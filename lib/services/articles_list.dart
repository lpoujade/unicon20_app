/// Manage articles list

import 'package:sqflite/sqflite.dart';
import 'package:unicon/tools/list.dart';

import '../data/article.dart';
import '../tools/api.dart' as api;
import 'database.dart';
import '../config.dart' as config;

/// Hold a list of [Article], a connection to [Database] and
/// handle connections to wordpress
class ArticleList extends ItemList<Article> {
  String? _lang;
  bool loaded = false;

  ArticleList({required DBInstance db})
    : super(db: db, db_table: 'articles');

  /// Read current language from db
  init_lang() async {
    _lang = await db.get_locale();
  }

  /// Update language
  /// Trigger a delete/download of all articles
  update_lang(l) async {
    _lang = l;
    await db.save_locale(l);
    list.clear();
    (await db.db).delete('articles_categories');
    (await db.db).delete('categories');
    (await db.db).delete('articles');
    fill();
  }

  get lang { return _lang; }

  @override
  save_list() async {
      await super.save_list();
      for (var a in list) await a.categories.save();
  }

  /// Read articles from db then from wordpress
  @override
  fill({bool update=true}) async {
    for(var raw_article in await super.get_from_db()) {
     add(await Article.to_article(db, raw_article));
    }
		if (update) await refresh();
  }

  // Fetch wp articles and update network status
  Future<List<Article>> _fetch_wp_articles() async {

    List<Article> wp_articles = [];

    if (_lang == null) {
      await init_lang();
    }

    try {
      wp_articles = await api.get_posts_from_wp(
          since: (await db.get_last_sync_date()) ?? DateTime.parse(config.max_article_date),
          lang: _lang
      );
    } catch(err) { print(err); }

    return wp_articles;
  }

  /// refresh loaded articles
  Future<List<Article>> refresh() async {

    List<Article> new_articles = [];

    final List<Article> wp_articles = await _fetch_wp_articles();
    bool modified = false;

    for (var wp_article in wp_articles) {

      var db_article = list.firstWhere((element) => element.id == wp_article.id,
				orElse: () => null);

      if(db_article != null) {
				if (wp_article.modification_date != db_article.modification_date) {
					db_article.read = 0;
					db_article.date = wp_article.date;
					db_article.modification_date = wp_article.modification_date;
					db_article.title = wp_article.title;
					db_article.content = wp_article.content;
					db_article.img = wp_article.img;
					db_article.categories = wp_article.categories;
					modified = true;
				}
			} else {
				new_articles.add(wp_article);
				add(wp_article);
			}
		}

		if (modified || new_articles.isNotEmpty) {
			await save_list();
		}

		return new_articles;
	}
}
