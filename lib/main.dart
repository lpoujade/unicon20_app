import 'dart:developer';

import 'package:flutter/material.dart';
import 'text_page.dart';
import 'article.dart';
import 'names.dart';
import 'package:flutter_week_view/flutter_week_view.dart';

/// Launching of the programme.
void main() {
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
/// This screen takes the information on the 'WorldPress' and draw them with the good format.
class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  // Creating the controller.
  late final TabController _principalController =
      TabController(length: 2, vsync: this, initialIndex: 0);

  final home_articles = ArticleList();

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
                    builder: (context, articles, Widget? child) {
                      Widget child;
                      if (articles.length > 0) {
                        articles.sort((a, b) {
                          return b.date.compareTo(a.date);
                        });
                        child = ListView(children: articles.map((e) {
                          return build_card(e);
                        }).toList());
                      } else {
                        // while we don't have articles
                        // ListView here because we need a scroll view
                        // as RefreshIncator child
                        child = ListView(children: [CircularProgressIndicator()]);
                      }
                      return RefreshIndicator(
                          onRefresh: home_articles.refresh, child: child);
                    }))
          ]),

          /// The second 'page' of the biggest controller.
          Column(
            children: [
              Expanded(
                // Taking care of the top bar that uses the second controller.
                child: WeekView(
                  dates: [
                    DateTime(2022, 7, 24),
                    DateTime(2022, 7, 25),
                    DateTime(2022, 7, 26),
                    DateTime(2022, 7, 27),
                    DateTime(2022, 7, 28),
                    DateTime(2022, 7, 29),
                    DateTime(2022, 7, 30),
                  ],
                  userZoomable: true,
                  initialTime: DateTime.now(),
                  // todo : get all the event and ad theme to the agenda: events:[ FlutterWeekViewEvent( title: description: start : end:)]
                  events:[
                    FlutterWeekViewEvent(
                      title: "Road: 10K",
                      description: 'null',
                      start: DateTime(2022, 7, 27, 8),
                      end: DateTime(2022, 7, 27, 12),
                      backgroundColor: Colors.green,
                    ),
                    FlutterWeekViewEvent(
                      title: "Hockey: Rink Build",
                      description: 'null',
                      start: DateTime(2022, 7, 27, 9),
                      end: DateTime(2022, 7, 27, 11),
                      backgroundColor: Colors.red,
                    ),
                    FlutterWeekViewEvent(
                      title: "Jumps: Track Hight & Long",
                      description: 'null',
                      start: DateTime(2022, 7, 27, 10),
                      end: DateTime(2022, 7, 27, 17),
                      backgroundColor: Colors.blue,
                    ),
                    FlutterWeekViewEvent(
                      title: "Trials: Build",
                      description: 'null',
                      start: DateTime(2022, 7, 27, 10),
                      end: DateTime(2022, 7, 27, 20),
                      backgroundColor: Colors.grey,
                    ),
                    FlutterWeekViewEvent(
                      title: "Hockay: A",
                      description: 'null',
                      start: DateTime(2022, 7, 27, 12, 30),
                      end: DateTime(2022, 7, 27, 22),
                      backgroundColor: Colors.orange,
                    ),
                    FlutterWeekViewEvent(
                      title: "Workshop: Children Meeting",
                      description: 'null',
                      start: DateTime(2022, 7, 27, 13),
                      end: DateTime(2022, 7, 27, 15),
                      backgroundColor: Colors.purple,
                    ),
                  ],
                ),
              ),
            ],
          ),

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
          tabs: [
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
  }

  /// At the closing of the app, we destroy everything so it close clean.
  @override
  void dispose() {
    _principalController.dispose();
    super.dispose();
  }

  /// Create a [Card] widget from an [Article]
  /// Expand to a [TextPage]
  Widget build_card(Article article) {
    var text_page = TextPage(title: article.title, paragraph: article.content);
    final sub_len = article.content.length > 30 ? 30 : article.content.length;
    return Card(
        child: ListTile(
            title: Text(article.title,
                style: const TextStyle(fontFamily: 'LinLiber')),
            subtitle: Text(article.content.substring(0, sub_len),
                style: TextStyle(fontFamily: 'LinLiber')),
            leading: Icon(Icons.landscape),
            trailing: Icon(Icons.arrow_forward_ios_outlined,
                color: article.important ? Colors.red : Colors.grey),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => text_page));
            }));
  }
}
