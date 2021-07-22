import 'db.dart';
import 'package:sqflite/sqflite.dart';

class Article {
  final id;
  final title;
  final content;

  Article({
    required this.id,
    required this.title,
    required this.content,
  });

  Map<String, dynamic> toMap() {
    var map = {'title': title, 'content': content};
    if (id != 0)
      map['rowid'] = id;
    return map;
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
      article.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<List<Article>> get_articles() async {
  final db = await database();

  final List<Map<String, dynamic>> maps = await db.query('article');

  return List.generate(maps.length, (i) {
    return Article(
        id: maps[i]['rowid'],
        title: maps[i]['title'],
        content: maps[i]['content'],
    );
  });
}

Future<void> update_article(Article article) async {
  final db = await database();

  await db.update(
      'article',
      article.toMap(),
      where: 'rowid = ?',
      whereArgs: [article.id],
  );
}
