/// Manage events list

import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'package:http_retry/http_retry.dart';
import 'package:ical_parser/ical_parser.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../data/event.dart';
import '../tools/list.dart';
import 'database.dart';
import '../tools/geofr.dart';
import '../config.dart' as config;

/// Hold a [Event] list, a connection
/// to [Database] and functions to read from
/// an ICS URL
class EventList extends ItemList<Event> {
  final List<Event> _items = [];
  EventList({required DBInstance db}) : super(db: db, db_table: 'events');

  List<DateTime> dates = [];
  var filters = {};

  /// Get events from db and from ics calendar
  @override
  fill() async {
    var raw_events = await super.get_from_db();

    list = raw_events.map((e) {
      return Event(
          uid: e['uid'].toString(),
          title: e['title'].toString(),
          start: DateTime.fromMillisecondsSinceEpoch(e['start'] as int),
          end: DateTime.fromMillisecondsSinceEpoch(e['end'] as int),
          location: e['location'].toString(),
          type: e['type'].toString(),
          description: e['description'].toString(),
          summary: e['summary'].toString(),
          modification_date: DateTime.fromMillisecondsSinceEpoch(
              e['modification_date'] as int));
    }).toList();
    await refresh();
    _items.clear();
    _items.addAll(list.cast<Event>());
  }

  /// Download [Events] from ICS URLs
  Future<void> refresh() async {
    var last_sync_date = await db.get_last_event_sync_date();
    for (String cal in config.calendars.keys) {
      var client = RetryClient(http.Client());
      try {
        String raw_date =
            await client.read(Uri.parse(config.calendar_check_url + cal));
        var date = DateTime.parse(raw_date.trim());
        if (last_sync_date == null || date.isAfter(last_sync_date)) {
          await delete_calendar(cal);
          await download_calendar(cal, config.calendars[cal]!['url'], date);
        }
      } catch (err) {
        print("failed to check events update: '$err'");
      }
    }
    await fill_locations();
    save_list();
  }

  Future<void> download_calendar(String name, String url, DateTime date) async {
    List<Event> event_list = [];
    print("http GET '$name': '$url");
    var client = RetryClient(http.Client());
    try {
      String raw_ical = await client.read(Uri.parse(url));
      var json = ICal.toJson(raw_ical);
      var json_events = json['VEVENT'];
      for (var event in json_events) {
        var e = Event.fromICalJson(event, name, date);
        event_list.add(e);
      }
      list.removeWhere((element) => element.type == name);
      list = list + event_list;
    } catch (err) {
      Fluttertoast.showToast(
          msg: "Failed to fetch events from '$name' calendar at '$url'",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 2,
          fontSize: 16.0);
      rethrow;
    } finally {
      client.close();
    }
  }

  delete_calendar(String name) async {
    (await db.db).delete('events', where: 'type = ?', whereArgs: [name]);
  }

  Future<Map<String, List<Event>>> get_places() async {
    Map<String, List<Event>> places = {};
    for (Event event in list) {
      var loc = event.location;
      if (loc == null) continue;
      if (!places.keys.contains(loc)) {
        places[loc] = <Event>[];
      }

      places[loc]?.add(event);
    }

    return places;
  }

  fill_locations() async {
    Map<String, List<double>> locs = {};
    var invalids = {};
    late GeoFR geocode = GeoFR();
    for (var ev in list) {
      if (ev.location == null || invalids.keys.contains(ev.location)) {
        if (invalids.keys.contains(ev.location))
          invalids[ev.location]?.add(ev.title);
        continue;
      }
      if (RegExp(r"-?[0-9]{1,2}\.[0-9]{6}, ?-?[0-9]{1,2}\.[0-9]{6}")
          .hasMatch(ev.location!)) {
        ev.coords = ev.location.split(',').map((e) => double.parse(e)).toList();
        notifyListeners();
        continue;
      }
      if (locs.keys.contains(ev.location)) {
        ev.coords = locs[ev.location];
        notifyListeners();
        continue;
      }
      var saved = await db.get_loc(ev.location);
      if (saved != null) {
        locs[ev.location!] = saved;
        ev.coords = saved;
        notifyListeners();
        continue;
      }
      var coords = <double>[];
      try {
        coords = await geocode.geocode(ev.location!);
      } catch (err) {
        invalids[ev.location] = [ev.title];
        continue;
      }
      ev.coords = coords;
      notifyListeners();
      locs[ev.location!] = coords;
      await db.insert_loc(ev.location, coords[0], coords[1]);
    }
    if (invalids.keys.isNotEmpty) {
      print("didn't found coords for: ");
      for (var f in invalids.keys) print("'$f' : '${invalids[f]}'");
    }
  }

  get_day_extent() {
    List<DateTime> dates = [];
    for (Event e in _items) {
      var start_day = DateTime(e.start.year, e.start.month, e.start.day);
      var end_day = DateTime(e.end.year, e.end.month, e.end.day);
      if (!dates.contains(start_day)) dates.add(start_day);
      if (end_day != start_day && !dates.contains(end_day)) dates.add(end_day);
    }
    dates.sort((a, b) => a.compareTo(b));
    return dates;
  }

  get_calendars() {
    // we don't want duplicates, so
    // ignore: prefer_collection_literals
    var calendars = Set();
    for (var ev in _items) {
      calendars.add(ev.type);
    }
    return calendars;
  }

  filter_reset() {
    list = _items;
  }

  filter(dates, types) {
    if (dates.isEmpty && types.isEmpty) {
      list = _items;
      return;
    }
    list = _items
        .where((e) =>
            (dates.isEmpty ||
                (dates.contains(
                        DateTime(e.start.year, e.start.month, e.start.day)) ||
                    dates.contains(
                        DateTime(e.end.year, e.end.month, e.end.day)))) &&
            (types.isEmpty || types.contains(e.type)))
        .toList();
  }
}
