import 'package:flutter/material.dart';

import '../data/article.dart';
import '../services/articles_list.dart';

/// News page (first app screen)
ValueListenableBuilder<List<Article>> news_page(ArticleList home_articles, var clicked_card_callback) {
  return ValueListenableBuilder(valueListenable: home_articles.items,
      builder: (context, articles, Widget? _child) {
        Widget child = ListView();
        if (articles.isNotEmpty) {
          // specific to unicon20.fr wordpress
          articles.removeWhere((article) => (article.date.isBefore(DateTime(2020, 12, 21))));
          articles.sort((a, b) => b.date.compareTo(a.date));
          child = ListView(children:
              articles.map((e) => build_card(e, (article) {
                if (article.read != 1) {
                  article.read = 1;
                  home_articles.update_item(article);
                }
                clicked_card_callback(article);
              })).toList());
        }
        var refresh_indicator = RefreshIndicator(
            onRefresh: home_articles.refresh, child: child);
        return refresh_indicator;
      });
}

/// Create a [Card] widget from an [Article]
/// Expand to a [TextPage]
Widget build_card(Article article, var action) {
  /*
  final img = article.img.isEmpty ? null
      : FadeInImage(
          placeholder: AssetImage('res/topLogo.png'),
          image: NetworkImage(article.img),
          alignment: Alignment.centerLeft,
          excludeFromSemantics: true
      );
      */

  String? cat_name = article.categories.get_first()?.name;
  final bool is_important = article.is_important();
  final Color article_normal_text_color = (article.read == 1 ? Colors.grey : Colors.black);
  final Color article_important_text_color = (article.read == 1 ? Colors.redAccent : Colors.red);
  final TextStyle article_text_style = TextStyle(
    color: is_important ? article_important_text_color : article_normal_text_color,
    fontWeight: is_important ? FontWeight.bold : FontWeight.normal
  );

  return Card(
      child: ListTile(
          title: Text(article.title, style: article_text_style),
          subtitle: cat_name != null ? Text(cat_name) : null,
          // leading: SizedBox(width: 80, height: 80, child: img),
          trailing: const Icon(Icons.arrow_forward_ios_outlined, color: Colors.grey),
          onTap: () { action(article); }
      ));
}
