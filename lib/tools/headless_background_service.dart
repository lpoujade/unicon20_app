import 'dart:developer' as dev;
import 'package:background_fetch/background_fetch.dart';
import 'package:html_unescape/html_unescape.dart';
import 'dart:math';
import '../services/database.dart';
import '../data/article.dart';
import '../services/articles_list.dart';
import '../services/notifications.dart';
// import '../services/events_list.dart';

headless_task(HeadlessTask task) async {
  String taskId = task.taskId;
  // bool isTimeout = task.timeout;
  var notifier = Notifications();
  var db = DBInstance();
  if (DBInstance.instance_count > 1) {
    print("[headless] db instances: ${DBInstance.instance_count}");
    dev.log("[headless] db instances: ${DBInstance.instance_count}");
    notifier.show('headless task instances > 1', 'count: ${DBInstance.instance_count}', '', 'debug', 'Debug');
  }
  var article_list = ArticleList(db: db);

  List<Article> new_articles = await article_list.refresh();

  for (var article in new_articles) {
    notifier.show(
        article.title,
          HtmlUnescape().convert(article.content.substring(0,
              min(100, article.content.length))),
        '${article.id}',
        article.categories.get_first()?.slug,
        article.categories.get_first()?.name
        );
  }

  BackgroundFetch.finish(taskId);
}
