import 'dart:convert' show json;
import 'package:http/http.dart' as http;

const api_base = 'https://unicon20.fr/wp-json/wp/v2';
// const api_base = 'http://192.168.88.243:8080/wp-json/wp/v2';
/* args:
- after (ISO8601)
- exclude (ids list)
- categories
*/

const categories = [8, 11];

getPostsList(int category) async {
    var cat = List.from(categories);
    cat.remove(category);
    final exclude_cat = cat.join(',');
    final path = api_base + "/posts?categories=$category&exclude_categories=$exclude_cat";
    var url = Uri.parse(path);
    List<dynamic> postList = json.decode(await http.read(url));

    Map<String, String> posts = Map<String, String>();

    for (final p in postList) {
        final post_title = p['title']['rendered'];
        final content = p['content']['rendered'];

        posts[post_title] = content;
    }
    return posts;
}
