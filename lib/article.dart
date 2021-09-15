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
  bool read = false;
  late final DateTime date;

  Article(
      {required this.id,
      required this.title,
      required this.content,
      required this.date,
      required this.read});

  Map<String, dynamic> toSqlMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.millisecondsSinceEpoch,
      'read': (read ? 1 : 0)
    };
  }

  @override
  String toString() {
    return "Article('$id', '$title')";
  }
}

/// Hold a list of [Article], a connection to [Database] and
/// handle connections to wordpress
class ArticleList {
  late Database _db;
  final articles = ValueNotifier<List<Article>>([]);

  bool waiting_network = false;

  ArticleList({required db}) {
    this._db = db;
  }

  /// Read articles from db then from wordpress
  get_articles() async {
    await get_from_db().then((local_articles) {
      articles.value += local_articles;
    });
    await get_articles_from_wp();
  }

  /// Clear and refresh articles list
  Future<void> refresh() async {
    articles.value = [];
    get_articles();
  }

  /// Download and save new articles
  get_articles_from_wp() async {
    var from_wp = api.get_posts_from_wp(since: await db.get_last_sync_date(_db));
    waiting_network = true;
    from_wp.then((wp_articles) {
      articles.value += wp_articles;
      wp_articles.forEach((article) {
        save_article(article);
      });
    }).catchError((error) {
      log('error while downloading new articles: ${error}');
    }).whenComplete(() {
      waiting_network = false;
    });
  }

  /// Insert a new article in db
  save_article(Article article) async {
    _db.insert('article', article.toSqlMap(),
        conflictAlgorithm: ConflictAlgorithm.fail);
  }

  /// Update an existing article
  update_article(Article article) async {
    _db.update('article', article.toSqlMap(),
    where: 'id = ?', whereArgs: [article.id]);
  }

  /// Read articles from db
  Future<List<Article>> get_from_db() async {
    var raw_articles = await _db.query('article');

    return raw_articles.map((a) {
      dynamic date = a['date'];
      return Article(
          id: a['id'],
          title: a['title'],
          content: a['content'],
          date: DateTime.fromMillisecondsSinceEpoch(date),
          read: (a['read'] == 1));
    }).toList();
  }
}
