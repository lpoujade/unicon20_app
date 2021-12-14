import 'dart:developer';

import 'dart:convert' show json;
import 'package:http/http.dart' as http;
import 'package:http_retry/http_retry.dart';
import 'package:ical_parser/ical_parser.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../data/article.dart' show Article;
import '../data/event.dart' show CalendarEvent;
import '../config.dart' as config;

/// get posts from wordpress API
///
/// return a list of [Article]
Future<List<Article>> get_posts_from_wp(
    {since, exclude_ids = const [], only_ids = const [], lang = ''}) async {

  print('api using lang $lang');
  var _lang = (lang.isEmpty || lang == 'en') ? '' : "/$lang";
  var path = config.wordpress_host + _lang + config.api_path + '/posts';
  var filters = ['_embed'];
  if (since != null) filters.add('after=' + since.toIso8601String());
  if (exclude_ids.isNotEmpty) filters.add('exclude=' + exclude_ids.join(','));
  if (only_ids.isNotEmpty) filters.add('include=' + only_ids.join(','));
  if (filters.isNotEmpty) path += '?' + filters.join('&');
  print("http GET '$path'");
  var url = Uri.parse(path);
  var articles = <Article>[];

  List<dynamic> postList = [];
 
  var client = RetryClient(http.Client(),
      whenError: (_o, _s) => true,
      retries: 3);
      //onRetry: (req, resp, status) => print("retrying '$req' ($status)"));
  try {
    print('get $url');
    var response = await client.read(url).timeout(const Duration(seconds: 60));
    print("got api response");
    postList = json.decode(response);
  } catch(err) {
    Fluttertoast.showToast(
        msg: "Failed to fetch articles",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 2,
        fontSize: 16.0
    );
    rethrow;
  } finally { client.close(); }

  for (final p in postList) {
    final img =  (p['_embedded']['wp:featuredmedia'] != null)
        ? p['_embedded']['wp:featuredmedia'].first['media_details']['sizes']['thumbnail']['source_url']
        : '';

    List<String> categories = [];
    print('categories for ${p['title']['rendered']}');
    for (List category in p['_embedded']['wp:term']) {
      if (category.isEmpty) continue;
      categories.add(category[0]['slug']);
      print('added ${category[0]['slug']}');
    }
    articles.add(Article(
            id: p['id'],
            title: HtmlUnescape().convert(p['title']['rendered']),
            content: p['content']['rendered'],
            img: img,
            date: DateTime.parse(p['date']),
            read: false,
            categories: categories)
    );
  }

  return articles;
}

/// Download calendar from an ICS URL and parse it into
/// [CalendarEvent] array
Future<List<CalendarEvent>> get_events_from_ics() async {
  List<CalendarEvent> event_list = [];

  for (String cal in config.calendars.keys) {
    print("http GET '$cal': '${config.calendars[cal]}");
    var client = RetryClient(http.Client());
    try {
      String raw_ical = await client.read(Uri.parse(config.calendars[cal]!['url'].toString()));
      var json = ICal.toJson(raw_ical);
      var json_events = json['VEVENT'];
      for (var event in json_events) {
        var e = CalendarEvent.fromICalJson(event, cal);
        event_list.add(e);
      }
    } catch(err) {
      Fluttertoast.showToast(
          msg: "Failed to fetch calendar events",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 2,
          fontSize: 16.0
      );
      rethrow;
    } finally { client.close(); }
  }
  return event_list;
}
