import 'dart:developer';

import 'package:flutter/material.dart';

import 'article.dart';
import 'names.dart';
import 'text_page.dart';

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
  // Creating the two controllers.
  late final TabController _principalController = TabController(length: 2, vsync: this, initialIndex: 0);
  late final TabController _secondPageController = TabController(length: 4, vsync: this, initialIndex: 0);

  late Future<List<Article>> articles;

  final home_articles = ArticleList();

  // todo : change to get a real planning shape.
  final List<Widget> _listP1 = <Widget>[];
  final List<Widget> _listP2 = <Widget>[];
  final List<Widget> _listP3 = <Widget>[];
  final List<Widget> _listP4 = <Widget>[];

  /// The drawing of the first screen we draw.
  ///
  /// Taking care of the 2 different 'pages' in the page :
  ///   - The home one.
  ///   - The planning one.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // Taking care of the top bar.
        appBar: AppBar(
            title: Row(children: [
          Image.asset('res/topLogo.png', width: 75, height: 75),
          const Expanded(
              child: Center(
                  child: Text(Strings.DrawTitle,
                  style: TextStyle(color: Colors.white, fontSize: 30))))
        ])),

        // The body of the app.
        body: TabBarView(controller: _principalController, children: [
          Column(children: [
            Container(
                color: Colors.blueAccent,
                height: 55,
                child: const Center(
                    child: Text('News',
                        style: TextStyle(color: Colors.white, fontSize: 30)))),
            // Drawing the content of the first 'page'
            Expanded(
                child: FutureBuilder<List<Article>>(
                    future: articles,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        log("failed to get articles: ${snapshot.error}");
                        return Text(
                            'failed to get articles: ${snapshot.error}');
                      } else if (snapshot.hasData) {
												if (!home_articles.up_to_date)
													articles = home_articles.more();
                        return ListView(
                            children: snapshot.data!.map((e) {
															return build_card(e);
														}).toList());
                      }
                      return const CircularProgressIndicator();
                    }))
          ]),

          /// The second 'page' of the biggest controller. todo : change it to a real agenda
          Column(children: [
            Container(
                padding: const EdgeInsets.all(4.0),
                color: Colors.blueAccent,
                child: TabBar(
                    controller: _secondPageController,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    tabs: [
                      const Tab(text: 's'),
                      const Tab(text: 'm'),
                      const Tab(text: 's'),
                      const Tab(text: 's')
                    ])),

            // Drawing the content of the second 'page'
            Expanded(
                child: TabBarView(controller: _secondPageController, children: [
              ListView(children: _listP1),
              ListView(children: _listP2),
              ListView(children: _listP3),
              ListView(children: _listP4)
            ]))
          ])
        ]),

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
                  Tab(icon: Icon(Icons.access_time))
                ])));
  }

  /// At the creation of the app.
  @override
  void initState() {
    super.initState();

    log('init state');
    articles = home_articles.get_articles();
  }

  /// Create a [Card] widget from an [Article]
  /// Expand to a [TextPage]
  Widget build_card(Article article) {
    var text_page = TextPage(title: article.title, paragraph: article.content);
    final sub_len = article.content.length > 30 ? 30 : article.content.length;
    return Card(
        child: ListTile(
            title: Text(article.title),
            subtitle: Text(article.content.substring(0, sub_len)),
            leading: Icon(Icons.landscape),
            trailing: Icon(Icons.arrow_forward_ios_outlined),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => text_page));
            }));
  }

  /// At the closing of the app, we destroy everything so it close clean.
  @override
  void dispose() {
    _secondPageController.dispose();
    _principalController.dispose();
    super.dispose();
  }
}
