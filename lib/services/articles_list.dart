import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../data/article.dart';
import '../tools/api.dart' as api;
import 'database.dart';

/// Hold a list of [Article], a connection to [Database] and
/// handle connections to wordpress
class ArticleList {
  late DBInstance _db;
  String? _lang;

  final network_error = ValueNotifier<bool>(false);
  final articles = ValueNotifier<List<Article>>([]);

  ArticleList({required DBInstance db}) { _db = db; }

  // Read current language from db
  init_lang() async {
    _lang = await _db.get_locale();
  }

  /// Update language
  /// Trigger a delete/download of all articles
  update_lang(l) async {
    // print("update lang to '$l'");
    _lang = l;
    await _db.save_locale(l);
    articles.value = [];
    Database db = await _db.db;
    await db.delete('article');
    await get_articles();
  }

  get lang { return _lang; }

  /// Read articles from db then from wordpress
  get_articles() async {
    var local_articles = await get_from_db();
    articles.value = local_articles;
    _get_articles_from_wp();
  }

  /// Get new articles from wordpress
  Future<List<Article>> refresh() async {
    return await _get_articles_from_wp();
  }

  /// Download and save new articles
  Future<List<Article>> _get_articles_from_wp() async {
    if (_lang == null) await init_lang();
    List<Article> wp_articles = [];
    try {
      print('get_posts_from_wp');
      wp_articles = await api.get_posts_from_wp(
          since: await _db.get_last_sync_date(),
          lang: _lang
      );
      await save_articles(wp_articles);
      articles.value += wp_articles;
      network_error.value = false;
    } catch (err) {
      network_error.value = true;
    }
    return wp_articles;
  }

  /// Insert a list of [Article] using [Batch]
  save_articles(List<Article> articles) async {
    // save_categories(articles)
    Database db = await _db.db;
    var batch = db.batch();
    for (var a in articles) batch.insert('article', a.toSqlMap());
    try {
      batch.commit(noResult: true);
    } catch (e) {
      // print("failed to insert some articles from '$articles': '$e'");
    }
  }

  /// Insert a new article in db
  save_article(Article article) async {
    try {
      Database db = await _db.db;
      await db.insert('article', article.toSqlMap(),
          conflictAlgorithm: ConflictAlgorithm.fail);
      articles.value = articles.value + [article];
    } catch (e) {
      log("failed to save article '$article': '$e'");
    }
  }

  /// Update an existing article
  update_article(Article article) async {
    Database db = await _db.db;
    db.update('article', article.toSqlMap(),
    where: 'id = ?', whereArgs: [article.id]);
  }

  /// Read articles from db
  Future<List<Article>> get_from_db() async {
    Database db = await _db.db;
    var raw_articles = await db.query('article');

    return raw_articles.map((a) {
      dynamic date = a['date'];
      dynamic id = a['id'];
      return Article(
          id: id,
          title: a['title'].toString(),
          content: a['content'].toString(),
          img: a['img'].toString(),
          date: DateTime.fromMillisecondsSinceEpoch(date),
          read: (a['read'] == 1),
          categories: []);
    }).toList();
  }
}
