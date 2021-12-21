import 'package:unicon/services/categories_list.dart';

import 'abstract.dart';

/// Article data & serializations functions
class Article extends AData  {
  @override
  final int id;
  final String title;
  final String content;
  final String img;
  final bool important = false;
  bool read = false;
  late final DateTime date;
  // late final List<String> categories;
  late final CategoriesList categories;

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
      'read': (read ? 1 : 0)
    };
  }

  @override
  String toString() {
    return "Article('$id', '$title', '$categories')";
  }
}
