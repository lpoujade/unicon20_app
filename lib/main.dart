import 'dart:developer';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

import 'article.dart';
import 'calendar_event.dart';
import 'db.dart' as db;
import 'notifications.dart';
import 'text_page.dart';
import 'ui_components.dart' as ui_components;
import 'config.dart' as config;

late final Database databaseInstance;

/// Launching of the programme.
main() async {
  WidgetsFlutterBinding.ensureInitialized();
  databaseInstance = await db.init_database();
  runApp(const MyApp());
}

/// First creating page of the application.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  /// The information of the first page we draw to screen.
  ///
  /// This create the main core of the application, here it create the mores basics information
  /// and call 'MyHomePage' class which contain all the others information.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // To get rid of the 'DEBUG' banner
      //debugShowCheckedModeBanner: false,

      title: config.Strings.Title,
      theme: ThemeData(
          primaryColor: const Color(config.AppColors.green),
          fontFamily: 'Tahoma',
          appBarTheme: const AppBarTheme(color: Color(config.AppColors.green))
          ),
      home: const MyHomePage(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('fr', 'FR'),
        Locale('de', 'DE'),
        Locale('ja', 'JP'),
        Locale('ko', 'KR'),
        Locale('es', 'ES'),
        Locale('it', 'IT')
      ]
    );
  }
}

/// The calling of the drawing of the first screen.
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// The drawing of the first screen.
///
/// This screen is composed of 2 controllers :
///   - The biggest one always use.
///   - The smallest one only effective when the biggest one is on the 2nd selection.
/// This screen takes the information on the 'WordPress' and draw them with the good format.
class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  // Creating the controller.
  late final TabController _principalController =
      TabController(length: 2, vsync: this, initialIndex: 0);

  final home_articles = ArticleList(db: databaseInstance);
  final events = EventList(db: databaseInstance);

  final notifier = Notifications();

  late String lang;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Taking care of the top bar.
      appBar: ui_components.appBar,

      // The body of the app.
      body: TabBarView(
          controller: _principalController,
          children: [
          ui_components.news_page(home_articles, notifier, openArticle),
          ui_components.calendar_page(events)
          ]
      ),

      /// Creating the bar at the bottom of the screen.
      ///
      /// This bare help navigation between the 3 principals 'pages' ans uses the
      /// principal controller.
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
        Article article = home_articles.articles.value
            .firstWhere((a) => a.id == id);
        openArticle(article);
      }
    });

    initBackgroundService().then((e) => BackgroundFetch.start());
  }

  @override
  void didChangeDependencies() async {
    if (home_articles.lang == null) await home_articles.init_lang();
    var cur_lang = Localizations.localeOf(context).languageCode;
    if (home_articles.lang != cur_lang) home_articles.updateLang(cur_lang);
    else if (home_articles.articles.value.isEmpty) home_articles.get_articles();
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
      var new_articles = await home_articles.refresh();
      await events.refresh();
      setState(() {
        if (new_articles.isNotEmpty) {
          var articles_titles = new_articles.map((a) {
            return a.title;
          });
          String payload =
              new_articles.length == 1 ? new_articles.first.id.toString() : '';
          notifier.show('Fresh informations available !',
              articles_titles.join(' | '), payload);
        }
      });
      BackgroundFetch.finish(taskId);
    }, (String taskId) async {
      // <-- Task timeout handler.
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
      home_articles.update_article(article);
    }
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    _principalController.index = 0;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                TextPage(article: article)));
  }
}
