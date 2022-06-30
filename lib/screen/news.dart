/// News page definition

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../data/article.dart';
import '../services/articles_list.dart';
import '../ui/text_page.dart';

class ACard extends StatelessWidget {
	final Article article;
	const ACard({Key? key, required this.article}) : super(key: key);

	@override
	build(BuildContext context) {
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

			return GestureDetector(
					onTap: () {
						Navigator.push(context,
								MaterialPageRoute(builder: (context) =>
									TextPage(title: article.title, content: article.content, date: article.date)));
						},
				child: Card(
				 margin: const EdgeInsets.only(bottom: 2),
				 shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(60)),
				 child: Container(
					 height: card_height,
					 decoration: BoxDecoration(
						 color: Colors.black,
						 image: article.img.isEmpty ? null : DecorationImage(
							 opacity: .5,
							 fit: BoxFit.cover,
							 image: CachedNetworkImageProvider(article.img),
							 ),
						 ),
					 child: Center(child: ListTile(
							 subtitle: Text(article.title, style: title_style),
							 title: cat_name != null ? Text(cat_name, style: cat_style) : null,
							 ))
					 )
				 ));
	}
}

class News extends StatelessWidget {
	final ArticleList articles;
	const News({Key? key, required this.articles}) : super(key: key);

	@override
		Widget build(BuildContext context) {
      print('build articles widget');
			var consumer = Consumer<ArticleList>(builder: (context, articles, child) {
        if (articles.list.isNotEmpty) articles.list.sort((a, b) => (b.date as DateTime).compareTo(a.date));
					var refresh_indicator = RefreshIndicator(
						onRefresh: articles.refresh,
						child: ListView(children: articles.list.map((e) => ACard(article: e)).toList().cast<Widget>())
					);
				return refresh_indicator;
			});
			return ChangeNotifierProvider.value(value: articles, child: consumer);
		}
}
