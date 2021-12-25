import 'package:unicon/services/categories_list.dart';
import 'package:unicon/services/database.dart';

import 'abstract.dart';

/// Article data & serializations functions
class Article extends AData  {

  @override
  final int id;

  String title;
  String content;
  String img;
  int read = 0;
  int important = 0;
  DateTime date;
  CategoriesList categories;

  Article(
      {required this.id,
      required this.title,
      required this.content,
      required this.img,
      required this.date,
      required this.read,
      required this.categories})
      : super(db_id_field: 'id');

  @override
  Map<String, dynamic> toSqlMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'img': img,
      'date': date.millisecondsSinceEpoch,
      'read': read
    };
  }

  static Future<Article> to_article(DBInstance db, Map<String, dynamic> data) async {
    var categories = CategoriesList(db: db, parent_id: data['id']);
    await categories.fill();
    return Article(
        id: data['id'],
        title: data['title'],
        content: data['content'],
        img: data['img'],
        date : DateTime.fromMillisecondsSinceEpoch(data['date'] as int),
        read: data['read'],
        categories: categories
    );
  }

  @override
  String toString() {
    return "Article('$id', '$title', '$categories')";
  }
}
