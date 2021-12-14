import 'dart:developer';
import 'package:sqflite/sqflite.dart';

import '../data/event.dart';
import '../tools/api.dart' as api;
import '../tools/list.dart';
import 'database.dart';

/// Hold a [CalendarEvent] list, a connection
/// to [Database] and functions to read from
/// an ICS URL
class EventList extends ItemList {
  EventList({required DBInstance db}): super(db: db, db_table: 'events');

  /// Get events from db and from ics calendar
  @override
  fill() async {
    var local_events = await get_events_from_db();
    items.value += local_events;
    if (items.value.isEmpty) {
      await get_events_from_ics();
    }
  }

  /// Clear and refresh events from db & ics
  @override
  refresh() async {
    get_events_from_ics();
  }

  /// Download new events
  get_events_from_ics() {
     api.get_events_from_ics()
       .then((new_events) {
         save_list(new_events);
    }).catchError((error) {
      log('error while downloading events: $error');
    });
  }

  /// Read events from db
  Future<List<CalendarEvent>> get_events_from_db() async {
    Database dbi = await db.db;
    var raw_events = await dbi.query('events');

    return raw_events.map((e) {
      dynamic start = e['start'];
      dynamic end = e['end'];
      return CalendarEvent(
          uid: e['uid'].toString(),
          title: e['title'].toString(),
          start: DateTime.fromMillisecondsSinceEpoch(start),
          end: DateTime.fromMillisecondsSinceEpoch(end),
          location: e['location'].toString(),
          type: e['type'].toString(),
          description: e['description'].toString(),
          summary: e['summary'].toString()
      );
    }).toList();
  }
}
