import 'dart:developer';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/cupertino.dart';

import 'article.dart';
import 'calendar_event.dart';
import 'db.dart' as db;
import 'names.dart';
import 'text_page.dart';
import 'notifications.dart';

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

      title: Strings.Title,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'aAnggota',
      ),
      home: const MyHomePage(),
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

  /// The drawing of the first screen we draw.
  ///
  /// Taking care of the 3 different 'pages' in the page :
  ///   - The home one.
  ///   - The planning one.
  ///   - not existing one ( todo : transform to map )
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Taking care of the top bar.
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'res/topLogo.png',
              width: 75,
              height: 75,
            ),
            const Expanded(
              child: Center(
                child: Text(
                  Strings.DrawTitle,
                  style: TextStyle(color: Colors.white, fontSize: 30),
                ),
              ),
            ),
          ],
        ),
      ),

      // The body of the app.
      body: TabBarView(
        controller: _principalController,
        children: [
          Column(children: [
            Container(
                color: Colors.blueAccent,
                height: 55,
                child: const Center(
                    child: Text('News',
                        style: TextStyle(color: Colors.white, fontSize: 30)))),
            // Drawing the content of the first 'page'
            Expanded(
                child: ValueListenableBuilder<List<Article>>(
                    valueListenable: home_articles.articles,
                    builder: (context, articles, Widget? unused_child) {
                      Widget child;
                      if (articles.isNotEmpty) {
                        articles.sort((a, b) {
                          return b.date.compareTo(a.date);
                        });
                        child = ListView(children: articles.map((e) {
                          return build_card(e);
                        }).toList());
                      } else {
                        // we need a scroll view as RefreshIncator child
                        child = ListView(children: const [CircularProgressIndicator()]);
                      }
                      return RefreshIndicator(
                          onRefresh: () async {
                            var new_articles = await home_articles.refresh();
                            if (new_articles.isNotEmpty) {
                              var articles_titles = new_articles.map((a) { return a.title; });
                              String payload = new_articles.length == 1 ? new_articles.first.id.toString() : '';
                              notifier.show('Fresh informations available !', articles_titles.join(' | '), payload);
                            }
                            }, child: child);
                          }))
                      ]),

          /// The second 'page' of the biggest controller.
          Column(
            children: [
              Expanded(
                  child: ValueListenableBuilder<List<CalendarEvent>>(
                      valueListenable: events.events,
                      builder: (context, events, Widget? unused_child) {
                        List<DateTime> dates = [];
                        events.forEach((e) {
                          var day = DateTime(e.start.year, e.start.month, e.start.day);
                          if (!dates.contains(day)) dates.add(day);
                        });
                        dates.sort((a, b) => a.compareTo(b));
                        // todo : add theme to the agenda
                        return WeekView(
                            dates: dates,
                            userZoomable: true,
                            initialTime: DateTime.now(),
                            minimumTime: HourMinute(hour: 7, minute: 30),
                            events: events.map((e) {
                              return FlutterWeekViewEvent(
                                  title: e.title,
                                  description: e.description,
                                  start: e.start,
                                  end: e.end,
                                  onTap: () {
                                    // todo event page/popup
                                    print("${e.title} ${e.start} ${e.location}");
                                  }
                              );
                            }).toList()
                        );
                      }
                  )
              )
            ]
          )

          /*
                /// The third 'page' of the biggest controller. todo : change it to map
                Column(children: [
                  // Taking care of the top bar that uses the second controller.
                    Container(
                        color: Colors.blueAccent,
                        height: 55,
                        child: const Center(child: Text('Information', style: TextStyle(color: Colors.white, fontSize: 20))),
                    ),

                    // Drawing the content of the third 'page'
                    Expanded(child: ListView( children: _listInfo )),
                ],
                ),*/
        ],
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
          indicatorColor: Colors.green,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorWeight: 2,
          indicatorPadding: const EdgeInsets.only(bottom: 4.0),
          labelColor: Colors.green,
          unselectedLabelColor: Colors.blue,
          tabs: const [
            Tab(icon: Icon(Icons.home)),
            Tab(icon: Icon(Icons.access_time)),
            //Tab(icon: Icon(Icons.info)),
          ],
        ),
      ),
    );
  }

  /// At the creation of the app.
  @override
  void initState() {
    super.initState();

    log('init state');
    home_articles.get_articles();
    events.get_events();
    notifier.initialize((e) async {
      if (e != null && e.isNotEmpty) {
        Article article = home_articles.articles.value.firstWhere((a) => a.id == int.parse(e));
        build_text_page(article, navigate: true);
      }
    });

    initBackgroundService().then((e) => BackgroundFetch.start());
  }

  /// Initialize the background service used to fetch new event/posts
  /// and show notifications
  Future<void> initBackgroundService() async {
    int status = await BackgroundFetch.configure(BackgroundFetchConfig(
        minimumFetchInterval: 15, stopOnTerminate: false, startOnBoot: true,
        enableHeadless: true, requiresBatteryNotLow: true, requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false, requiredNetworkType: NetworkType.UNMETERED
    ), (String taskId) async {
      log("background fetch fired");
      var new_articles = await home_articles.refresh();
      await events.refresh(); 
      setState(() {
        if (new_articles.isNotEmpty) {
          var articles_titles = new_articles.map((a) {
            return a.title;
          });
          String payload = new_articles.length == 1 ? new_articles.first.id.toString() : '';
          notifier.show('Fresh informations available !', articles_titles.join(' | '), payload);
        }
      });
      BackgroundFetch.finish(taskId);
    }, (String taskId) async {  // <-- Task timeout handler.
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

  openArticle(Article article, TextPage textPage) {
    article.read = true;
    home_articles.update_article(article);
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    _principalController.index = 0;
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => textPage));
  }

  /// Create a [Card] widget from an [Article]
  /// Expand to a [TextPage]
  Widget build_card(Article article) {
    var textPage = build_text_page(article);
    final sub_len = article.content.length > 30 ? 30 : article.content.length;
    return Card(
        child: ListTile(
            title: Text(article.title,
                style: TextStyle(fontFamily: 'LinLiber',
                    color: (article.read ? Colors.grey : Colors.black))),
            subtitle: Text(article.content.substring(0, sub_len),
                style: const TextStyle(fontFamily: 'LinLiber')),
            leading: const Icon(Icons.landscape),
            trailing: const Icon(Icons.arrow_forward_ios_outlined, color: Colors.grey),
                // color: article.important ? Colors.red : (article.read ? Colors.white : Colors.grey)),
            onTap: () { openArticle(article, textPage); }
            ));
  }

  /// Create a [TextPage] showing an [Article]
  /// and push it as [MaterialPageRoute] using [Navigator]
  /// if `navigate` is true
  TextPage build_text_page(Article article, {navigate = false}) {
    var textPage = TextPage(title: article.title, paragraph: article.content);
    if (navigate == true) { openArticle(article, textPage); }
    return textPage;
  }
}
