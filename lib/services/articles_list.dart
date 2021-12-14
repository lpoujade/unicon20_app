import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../data/article.dart';
import '../tools/api.dart' as api;
import '../tools/db.dart' as db;

/// Hold a list of [Article], a connection to [Database] and
/// handle connections to wordpress
class ArticleList {
  late Database _db;
  String? _lang;

  final network_error = ValueNotifier<bool>(false);
  final articles = ValueNotifier<List<Article>>([]);

  ArticleList({required Database db}) {
    _db = db;
  }

  // Read current language from db
  init_lang() async {
    _lang = await db.get_locale(_db);
  }

  /// Update language
  /// Trigger a delete/download of all articles
  updateLang(l) async {
    // print("update lang to '$l'");
    _lang = l;
    await db.save_locale(_db, l);
    articles.value = [];
    await _db.delete('article');
    await get_articles();
  }

  get lang { return _lang; }

  /// Read articles from db then from wordpress
  get_articles() async {
    // await _db.delete('article'); // TODO REMOVE
    await get_from_db().then((local_articles) {
      articles.value += local_articles;
    });
    await _get_articles_from_wp();
  }

  /// Get new articles
  Future<List<Article>> refresh() async {
    return await _get_articles_from_wp();
  }

  /// Download and save new articles
  Future<List<Article>> _get_articles_from_wp() async {
    if (_lang == null) await init_lang();
    List<Article> wp_articles = [];
    try {
      wp_articles = await api.get_posts_from_wp(since: await db.get_last_sync_date(_db), lang: _lang);
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
    var batch = _db.batch();
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
      await _db.insert('article', article.toSqlMap(),
          conflictAlgorithm: ConflictAlgorithm.fail);
      articles.value = articles.value + [article];
    } catch (e) {
      // print("failed to save article '$article': '$e'");
    }
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
          read: (a['read'] == 1),
          categories: []);
    }).toList();
  }
}
