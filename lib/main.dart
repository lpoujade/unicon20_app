import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'config.dart' as config;
import 'data/article.dart';
import 'screen/calendar.dart';
import 'screen/competitions_infos.dart';
import 'screen/news.dart';
import 'screen/places.dart';
import 'services/articles_list.dart';
import 'services/database.dart';
import 'services/events_list.dart';
import 'services/competitions_list.dart';
import 'services/notifications.dart';
import 'tools/background_service.dart';
import 'tools/headless_background_service.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      home: UniconApp(),
      title: config.Strings.Title,
      theme: ThemeData(
          primaryColor: const Color(config.AppColors.green),
          fontFamily: 'Tahoma',
          appBarTheme: const AppBarTheme(color: Color(config.AppColors.green))),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales:
          config.supported_locales.map((l) => Locale(l[0], l[1]))));
  BackgroundFetch.registerHeadlessTask(headless_task);
}

class UniconApp extends StatefulWidget {
  final db = DBInstance();
  final notifier = Notifications();

  late final articles = ArticleList(db: db);
  late final events = EventList(db: db);
  late final competitions = CompetitionsList(db: db);

  UniconApp({Key? key}) : super(key: key) {
    events.fill();
    competitions.fill();
    initBackgroundService(background_task).then((e) => BackgroundFetch.start());
  }

  @override
  State<UniconApp> createState() => _UniconAppState();

  background_task() async {
    events.refresh();
    competitions.refresh();
    var new_articles = await articles.refresh();
    Article last = new_articles.first;
    if (new_articles.isNotEmpty) {
      notifier.show(last.title, '', '${last.id}',
          last.categories.get_first()?.slug, last.categories.get_first()?.name);
    }
  }
}

class _UniconAppState extends State<UniconApp>
    with SingleTickerProviderStateMixin {
  late final TabController _principalController =
      TabController(length: 4, vsync: this, initialIndex: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _principalController,
            children: [
              News(articles: widget.articles),
              Calendar(events: widget.events),
              Map(events: widget.events),
              CompetitionsInfo(competitions: widget.competitions)
            ]),
        bottomNavigationBar: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(4.0),
            child: TabBar(
                controller: _principalController,
                indicatorColor: const Color(config.AppColors.green),
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 2,
                labelColor: const Color(config.AppColors.green),
                unselectedLabelColor: const Color(config.AppColors.light_blue),
                tabs: const [
                  Tab(icon: Icon(Icons.home)),
                  Tab(icon: Icon(Icons.access_time)),
                  Tab(icon: Icon(Icons.place)),
                  Tab(icon: Icon(Icons.workspace_premium))
                ])));
  }

  @override
  void didChangeDependencies() async {
    if (widget.articles.lang == null) {
      await widget.articles.init_lang();
    }
    if (!mounted) return; // avoid using invalid context
    /*
      showDialog(context: context, builder: (context) =>
        SimpleDialog(title: const Text("Welcome !"),
          children: [Column(children: const [
            Text("If you got any suggestion or problem, please send a mail to unicon@lpo.host. Thank and see you in Grenoble !"),
            ElevatedButton(onPressed: null, child: Text('Close and see next time')),
            ElevatedButton(onPressed: null, child: Text('Close and never see again'))
          ]
          )
          ]
        )
      );
      */
    var cur_lang = Localizations.localeOf(context).languageCode;
    if (widget.articles.lang != cur_lang) {
      widget.articles.update_lang(cur_lang);
    } else if (widget.articles.list.isEmpty) {
      widget.articles.fill();
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _principalController.dispose();
    widget.db.close();
    super.dispose();
  }
}
