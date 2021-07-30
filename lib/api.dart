import 'dart:convert' show json;
import 'package:http/http.dart' as http;
import 'article.dart' show Article;
import 'dart:developer';

const api_base = 'https://unicon20.fr/wp-json/wp/v2';
// const api_base = 'http://192.168.88.243:8080/wp-json/wp/v2';
/* args:
   - after (ISO8601)
   - exclude (ids list)
   */


/// get posts from wordpress API	
Future<List<Article>> getPostsList({since, exclude_ids = const [], only_ids = const []}) async {
  var path = api_base + '/posts';
	List filters = [];
	if (since != null) filters.add('after=' + since.toIso8601String());
	if (exclude_ids.isNotEmpty) filters.add('exclude=' + exclude_ids.join(','));
	if (only_ids.isNotEmpty) filters.add('include=' + only_ids.join(','));
	if (filters.isNotEmpty) path += '?' + filters.join('&');
  log("get '$path'");
  var url = Uri.parse(path);
  List<dynamic> postList = json.decode(await http.read(url));

  var articles = <Article>[];

  for (final p in postList) {
    articles.add(
        Article(
            id: p['id'],
            title: p['title']['rendered'],
            content: p['content']['rendered'],
            date: DateTime.parse(p['date'])
            ));
  }
  return articles;
}
