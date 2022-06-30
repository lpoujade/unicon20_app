/// Wordpress API connection, to be moved to lib/data/article.dart

import 'dart:convert' show json;

import 'package:fluttertoast/fluttertoast.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;
import 'package:http_retry/http_retry.dart';

import '../config.dart' as config;
import '../data/article.dart' show Article;
import '../data/category.dart';
import '../services/categories_list.dart';
import '../services/database.dart';

/// get posts from wordpress API
///
/// return a list of [Article]
Future<List<Article>> get_posts_from_wp(
    {since, exclude_ids = const [], only_ids = const [], lang = ''}) async {
  print('api using lang $lang');
  var lang_param = (lang.isEmpty || lang == 'en') ? '' : "/$lang";
  var path = '${config.wordpress_host}$lang_param${config.wp_api_path}/posts';
  var filters = ['_embed', 'per_page=100'];
  if (since != null) filters.add('modified_after=${since.toIso8601String()}');
  if (exclude_ids.isNotEmpty) filters.add('exclude=${exclude_ids.join(",")}');
  if (only_ids.isNotEmpty) filters.add('include=${only_ids.join(",")}');
  if (filters.isNotEmpty) path += '?${filters.join("&")}';
  var url = Uri.parse(path);
  var articles = <Article>[];

  List<dynamic> postList = [];

  var client =
      RetryClient(http.Client(), whenError: (o, s) => true, retries: 3);
  try {
    print('get $url');
    var response = await client.read(url).timeout(const Duration(seconds: 60));
    postList = json.decode(response);
  } catch (err) {
    Fluttertoast.showToast(
        msg: "Failed to fetch articles",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 2,
        fontSize: 16.0);
    rethrow;
  } finally {
    client.close();
  }

  for (final p in postList) {
    var img = '';
    try {
      img = p['_embedded']['wp:featuredmedia'].first['media_details']['sizes']
          ['medium_large']['source_url'];
    } catch (e) {
      1;
    }

    var categories = CategoriesList(db: DBInstance(), parent_id: p['id']);
    for (var category in p['_embedded']['wp:term'][0]) {
      var cat = Category(
          id: category['id'], slug: category['slug'], name: category['name']);
      categories.list.add(cat);
    }
    articles.add(Article(
        id: p['id'],
        title: HtmlUnescape().convert(p['title']['rendered']),
        content: p['content']['rendered'],
        img: img,
        date: DateTime.parse(p['date']),
        modification_date: DateTime.parse(p['modified']),
        read: 0,
        categories: categories));
  }

  return articles;
}
