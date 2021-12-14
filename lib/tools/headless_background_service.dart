import 'dart:developer';
import 'package:background_fetch/background_fetch.dart';
import '../services/database.dart';
import '../data/article.dart';
import '../services/articles_list.dart';
import '../services/notifications.dart';
// import '../services/events_list.dart';

headless_task(HeadlessTask task) async {
  String taskId = task.taskId;
  // bool isTimeout = task.timeout;
  var notifier = Notifications();
  notifier.show('task started', "task: $task", '');
  print("headless task start");
  log("headless task start");
  var db = DBInstance();
  var article_list = ArticleList(db: db);

  List<Article> new_articles = await article_list.refresh();
  if (new_articles.isNotEmpty) {
    notifier.show("hello", "content", '');
  }
  BackgroundFetch.finish(taskId);
}
