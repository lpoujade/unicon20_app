import 'package:flutter/material.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:html_unescape/html_unescape.dart';
import 'dart:math';

import 'services/articles_list.dart';
import 'services/database.dart';
import 'services/events_list.dart';
import 'data/article.dart';
import 'services/notifications.dart';
import 'ui/app_bar.dart';
import 'ui/text_page.dart';
import 'screen/calendar.dart';
import 'screen/news.dart';
import 'config.dart' as config;
import 'tools/background_service.dart';


class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  final db = DBInstance();
  late final notifier = Notifications();

  late final articles = ArticleList(db: db);
  late final events = EventList(db: db);

  @override
  State<MyHomePage> createState() => _MyHomePageState();

  background_task() async {
    var new_articles = await articles.refresh();
    for (var article in new_articles) {
      notifier.show(
          article.title,
          HtmlUnescape().convert(article.content.substring(0,
              min(100, article.content.length))),
          '${article.id}',
          article.categories.get_first()?.slug,
          article.categories.get_first()?.name
          );
    }
  }
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {

  late final TabController _principalController = TabController(length: 2, vsync: this, initialIndex: 0);
  late String lang;

  @override
    Widget build(BuildContext context) {
      return Scaffold(
          appBar: appBar,
          body: TabBarView(
            controller: _principalController,
            children: [
              news_page(widget.articles, openArticle),
              calendar_page(widget.events)
            ]
          ),
          bottomNavigationBar: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(4.0),
            child: TabBar(
              controller: _principalController,
              indicatorColor: const Color(config.AppColors.green),
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 2,
              indicatorPadding: const EdgeInsets.only(bottom: 4.0),
              labelColor: const Color(config.AppColors.green),
              unselectedLabelColor: const Color(config.AppColors.light_blue),
              tabs: const [
                Tab(icon: Icon(Icons.home)),
                Tab(icon: Icon(Icons.access_time))
              ]
              )
            )
          );
    }

  @override
    initState() {
      super.initState();
      widget.events.fill();
      initBackgroundService(widget.background_task)
        .then((e) => BackgroundFetch.start());
    }

  @override
    void didChangeDependencies() async {
      if (widget.articles.lang == null) {
        await widget.articles.init_lang();
      }
      var cur_lang = Localizations.localeOf(context).languageCode;
      if (widget.articles.lang != cur_lang) {
        widget.articles.update_lang(cur_lang);
      }
      else if (widget.articles.items.value.isEmpty) {
        widget.articles.fill();
      }
      super.didChangeDependencies();
    }

  /// At the closing of the app, we destroy everything so it close clean.
  /// (background service will still run)
  @override
    void dispose() {
      _principalController.dispose();
      super.dispose();
    }

  openArticle(Article article) {
    if (Navigator.canPop(context)) Navigator.pop(context);
    _principalController.index = 0;
    Navigator.push(context,
        MaterialPageRoute(builder: (context) =>
          TextPage(title: article.title, content: article.content, date: article.date)));
  }
}
