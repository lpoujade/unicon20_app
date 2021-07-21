import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
//import 'package:flutter_html/flutter_html.dart';
import 'api.dart' as api;

///////////////Programme principale
void main() {
  runApp(const MyApp());
}

//////////// Premiere classe appellé donc premiere page créé
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
    Widget build(BuildContext context) {
      return MaterialApp(   //// info standars à l'appli
          //debugShowCheckedModeBanner: false,
          title: 'unicons',
          theme: ThemeData(
            primarySwatch: Colors.green,
            ),
          home: MyHomePage(),   //appelle de la page principale
          );
    }
}

//////// classe de la page principale, renvoie sur une autre classe
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
    State<MyHomePage> createState() => _MyHomePageState();
}

////// vraie classe de la page principale
class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin{
  //// création et configuration des 2 controller
  late final TabController _principalController = TabController(length: 3, vsync: this, initialIndex: 0); // controle la barre de navigation du bas de l'écran
  late final TabController _pageController = TabController(length: 4, vsync: this, initialIndex: 0);  //controlle quand on est dans l'onglet planning

  //// création des listes qui contiendront toute les infos a affichés (récupéré pour le moment null part...)
  List<Widget> _listeHome = <Widget>[];
  List<Widget> _listeP1 = <Widget>[];
  List<Widget> _listeP2 = <Widget>[];
  List<Widget> _listeP3 = <Widget>[];
  List<Widget> _listeP4 = <Widget>[];
  List<Widget> _listeInfo = <Widget>[];


  //// création de la page principale
  @override
    Widget build(BuildContext context) {
      return Scaffold(
          // gestion de la barre en haut de l'écran:
          appBar: AppBar(
            title: Row(
              children: [
              Image.asset('res/tmp.jpg', width: 45, height: 45, ),  //l'image à gauche de la barre
              const Expanded(
                child: Center(child: Text('unicons')),  //le texte au centre de la barre
                ),
              ],
              ),
            ),

          //// affichage des pages principales
          body: TabBarView(
            controller: _principalController,
            //Seconde barre en haut de l'écran
            children: [Column(children: [Container(
                color: Colors.blueAccent,
                height: 55,
                child: const Center(child: Text('News', style: TextStyle(color: Colors.white, fontSize: 20)),),
                ),
              ////affichage de la liste d'element à afficher pour cet ecran
              Expanded(child: ListView(
                  children: _listeHome,
                  ),),
            ],),
            Column(
              ////Seconde barre en haut de l'ecran avec gestion de plusieurs fenetres
              children: [ Container(
                padding: EdgeInsets.all(4.0),
                color: Colors.blueAccent,
                child: TabBar(
                  controller: _pageController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: [
                  Tab(text: 's',),
                  Tab(text: 'm',),
                  Tab(text: 's',),
                  Tab(text: 's'),
                  ],
                  ),),
              ////affichage de la liste d'element à afficher pour ces ecrans
              Expanded(
                child: Container(
                  child: TabBarView(
                    controller: _pageController,
                    children: [
                    ListView(children: _listeP1,),
                    ListView(children: _listeP2,),
                    ListView(children: _listeP3,),
                    ListView(children: _listeP4,),
                    ]
                    ),
                  ),
                ),
              ],
              ),
              //Seconde barre en haut de l'écran
              Column(children: [
                  Container(
                    color: Colors.blueAccent,
                    height: 55,
                    child: const Center(child: Text('Information', style: TextStyle(color: Colors.white, fontSize: 20)),),
                    ),
                  ////affichage de la liste d'element à afficher pour cet ecran
                  Expanded(child: ListView( children: _listeInfo )),
              ],
              ),
              ],
              ),
              ////Barre du bas de l'ecran avec les 3 onglets principaux
              bottomNavigationBar: Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(4.0),
                  child: TabBar(
                    controller: _principalController,
                    indicatorColor: Colors.green,
                    indicatorSize :TabBarIndicatorSize.label,
                    indicatorWeight: 2,
                    indicatorPadding: EdgeInsets.only(bottom: 4.0),
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

  //lors de l'initialisation
  @override
    void initState() {

      //Recupération des données a afficher
      // _GenerateCards();
      // _listeHome = await getData(8);
      // _listeInfo = await getData(11);
      getData(8).then((r) => setState(() {_listeHome = r;}));
      getData(11).then((r) => setState(() {_listeInfo = r;}));
      super.initState();
    }

  // On ferme l'appli proprement
  @override
    void dispose(){
      _pageController.dispose();
      _principalController.dispose();
      super.dispose();
    }

Future<List<Widget>> getData(int category) async {
    List<Widget> list = <Widget>[];
    final postlist = await api.getPostsList(category);
    postlist.forEach((title, content) => {
        list.add(Card(
              child: ListTile(
                title: Text(title),
                leading: Icon(Icons.landscape),
                trailing: Icon(Icons.arrow_forward_ios_outlined),
                onTap: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TextPage(title: title, paragraphe: content))
                    );
                }, subtitle: Text('...'),
                )))
        });
    return list;
}


  /// Fonction de récupération des donnés ainsi que de la mise en forme de ces donnés dans une liste de widget
  Future<void> _GenerateCards() async {

    List<Widget> listeHometmp = <Widget>[];
    final postlist = await api.getPostsList(8);
    postlist.forEach((title, content) => {
        listeHometmp.add(Card(
              child: ListTile(
                title: Text(title),
                leading: Icon(Icons.landscape),
                trailing: Icon(Icons.arrow_forward_ios_outlined),
                onTap: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TextPage(title: title, paragraphe: content))
                    );
                }, subtitle: Text('...'),
                )))
        });

    switch(0){
      case 0:setState(() {_listeHome = listeHometmp;});break;
      case 1:setState(() {_listeP1 = listeHometmp;});break;
      case 2:setState(() {_listeP2 = listeHometmp;});break;
      case 3:setState(() {_listeP3 = listeHometmp;});break;
      case 4:setState(() {_listeP4 = listeHometmp;});break;
      case 5:setState(() {_listeInfo = listeHometmp;});break;
    }
  }
}


// Permet de faire du bleuaccent en une couleur materiel
Map<int, Color> color ={
50:Color.fromRGBO(68,138,255, .1),
   100:Color.fromRGBO(68,138,255, .2),
   200:Color.fromRGBO(68,138,255, .3),
   300:Color.fromRGBO(68,138,255, .4),
   400:Color.fromRGBO(68,138,255, .5),
   500:Color.fromRGBO(68,138,255, .6),
   600:Color.fromRGBO(68,138,255, .7),
   700:Color.fromRGBO(68,138,255, .8),
   800:Color.fromRGBO(68,138,255, .9),
   900:Color.fromRGBO(68,138,255, 1),};


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
                FlatButton(
                  onPressed: (){Navigator.pop(context);},
                  child: Icon(Icons.arrow_back, size: 25,color: Colors.white,),
                  ),
                Expanded(
                  child: Text(title),
                  ),
                ],
                ),
              ),
            body: Container(
              padding: EdgeInsets.all(32),
              child: SingleChildScrollView(child: Text(paragraphe, style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold,),))
              ),
            ),
          );
    }
}
