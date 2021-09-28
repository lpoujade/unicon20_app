import 'package:flutter/material.dart';
import 'dart:convert' show json;
import 'package:http/http.dart' as http;
import 'article.dart' show Article;
import 'calendar_event.dart' show CalendarEvent;
import 'dart:developer';

import 'package:ical_parser/ical_parser.dart';

// TODO move to env/conf
const api_host = String.fromEnvironment('API_HOST',
    defaultValue: 'https://unicon20.fr');
const api_base = '$api_host/wp-json/wp/v2';

const Map<String, Map<String, dynamic>> calendars = {
  'admin': {
    'url': 'https://calendar.google.com/calendar/ical/j39mlonvmepkdc4797nk88f7ok%40group.calendar.google.com/public/basic.ics',
    'color': Colors.black
  },
  'freestyle': {
    'url': 'https://calendar.google.com/calendar/ical/4e19oc9m4f7jnfrt1c7hm3lekc%40group.calendar.google.com/public/basic.ics',
    'color': Colors.red
  },
  'muni': {
    'url': 'https://calendar.google.com/calendar/ical/o0n78b4n7ssq326obekeasbf8k%40group.calendar.google.com/public/basic.ics',
    'color': Colors.blue
  },
  'road': {
    'url': 'https://calendar.google.com/calendar/ical/f53rlq1p3jcm4tf3jguaj1a5ss%40group.calendar.google.com/public/basic.ics',
    'color': Colors.yellow
  },
  'team': {
    'url': 'https://calendar.google.com/calendar/ical/sb5l8ble394dohk4kdfnnsarlg%40group.calendar.google.com/public/basic.ics',
    'color': Colors.pink
  },
  'track': {
    'url': 'https://calendar.google.com/calendar/ical/4lbqed8as0a1c2gaes252amn8k%40group.calendar.google.com/public/basic.ics',
    'color': Colors.deepOrange
  },
  'urban': {
    'url': 'https://calendar.google.com/calendar/ical/55rrt700v8beo61h185cfptu5k%40group.calendar.google.com/public/basic.ics',
    'color': Colors.green
  },
  'workshop': {
    'url': 'https://calendar.google.com/calendar/ical/acg4v7l8j9i8li8mfg29i2758g%40group.calendar.google.com/public/basic.ics',
    'color': Colors.brown
  }
};

/// get posts from wordpress API
///
/// return a list of [Article]
Future<List<Article>> get_posts_from_wp(
    {since, exclude_ids = const [], only_ids = const []}) async {
  var path = api_base + '/posts';
  var filters = [];
  if (since != null) filters.add('after=' + since.toIso8601String());
  if (exclude_ids.isNotEmpty) filters.add('exclude=' + exclude_ids.join(','));
  if (only_ids.isNotEmpty) filters.add('include=' + only_ids.join(','));
  if (filters.isNotEmpty) path += '?' + filters.join('&');
  log("http GET '$path'");
  var url = Uri.parse(path);
  var articles = <Article>[];

  try {
    var response = await http.read(url).timeout(const Duration(seconds: 20));
    List<dynamic> postList = json.decode(response);

    for (final p in postList) {
      final img = p['featured_media'] == 0 ? '' : p['featured_image_urls']['thumbnail'].first;
      articles.add(Article(
              id: p['id'],
              title: p['title']['rendered'],
              content: p['content']['rendered'],
              img: img,
              date: DateTime.parse(p['date']),
              read: false)
          );
    }
  } catch(err) {
    log("network error: $err");
  }

  return articles;
}

Future<List<CalendarEvent>> get_events_from_google() async {
  List<CalendarEvent> event_list = [];

  for (String cal in calendars.keys) {
    log("http GET '$cal': '${calendars[cal]}");
    String raw_ical = await http.read(Uri.parse(calendars[cal]!['url'].toString()));
    var json = ICal.toJson(raw_ical);
    var json_events = json['VEVENT'];
    for (var event in json_events) {
      event_list.add(CalendarEvent.fromICalJson(event, cal));
    }
  }
  return event_list;
}
