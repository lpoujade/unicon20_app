import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:sqflite/sqflite.dart';

import 'services/articles_list.dart';
import 'services/events_list.dart';
import 'data/article.dart';
import 'tools/db.dart' as db;
import 'services/notifications.dart';
import 'ui/app_bar.dart';
import 'ui/text_page.dart';
import 'screen/calendar.dart';
import 'screen/news.dart';
import 'config.dart' as config;


/// The calling of the drawing of the first screen.
class MyHomePage extends StatefulWidget {
  final Database db;
  const MyHomePage({Key? key, required this.db}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState(database_instance: db);
}

/// The drawing of the first screen.
///
/// This screen is composed of 2 controllers :
///   - The biggest one always use.
///   - The smallest one only effective when the biggest one is on the 2nd selection.
/// This screen takes the information on the 'WordPress' and draw them with the good format.
class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late final TabController _principalController =
      TabController(length: 2, vsync: this, initialIndex: 0);

  final notifier = Notifications();
  final Database database_instance;

  late final articles;
  late final events;
  late String lang;

  _MyHomePageState({required this.database_instance}) {
      articles = ArticleList(db: database_instance);
      events = EventList(db: database_instance);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: TabBarView(
          controller: _principalController,
          children: [
            news_page(articles, openArticle),
            calendar_page(events)
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
          ],
        ),
      ),
    );
  }

  /// At the creation of the app.
  @override
  void initState() {
    super.initState();
      events.get_events();
      notifier.initialize((e) async {
        if (e != null && e.isNotEmpty) {
          int id = int.parse(e);
          Article article = articles.articles.value
              .firstWhere((a) => a.id == id);
          openArticle(article);
        }
      });

    initBackgroundService().then((e) => BackgroundFetch.start());
  }

  @override
  void didChangeDependencies() async {
    if (articles.lang == null) await articles.init_lang();
    var cur_lang = Localizations.localeOf(context).languageCode;
    if (articles.lang != cur_lang) articles.updateLang(cur_lang);
    else if (articles.articles.value.isEmpty) articles.get_articles();
    super.didChangeDependencies();
  }

  /// Initialize the background service used to fetch new event/posts
  /// and show notifications
  Future<void> initBackgroundService() async {
     await BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 15,
            stopOnTerminate: false,
            startOnBoot: true,
            enableHeadless: true,
            requiresBatteryNotLow: true,
            requiresCharging: false,
            requiresStorageNotLow: false,
            requiresDeviceIdle: false,
            requiredNetworkType: NetworkType.UNMETERED), (String taskId) async {
      log("background fetch fired");
      var new_articles = await articles.refresh();
      setState(() {
        if (new_articles.isNotEmpty) {
          var articles_titles = new_articles.map((a) => a.title);
          String payload = '';
          String text = '';
          if (new_articles.length > 1) {
            text = articles_titles.toList().sublist(1).join(config.notif_titles_separator);
            payload = '';
          } else if (new_articles.length == 1) {
            payload = new_articles.first.id.toString();
            text = HtmlUnescape().convert(new_articles.first.content.substring(0, 100));
          }
          notifier.show(new_articles.first.title, text, payload);
        }
      });
      BackgroundFetch.finish(taskId);
    }, (String taskId) async {
      log("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
      BackgroundFetch.finish(taskId);
    });
  }

  /// At the closing of the app, we destroy everything so it close clean.
  /// (background service will still run)
  @override
  void dispose() {
    _principalController.dispose();
    super.dispose();
  }

  openArticle(Article article) {
    if (!article.read) {
      article.read = true;
      articles.update_article(article);
    }
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    _principalController.index = 0;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                TextPage(title: article.title, content: article.content, date: article.date)));
  }
}
