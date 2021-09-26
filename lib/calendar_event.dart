import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';

import 'api.dart' as api;
import 'db.dart' as db;

/// Event data
class CalendarEvent {
  final String uid;
  final String title;
  final DateTime start;
  final DateTime end;
  final String location;
  final String type;
  final String description;
  final String summary;
  int day;
  int startHour;
  int timeTaken;
  Color backColor;

  CalendarEvent({
    required this.uid,
    required this.title,
    required this.start,
    required this.end,
    required this.location,
    required this.type,
    required this.description,
    required this.summary
  }) : day = start.day,
    startHour = start.hour,
    timeTaken = end.hour - start.hour,
    backColor = const Color.fromRGBO(100, 100, 100, .5);

  CalendarEvent.fromICalJson(json, String calendar)
      : uid = json['UID'].toString(),
      title = json['SUMMARY'].toString(),
      start = DateTime.parse(json['DTSTART']),
      end = DateTime.parse(json['DTEND']),
      location = json['LOCATION'].toString(),
      type = calendar,
      description = json['DESCRIPTION'].toString(),
      summary = json['SUMMARY'].toString(),
      day = DateTime.parse(json['DTSTART']).day,
      backColor = const Color.fromRGBO(100, 100, 100, .5),
      startHour = DateTime.parse(json['DTSTART']).hour,
      timeTaken = DateTime.parse(json['DTEND']).hour - DateTime.parse(json['DTSTART']).hour;

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
}

/// Hold a [CalendarEvent] list, a connection
/// to [Database] and functions to read from
/// google ics
class EventList {
  late Database _db;
  final events = ValueNotifier<List<CalendarEvent>>([]);

  EventList({required db}) {
    _db = db;
  }

  /// Get events from db and from google calendar
  get_events() async {
    await get_events_from_db()
        .then((e) {
          events.value += e;
        });
    if (events.value.isEmpty) {
      await get_events_from_google();
    }
  }

  /// Clear and refresh events from db & google
  refresh() async {
    events.value = [];
    get_events();
  }

  /// Download new events
  get_events_from_google() {
    var new_events_list = api.get_events_from_google();
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