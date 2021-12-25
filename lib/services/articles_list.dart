import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:unicon/tools/list.dart';

import '../data/article.dart';
import '../tools/api.dart' as api;
import 'database.dart';

/// Hold a list of [Article], a connection to [Database] and
/// handle connections to wordpress
class ArticleList extends ItemList<Article> {

  String? _lang;
  bool loaded = false;
  final network_error = ValueNotifier<bool>(false);

  ArticleList({required DBInstance db})
    : super(db: db, db_table: 'article');

  /// Read current language from db
  init_lang() async {
    _lang = await db.get_locale();
  }

  /// Update language
  /// Trigger a delete/download of all articles
  update_lang(l) async {
    // print("update lang to '$l'");
    _lang = l;
    await db.save_locale(l);
    items.value = [];
    (await db.db).delete('article');
    fill();
  }

  get lang { return _lang; }

  @override
  save_list() async {
      await super.save_list();
      for (var a in items.value) await a.categories.save();
  }

  /// Read articles from db then from wordpress
  @override
  fill() async {
    await refresh();
  }

  // Fetch wp articles and update network status
  Future<List<Article>> _fetch_wp_articles() async {

    List<Article> wp_articles = [];

    if (_lang == null) {
      await init_lang();
    }

    try {
      wp_articles = await api.get_posts_from_wp(
          since: await db.get_last_sync_date(),
          lang: _lang
      );
      network_error.value = false;
    } catch(err) {
      network_error.value = true;
    }

    return wp_articles;
  }

  // refresh loaded articles
  Future<List<Article>> refresh() async {

    final List<Article> db_articles = [];
    final List<Article> new_articles = [];

    for(var raw_article in await super.get_from_db()) {
      db_articles.add(await Article.to_article(db, raw_article));
    }

    final List<Article> wp_articles = await _fetch_wp_articles();

    for(var wp_article in wp_articles) {

      final Article? db_article = db_articles.firstWhereOrNull((element) => wp_article.id == element.id);

      if(db_article != null) {
        db_article.title = wp_article.title;
        db_article.content = wp_article.content;
        db_article.img = wp_article.img;
        db_article.categories = wp_article.categories;
      } else {
        new_articles.add(wp_article);
        db_articles.add(wp_article);
      }
    }

    items.value = db_articles;

    if (wp_articles.isNotEmpty) {
      await save_list();
    }

    return new_articles;
  }
}
