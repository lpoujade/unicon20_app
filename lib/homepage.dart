import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:html_unescape/html_unescape.dart';

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


class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  final db = DBInstance();
  final notifier = Notifications();

  late final articles = ArticleList(db: db);
  late final events = EventList(db: db);

  // initBackgroundService().then((e) => BackgroundFetch.start());

  @override
  State<MyHomePage> createState() => _MyHomePageState();

  background_task() async {
    print("i'm running in background & headless !");
    print("still allocated ? $articles");
    var new_articles = await articles.refresh();
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
        background_task();
        // setState ?
        BackgroundFetch.finish(taskId);
        }, (String taskId) async {
          log("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
          BackgroundFetch.finish(taskId);
        });
    BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  }

  void backgroundFetchHeadlessTask(HeadlessTask task) async {
    String taskId = task.taskId;
    bool isTimeout = task.timeout;
    if (isTimeout) {
      print("[BackgroundFetch] Headless task timed-out: $taskId");
      BackgroundFetch.finish(taskId);
      return;
    }
    background_task();
    print("headless background task fired");
    BackgroundFetch.finish(taskId);
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
      widget.events.get_events();
      // widget.initBackgroundService();
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
      else if (widget.articles.articles.value.isEmpty) {
        widget.articles.get_articles();
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
