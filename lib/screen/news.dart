/// News page definition

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../data/article.dart';
import '../services/articles_list.dart';


/// News page (first app screen)
ValueListenableBuilder<List<Article>> news_page(ArticleList home_articles, var clicked_card_callback) {
  return ValueListenableBuilder(valueListenable: home_articles.items,
      builder: (context, articles, Widget? _child) {
        Widget child = Container(color: Colors.grey, child: ListView());
        if (articles.isNotEmpty) {
          articles.sort((a, b) => b.date.compareTo(a.date));
          child =  Container(color: Color(0xffd3d3d3), child: ListView(children:
              articles.map((e) => build_card(e, (article) {
                if (article.read != 1) {
                  article.read = 1;
                  home_articles.update_item(article);
                }
                clicked_card_callback(article);
              })).toList()));
        }
        var refresh_indicator = RefreshIndicator(
            onRefresh: home_articles.refresh, child: child);
        return refresh_indicator;
      });
}

/// Create a [Card] widget from an [Article]
/// Expand to a [TextPage]
Widget build_card(Article article, var action) {
  var img = article.img.isEmpty ? null
      : FadeInImage(
          placeholder: const AssetImage('res/topLogo.png'),
          image: CachedNetworkImageProvider(article.img),
          alignment: Alignment.centerLeft,
          excludeFromSemantics: true
      );

  String? cat_name = article.categories.get_first()?.name;
  final bool is_important = article.is_important();
  final Color article_normal_text_color = (article.read == 1 ? Colors.grey : Colors.black);
  final Color article_important_text_color = (article.read == 1 ? Colors.redAccent : Colors.red);
  final TextStyle article_text_style = TextStyle(
    color: is_important ? article_important_text_color : article_normal_text_color,
    fontWeight: is_important ? FontWeight.bold : FontWeight.normal,
  );

  return Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Card(
			shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
          title: Text(article.title, style: article_text_style),
          subtitle: cat_name != null ? Text(cat_name) : null,
          leading: ClipRRect(
              borderRadius: BorderRadius.circular(50.0),
              child: img
            ),
          trailing: const Icon(Icons.arrow_forward_ios_outlined, color: Colors.grey),
          onTap: () { action(article); }
        )
      ));
}
