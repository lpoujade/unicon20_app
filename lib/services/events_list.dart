/// Manage events list

import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'package:http_retry/http_retry.dart';
import 'package:ical_parser/ical_parser.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocode/geocode.dart';

import '../data/event.dart';
import '../tools/list.dart';
import 'database.dart';
import '../config.dart' as config;

/// Hold a [Event] list, a connection
/// to [Database] and functions to read from
/// an ICS URL
class EventList extends ItemList<Event> {
	List<Event> _items = [];
  EventList({required DBInstance db}): super(db: db, db_table: 'events');

	List<DateTime> dates = [];

  /// Get events from db and from ics calendar
  @override
  fill() async {
   var raw_events = await super.get_from_db(); 

	 items.value = raw_events.map((e) {
			 return Event(
					 uid: e['uid'].toString(),
					 title: e['title'].toString(),
					 start: DateTime.fromMillisecondsSinceEpoch(e['start'] as int),
					 end: DateTime.fromMillisecondsSinceEpoch(e['end'] as int),
					 location: e['location'].toString(),
					 type: e['type'].toString(),
					 description: e['description'].toString(),
					 summary: e['summary'].toString(),
					 modification_date: DateTime.fromMillisecondsSinceEpoch(e['modification_date'] as int)
			 );
			 }).toList();
    await refresh();
  }

  /// Download [Events] from ICS URLs
  Future<void> refresh() async {
    var last_sync_date = await db.get_last_event_sync_date();
    for (String cal in config.calendars.keys) {
      var client = RetryClient(http.Client());
      try {
        String raw_date = await client.read(Uri.parse(config.calendar_check_url + cal));
        var date = DateTime.parse(raw_date.trim());
        if (last_sync_date == null || date.isAfter(last_sync_date))
        // TODO await all in once
          await download_calendar(cal, config.calendars[cal]!['url']);
      } catch(err) {
        print("failed to check events update: '$err'");
      }
    }
		fill_locations();
    save_list();
		_items = items.value;
  }

  download_calendar(String name, String url) async {
    List<Event> event_list = [];
    print("http GET '$name': '$url");
    var client = RetryClient(http.Client());
    try {
      String raw_ical = await client.read(Uri.parse(url));
      var json = ICal.toJson(raw_ical);
      var json_events = json['VEVENT'];
      for (var event in json_events) {
        var e = Event.fromICalJson(event, name);
        event_list.add(e);
      }
      items.value.removeWhere((element) => element.type == name);
      items.value += event_list;
    } catch(err) {
      Fluttertoast.showToast(
          msg: "Failed to fetch events from '$name' calendar at '$url'",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 2,
          fontSize: 16.0
      );
      rethrow;
    } finally { client.close(); }
  }

	Future<Map<String, List<Event>>> get_places() async {

		Map<String, List<Event>> places = {};
		for (Event event in items.value) {
			var loc = event.location;
			if (loc == null) continue;
			if (loc == 'TBD') continue; // TODO remove once fixed upstream
			if (!places.keys.contains(loc)) {
				places[loc] = <Event>[];
			}

			places[loc]?.add(event);
		}

		return places;
	}

	_update_item(_item) {
		// items.value.removeWhere((element) => element.id == _item.id);
		var t = items.value;
		items.value = [];
		t.removeWhere((i) => i.id == _item.id);
		t.add(_item);
		items.value = t;
		// items.value = items.value + [_item];
		// items.value.add(_item);
	}

	fill_locations() async {
		var locs = {};
		late GeoCode geocode = GeoCode();
		for (var ev in items.value) {
			if (ev.location == null
					|| ev.location == 'TBD' // TODO remove once fixed upstream
					|| ev.location == '')
				continue;
			if (locs.keys.contains(ev.location)) {
				ev.coords = locs[ev.location];
				_update_item(ev);
				continue;
			}
			var saved = await db.get_loc(ev.location);
			if (saved != null) {
				locs[ev.location] = saved;
				_update_item(ev);
				continue;
			}
			Coordinates latlng;
			try {
				latlng = await geocode.forwardGeocoding(address: ev.location!);
				sleep(const Duration(seconds: 2));
			}
			catch (err) {
				print("didn't found ${ev.location} or req failed : $err");
				continue;
			}
			print("fetched loc $latlng for ${ev.location}");
			var lat = latlng.latitude!;
			var lon  = latlng.longitude!;
			ev.coords = [lat, lon];
			_update_item(ev);
			locs[ev.location] = [lat, lon];
			db.insert_loc(ev.location, lat, lon);
		}
	}

	filter_reset() { items.value = _items; }

	filter_by_day(DateTime date) {
		items.value = _items.where((e) => DateTime(e.start.year, e.start.month, e.start.day) == date).toList();
	}
}
