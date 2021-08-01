import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import 'api.dart' as api;
import 'db.dart' as db;

/// Article infos
class Article {
  final id;
  final title;
  var content;
  // final bool important;
  // bool read;
  late final DateTime date;

  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.date
  });

  Map<String, dynamic> toSqlMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.millisecondsSinceEpoch
    };
  }

  @override
  String toString() {
    return "Article('$id', '$title')";
  }
}

/// Hold a list of [Article], a connection to [Database] and
/// handle connections to wordpress  
/// `last_sync_date` is the date of the newest article in local db
class ArticleList {
  late Database _db;
  var _articles = <Article>[];

  DateTime? last_sync_date;
  bool up_to_date = false;
  bool waiting_network = false;

  /// Get database connection and save last sync date
  _init_db() async {
    _db = await db.init_database();
    last_sync_date = await db.get_last_sync_date(_db);
  }
  
  /// TODO db init

  /// Get articles from db
  Future<List<Article>> get_articles() async {
    await _init_db();
    var from_db = get_from_db().then((articles) {
      _articles += articles;
      return articles;
    });

    return from_db;
  }

  /// Download new articles
  Future<List<Article>> more() async {
    if (up_to_date) return _articles;
    var from_wp = api.get_posts_from_wp(since: last_sync_date);
    waiting_network = true;
    from_wp.then((articles) {
      _articles += articles;
      articles.forEach((article) {
        save_article(article);
      });
      up_to_date = true;
    })
    .catchError((error) {
      log('error download new articles: ${error}');
    })
    .whenComplete(() { waiting_network = false; });
    await Future.wait([from_wp]);
    return _articles;
  }

  /// Insert a new article in db
  save_article(Article article) async {
    _db.insert(
      'article',
      article.toSqlMap(),
      conflictAlgorithm: ConflictAlgorithm.fail
    );
  }

  /// Read articles saved in db
  Future<List<Article>> get_from_db() async {
    var raw_articles = await _db.rawQuery('select * from article');

    return raw_articles.map((a) {
      dynamic timestamp = a['date'];
      return Article(id: a['id'],
          title: a['title'],
          content: a['content'],
          date: DateTime.fromMillisecondsSinceEpoch(timestamp)
      );
    }).toList();
  }
}
