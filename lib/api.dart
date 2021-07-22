import 'dart:convert' show json;
import 'package:http/http.dart' as http;
import 'article.dart' show Article;

const api_base = 'https://unicon20.fr/wp-json/wp/v2';
// const api_base = 'http://192.168.88.243:8080/wp-json/wp/v2';
/* args:
- after (ISO8601)
- exclude (ids list)
- categories
*/


Future<List<Article>> getPostsList(int category, [String exclude_articles = '']) async {
    final path = api_base + "/posts?categories=$category&exclude_articles=$exclude_articles";
    var url = Uri.parse(path);
    List<dynamic> postList = json.decode(await http.read(url));

    var posts = Map<String, String>();

    var articles = <Article>[];

    for (final p in postList) {
        final post_title = p['title']['rendered'];
        final content = p['content']['rendered'];

        posts[post_title] = content;
        articles.add(Article(id: 0, title: post_title, content: content));
    }
    return articles;
}
