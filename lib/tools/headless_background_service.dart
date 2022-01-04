import 'package:background_fetch/background_fetch.dart';
import 'package:html_unescape/html_unescape.dart';
import 'dart:math';
import '../services/database.dart';
import '../data/article.dart';
import '../services/articles_list.dart';
import '../services/notifications.dart';

headless_task(HeadlessTask task) async {
  String taskId = task.taskId;
  // bool isTimeout = task.timeout;
  var notifier = Notifications();
  var db = DBInstance();
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
  db.close();
  BackgroundFetch.finish(taskId);
}
