import 'dart:convert' show json;

import 'package:http/http.dart' as http;
import 'package:ical_parser/ical_parser.dart';

import 'article.dart' show Article;
import 'calendar_event.dart' show CalendarEvent;
import 'config.dart' as config;

/// get posts from wordpress API
///
/// return a list of [Article]
Future<List<Article>> get_posts_from_wp(
    {since, exclude_ids = const [], only_ids = const [], lang = ''}) async {
  var _lang = (lang.isEmpty || lang == 'en') ? '' : "/$lang";
  var path = config.api_host + _lang + config.api_path + '/posts';
  var filters = [];
  if (since != null) filters.add('after=' + since.toIso8601String());
  if (exclude_ids.isNotEmpty) filters.add('exclude=' + exclude_ids.join(','));
  if (only_ids.isNotEmpty) filters.add('include=' + only_ids.join(','));
  if (filters.isNotEmpty) path += '?' + filters.join('&');
  print("http GET '$path'");
  var url = Uri.parse(path);
  var articles = <Article>[];

  try {
    var response = await http.read(url).timeout(const Duration(seconds: 30));
    print("got api response");
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
    print("network error while fetching articles: '$err'");
  }

  return articles;
}

Future<List<CalendarEvent>> get_events_from_google() async {
  List<CalendarEvent> event_list = [];

  for (String cal in config.calendars.keys) {
    print("http GET '$cal': '${config.calendars[cal]}");
    try {
      String raw_ical = await http.read(Uri.parse(config.calendars[cal]!['url'].toString()));
      var json = ICal.toJson(raw_ical);
      var json_events = json['VEVENT'];
      for (var event in json_events) {
        event_list.add(CalendarEvent.fromICalJson(event, cal));
      }
    } catch(err) {
      print("network error while fetching calendar $cal: '$err'");
    }
  }
  return event_list;
}
