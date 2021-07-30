import 'package:flutter/material.dart';
import 'text_page.dart';
import 'api.dart' as api;
import 'article.dart';
import 'db.dart';
import 'dart:developer';

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

		log('init state');
		getData();
		super.initState();
	}

	/// At the closing of the app, we destroy everything so it close clean.
	@override
	void dispose(){
		_secondPageController.dispose();
		_principalController.dispose();
		super.dispose();
	}

	/// Get articles from database and from wordpress, update state accordingly
	getData() async {
		List<Widget> list = <Widget>[];
		final postlist = await get_articles();
		log("found articles: $postlist");
		var saved_articles_id = [];
		postlist.forEach((article) {
			saved_articles_id.add(article.id);
			list.add(
					Card(
							child: ListTile(
									title: Text(article.title),
									leading: Icon(Icons.landscape),
									trailing: Icon(Icons.arrow_forward_ios_outlined),
									onTap: (){
										Navigator.push(
												context,
												MaterialPageRoute(builder: (context) => TextPage(title: article.title, paragraph: article.content))
										);
									}, subtitle: Text('...')
							)));
		});
		setState(() { _listHome = list; });
		final last_sync_if_any = await get_last_sync_date();
		final new_articles = await api.getPostsList(since: last_sync_if_any);
		new_articles.forEach((article) {
			save_article(article);
			list.add(
					Card(
							child: ListTile(
									title: Text(article.title),
									leading: Icon(Icons.landscape),
									trailing: Icon(Icons.arrow_forward_ios_outlined),
									onTap: (){
										Navigator.push(
												context,
												MaterialPageRoute(builder: (context) => TextPage(title: article.title, paragraph: article.content))
										);
									}, subtitle: Text('...')
							)));
			setState((){_listHome = list;});
		});
	}
}
