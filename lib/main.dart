import 'package:flutter/material.dart';
//import 'package:flutter/services.dart' show rootBundle;
//import 'package:flutter_html/flutter_html.dart';
import 'api.dart' as api;
import 'article.dart';
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

        title: 'Unicon 2020',
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
class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin{

  // Creating the two controllers.
  late final TabController _principalController = TabController(length: 3, vsync: this, initialIndex: 0);
  late final TabController _secondPageController = TabController(length: 4, vsync: this, initialIndex: 0);

  //Creating all the list that will contain future information to draw on screen.
  List<Widget> _listHome = <Widget>[];
  List<Widget> _listInfo = <Widget>[];

  // todo : change to get a real planning shape.
  final List<Widget> _listP1 = <Widget>[];
  final List<Widget> _listP2 = <Widget>[];
  final List<Widget> _listP3 = <Widget>[];
  final List<Widget> _listP4 = <Widget>[];


  /// The drawing of the first screen we draw.
  ///
  /// Taking care of the 3 different 'pages' in the page :
  ///   - The home one.
  ///   - The planning one.
  ///   - The info one ( todo : transform to map )
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // Taking care of the top bar.
        appBar: AppBar(
            title: Row(
                children: [
                  Image.asset('res/topLogo.png', width: 75, height: 75, ),
                  const Expanded( child: Center(child: Text('Unicon           ', style: TextStyle(color: Colors.white, fontSize: 30), ), ), ),
                ],
            ),
        ),

        // The body of the app.
        body: TabBarView(
            controller: _principalController,
            children: [

              /// The first 'page' of the biggest controller.
              Column(children: [Container(
                    color: Colors.blueAccent,
                    height: 55,
                    child: const Center(child: Text('News', style: TextStyle(color: Colors.white, fontSize: 30, ))),
                ),

                // Drawing the content of the first 'page'
                Expanded(child: ListView(
                        children: _listHome,
                )),
              ]),

            /// The second 'page' of the biggest controller. todo : change it to a real agenda
            Column(
              // Taking care of the top bar that uses the second controller.
                children: [ Container(
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
                          const Tab(text: 's'),
                        ],
                    )),

                // Drawing the content of the second 'page'
                Expanded(
                    child: TabBarView(
                            controller: _secondPageController,
                            children: [
                              ListView(children: _listP1),
                              ListView(children: _listP2),
                              ListView(children: _listP3),
                              ListView(children: _listP4),
                            ]
                        ),
                ),
                ],
                ),

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
                ),
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
                        indicatorSize :TabBarIndicatorSize.label,
                        indicatorWeight: 2,
                        indicatorPadding: const EdgeInsets.only(bottom: 4.0),
                        labelColor: Colors.green,
                        unselectedLabelColor: Colors.blue,
                        tabs: [
                          Tab(icon: Icon(Icons.home)),
                          Tab(icon: Icon(Icons.access_time)),
                          Tab(icon: Icon(Icons.info)),
                        ],
                    ),
                ),
                );
  }

  /// At the creation of the app.
  ///
  /// When the app launch, we get the information from the wordpress database 8
  /// or database 11.
  @override
  void initState() {

    // todo 2 setState ?
    getData(8).then((r) => setState(() {_listHome = r;}));
    getData(11).then((r) => setState(() {_listInfo = r;}));
    super.initState();
  }

  /// At the closing of the app, we destroy everything so it close clean.
  @override
  void dispose(){
    _secondPageController.dispose();
    _principalController.dispose();
    super.dispose();
  }

  ///Retrieval of wordpress information and put it in a list. todo : look like a same info appear multiple time.....
  Future<List<Widget>> getData(int category) async {

    // Variables initialisation.
    List<Widget> list = <Widget>[];
    final postlist = await get_articles();
    var savedArticlesId = [];

    // Taking care of every existing article we need to put on the app from the postlist.
    postlist.forEach((article) {
      savedArticlesId.add(article.id);
      list.add(
          Card(
              child: ListTile(
                  title: Text(article.title),
                  leading: const Icon(Icons.landscape),
                  trailing: const Icon(Icons.arrow_forward_ios_outlined),
                  onTap: (){
                    Navigator.push(
                        context,
                        /// If the user click, we send him on a new page name TextPage with its own characteristics.
                        MaterialPageRoute(builder: (context) => TextPage(title: article.title, paragraph: article.content))
                    );
                  },
                  // todo: change the text to a part of the paragraph one.
                  subtitle: const Text('...')
              )));
    });

    final newArticles = await api.getPostsList(category, savedArticlesId.join(','));

    // Taking care of every existing article we need to put on the app from the articles.
    newArticles.forEach((article) {
      save_article(article);
      list.add(
          Card(
              child: ListTile(
                  title: Text(article.title),
                  leading: const Icon(Icons.info),
                  trailing: const Icon(Icons.arrow_forward_ios_outlined),
                  onTap: (){
                    Navigator.push(
                        context,
                        /// If the user click, we send him on a new page name TextPage with its own characteristics.
                        MaterialPageRoute(builder: (context) => TextPage(title: article.title, paragraph: article.content))
                    );
                  },
                  // todo: change the text to a part of the paragraph one.
                  subtitle: const Text('...')
              )));
    });
    return list;
  }
}
/*
///
Map<int, Color> color ={
  50:const Color.fromRGBO(68,138,255, .1),
  100:const Color.fromRGBO(68,138,255, .2),
  200:const Color.fromRGBO(68,138,255, .3),
  300:const Color.fromRGBO(68,138,255, .4),
  400:const Color.fromRGBO(68,138,255, .5),
  500:const Color.fromRGBO(68,138,255, .6),
  600:const Color.fromRGBO(68,138,255, .7),
  700:const Color.fromRGBO(68,138,255, .8),
  800:const Color.fromRGBO(68,138,255, .9),
  900:const Color.fromRGBO(68,138,255, 1),};


// Page d'affichage du texte
class TextPage extends StatelessWidget{

  const TextPage({Key? key, required this.title, required this.paragraphe}) : super(key: key);
  final String title;
  final String paragraphe;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            primarySwatch: MaterialColor(0xff448aff, color),
        ),
        home: Scaffold(
            appBar: AppBar(
                title: Row(
                    children: [
                      TextButton(
                          onPressed: (){Navigator.pop(context);},
                          child: Icon(Icons.arrow_back, size: 25,color: Colors.white),
                      ),
                      Expanded(
                          child: Text(title),
                      ),
                    ],
                ),
            ),
            body: Container(
                padding: EdgeInsets.all(32),
                child: SingleChildScrollView(child: Text(paragraphe, style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)))
            ),
        ),
        );
  }
}*/
