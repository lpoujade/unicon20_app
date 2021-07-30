import 'db.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:developer';

class Article {
  final id;
  final title;
  final content;
  // final bool important;
  var date = DateTime.now();

  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.date
  });

  Map<String, dynamic> toSqlMap() {
    return {'id': id, 'title': title, 'content': content, 'date': date.millisecondsSinceEpoch};
  }

  @override
  String toString() {
    return "Article('$id', '$title')";
  }
}

Future<void> save_article(Article article) async {
  final db = await database();

  await db.insert(
      'article',
      article.toSqlMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
  );
}

Future<List<Article>> get_articles() async {
  final db = await database();

  List<Map<String, dynamic>> maps = await db.rawQuery('select * from article');

  return List.generate(maps.length, (i) {
    return Article(
        id: maps[i]['id'],
        title: maps[i]['title'],
        content: maps[i]['content'],
        date: DateTime.fromMillisecondsSinceEpoch(maps[i]['date'])
    );
  });
}
