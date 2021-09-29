import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'api.dart' as api;
import 'db.dart' as db;

/// Article infos
class Article {
  final int id;
  final String title;
  final String content;
  final String img;
  final bool important = false;
  bool read = false;
  late final DateTime date;

  Article(
      {required this.id,
      required this.title,
      required this.content,
      required this.img,
      required this.date,
      required this.read});

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
    return "Article('$id', '$title')";
  }
}

/// Hold a list of [Article], a connection to [Database] and
/// handle connections to wordpress
class ArticleList {
  late Database _db;
  String _lang = '-';
  final articles = ValueNotifier<List<Article>>([]);

  bool waiting_network = false;

  ArticleList({required db}) {
    _db = db;
  }

  set lang(String l) {
    _lang = l;
  }

  /// Read articles from db then from wordpress
  get_articles() async {
    await get_from_db().then((local_articles) {
      articles.value += local_articles;
    });
    await get_articles_from_wp();
  }

  /// Get new articles
  Future<List<Article>> refresh() async {
    return await get_articles_from_wp();
  }

  /// Download and save new articles
  Future<List<Article>> get_articles_from_wp() async {
    if (_lang == '-') {
      print("ERROR can't get articles without language set");
      return [];
    }
    List<Article> new_articles = [];
    var from_wp = api.get_posts_from_wp(since: await db.get_last_sync_date(_db), lang: _lang);
    waiting_network = true;
    await from_wp.then((wp_articles) {
      articles.value += wp_articles;
      for (var article in wp_articles) {
        save_article(article);
        new_articles.add(article);
      }
    }).catchError((error) {
      log('error while downloading new articles: $error');
    }).whenComplete(() {
      waiting_network = false;
    });
    return new_articles;
  }

  /// Insert a new article in db
  save_article(Article article) async {
    await _db.insert('article', article.toSqlMap(),
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
      dynamic id = a['id'];
      return Article(
          id: id,
          title: a['title'].toString(),
          content: a['content'].toString(),
          img: a['img'].toString(),
          date: DateTime.fromMillisecondsSinceEpoch(date),
          read: (a['read'] == 1));
    }).toList();
  }
}
