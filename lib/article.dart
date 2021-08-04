import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'api.dart' as api;
import 'db.dart' as db;

/// Article infos
class Article {
  final id;
  final title;
  var content;
  final bool important = false;
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
  final articles = ValueNotifier<List<Article>>([]);

  DateTime? last_sync_date;
  bool up_to_date = false;
  bool waiting_network = false;

  /// Get database connection and save last sync date
  _init_db() async {
    _db = await db.init_database();
    last_sync_date = await db.get_last_sync_date(_db);
  }

  
  /// TODO db init

  /// Init db, read articles from it, then get
  /// updates from wordpress
  get_articles() async {
    await _init_db();
    await get_from_db().then((local_articles) {
      articles.value += local_articles;
    });
    get_articles_from_wp();
  }

  /// Download new articles
  get_articles_from_wp() async {
    var from_wp = api.get_posts_from_wp(since: last_sync_date);
    waiting_network = true;
    from_wp.then((wp_articles) {
      articles.value += wp_articles;
      wp_articles.forEach((article) {
        save_article(article);
      });
      up_to_date = true;
    })
    .catchError((error) {
      log('error while downloading new articles: ${error}');
    })
    .whenComplete(() { waiting_network = false; });
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
