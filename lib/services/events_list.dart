import 'package:sqflite/sqflite.dart';

import '../data/event.dart';
import '../tools/api.dart' as api;
import '../tools/list.dart';
import 'database.dart';

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
      return Event(
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
    if (items.value.isEmpty) {
      await refresh();
    }
  }

  /// Download [Events] from ICS URLs
  @override
  refresh() async {
    var ev = await api.get_events_from_ics();
    save_list(ev);
    return ev;
  }
}
