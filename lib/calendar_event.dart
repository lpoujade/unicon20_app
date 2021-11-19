import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';

import 'utils.dart';
import 'api.dart' as api;

/// Event data
class CalendarEvent {
  final String uid;
  final String title;
  DateTime start;
  DateTime end;
  final String location;
  final String type;
  final String description;
  final String summary;

  CalendarEvent({
    required this.uid,
    required this.title,
    required this.start,
    required this.end,
    required this.location,
    required this.type,
    required this.description,
    required this.summary
  });

  CalendarEvent.from(CalendarEvent e)
      : uid = e.uid,
      title = e.title,
      start = e.start,
      end = e.end,
      location = e.location,
      type = e.type,
      description = e.description,
      summary = e.summary;

  CalendarEvent.fromICalJson(json, String calendar)
      : uid = json['UID'].toString(),
      title = clean_ics_text_fields(json['SUMMARY']),
      start = DateTime.parse(json['DTSTART']).toLocal(),
      end = DateTime.parse(json['DTEND']).toLocal(),
      location = clean_ics_text_fields(json['LOCATION']),
      type = calendar,
      description = clean_ics_text_fields(json['DESCRIPTION']),
      summary = clean_ics_text_fields(json['SUMMARY']);

  Map<String, dynamic> toSqlMap() {
    return {
      'uid': uid,
      'title': title,
      'start': start.millisecondsSinceEpoch,
      'end': end.millisecondsSinceEpoch,
      'location': location,
      'type': type,
      'description': description,
      'summary': summary
    };
  }

  String toString() {
    return "$title $start $end (start is utc: ${start.isUtc})";
  }
}

/// Hold a [CalendarEvent] list, a connection
/// to [Database] and functions to read from
/// an ICS URL
class EventList {
  late Database _db;
  final events = ValueNotifier<List<CalendarEvent>>([]);

  EventList({required db}) {
    _db = db;
  }

  /// Get events from db and from ics calendar
  get_events() async {
    await get_events_from_db()
        .then((e) {
          events.value += e;
        });
    if (events.value.isEmpty) {
      await get_events_from_ics();
    }
  }

  /// Clear and refresh events from db & ics
  refresh() async {
    events.value = [];
    get_events();
  }

  /// Download new events
  get_events_from_ics() {
    var new_events_list = api.get_events_from_ics();
    new_events_list.then((new_event) {
      events.value += new_event;
      new_event.forEach(save_event);
    }).catchError((error) {
      log('error while downloading new articles: $error');
    });
  }

  /// Save a new [CalendarEvent]
  save_event(CalendarEvent event) {
    _db.insert('events', event.toSqlMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Read events from db
  Future<List<CalendarEvent>> get_events_from_db() async {
    var raw_events = await _db.query('events');

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