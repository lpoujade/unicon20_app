import 'dart:convert' show json;
import 'package:http/http.dart' as http;
import 'article.dart' show Article;
import 'dart:developer';

const api_host = String.fromEnvironment('API_HOST',
    defaultValue: 'https://unicon20.fr');
const api_base = '${api_host}/wp-json/wp/v2';

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
  log("get '$path'");
  var url = Uri.parse(path);
  // TODO error handling, timeout
  List<dynamic> postList = json.decode(await http.read(url));

  var articles = <Article>[];

  for (final p in postList) {
    articles.add(Article(
        id: p['id'],
        title: p['title']['rendered'],
        content: p['content']['rendered'],
        date: DateTime.parse(p['date']),
        read: false));
  }
  return articles;
}
