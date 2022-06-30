/// Headless background service task

import 'package:background_fetch/background_fetch.dart';
import '../services/competitions_list.dart';
import '../services/database.dart';
import '../data/article.dart';
import '../services/articles_list.dart';
import '../services/events_list.dart';
import '../services/notifications.dart';

headless_task(HeadlessTask task) async {
  String taskId = task.taskId;
  // bool isTimeout = task.timeout;
  var notifier = Notifications();
  var db = DBInstance();
  var article_list = ArticleList(db: db);
  var event_list = EventList(db: db);
  var competition_list = CompetitionsList(db: db);

  var evp = event_list.refresh();
  var comp_list = await competition_list.refresh();
  await article_list.fill();
  List<Article> new_articles = await article_list.refresh();

  Article last = new_articles.first;

  if (comp_list.isNotEmpty) {
    notifier.show(
        'Competitions updated', '', '', 'competitions', 'Competitions infos');
  }

  if (new_articles.isNotEmpty) {
    notifier.show(last.title, '', '${last.id}',
        last.categories.get_first()?.slug, last.categories.get_first()?.name);
  }
  await evp;
  db.close();
  BackgroundFetch.finish(taskId);
}
