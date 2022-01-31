import 'package:background_fetch/background_fetch.dart';
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
    if (article.read == 1) continue;
    notifier.show(
        article.title,
	null,
        '${article.id}',
        article.categories.get_first()?.slug,
        article.categories.get_first()?.name
        );
  }
  db.close();
  BackgroundFetch.finish(taskId);
}
