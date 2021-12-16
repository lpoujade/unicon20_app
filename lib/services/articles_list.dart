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

  /// Read articles from db then from wordpress
  @override
    fill() async {
    print("fill articles");
      var raw_articles = await super.get_from_db(); 
      items.value = raw_articles.map((a) {
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
      refresh();
    }

  /// Get new articles from wordpress
  @override
    Future<List<Article>> refresh() async {
      if (_lang == null) await init_lang();
      List<Article> wp_articles = [];
      try {
        print('get_posts_from_wp');
        wp_articles = await api.get_posts_from_wp(
            since: await db.get_last_sync_date(),
            lang: _lang
            );
        await save_list(wp_articles);
        network_error.value = false;
      } catch (err) {
        network_error.value = true;
      }
      return wp_articles;
    }
}
