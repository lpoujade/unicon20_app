/// News page definition

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../data/article.dart';
import '../services/articles_list.dart';


/// News page (first app screen)
ValueListenableBuilder<List<Article>> news_page(ArticleList home_articles, var clicked_card_callback) {
  return ValueListenableBuilder(valueListenable: home_articles.items,
      builder: (context, articles, Widget? _child) {
        Widget child = ListView();
        if (articles.isNotEmpty) {
          articles.sort((a, b) => b.date.compareTo(a.date));
          child = ListView(children:
              articles.map((e) => build_card(e, context, (article) {
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
Widget build_card(Article article, context, var action) {
	var card_height = MediaQuery.of(context).size.height / 3.5;

  String? cat_name = article.categories.get_first()?.name;
  const TextStyle title_style = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
		fontSize: 20
  );
  var cat_style = article.is_important() ?
	const TextStyle(backgroundColor: Colors.red, color: Colors.white)
	: const TextStyle(color: Colors.white, backgroundColor: Colors.blue);

	return Card(
			margin: const EdgeInsets.only(bottom: 2),
			shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(60)),
			child: Container(
				height: card_height,
				decoration: BoxDecoration(
					color: Colors.black,
					image: DecorationImage(
						opacity: .5,
						fit: BoxFit.cover,
						image: CachedNetworkImageProvider(article.img),
						)
					),
				child: Center(child: ListTile(
					subtitle: Text(article.title, style: title_style),
					title: cat_name != null ? Text(cat_name, style: cat_style) : null,
          onTap: () { action(article); }
					))
				)
		);
}
