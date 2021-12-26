import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'package:http_retry/http_retry.dart';
import 'package:ical_parser/ical_parser.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../data/event.dart';
import '../tools/list.dart';
import 'database.dart';
import '../tools/utils.dart';
import '../config.dart' as config;

/// Hold a [Event] list, a connection
/// to [Database] and functions to read from
/// an ICS URL
class EventList extends ItemList<Event> {
  EventList({required DBInstance db}): super(db: db, db_table: 'events');

  /// Get events from db and from ics calendar
  @override
  fill() async {
   var raw_events = await super.get_from_db(); 

    items.value = raw_events.map((e) {
      dynamic start = e['start'];
      dynamic end = e['end'];
      dynamic modification_date = e['modification_date'];
      return Event(
          uid: e['uid'].toString(),
          title: e['title'].toString(),
          start: DateTime.fromMillisecondsSinceEpoch(start),
          end: DateTime.fromMillisecondsSinceEpoch(end),
          location: e['location'].toString(),
          type: e['type'].toString(),
          description: e['description'].toString(),
          summary: e['summary'].toString(),
          modification_date: DateTime.fromMillisecondsSinceEpoch(modification_date)
      );
    }).toList();
    await refresh();
  }

  /// Download [Events] from ICS URLs
  refresh() async {
    var last_sync_date = await db.get_last_event_sync_date();
    print("last event sync date: '$last_sync_date'");
    for (String cal in config.calendars.keys) {
      var client = RetryClient(http.Client());
      try {
        String raw_date = await client.read(Uri.parse(config.calendar_check_url + cal));
        var date = parse_date(raw_date.trim());
        if (last_sync_date == null || date.isAfter(last_sync_date))
          download_calendar(cal, config.calendars[cal]!['url']);
      } catch(err) {
        print("failed to check events update: '$err'");
      }
    }
    save_list();
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
}
