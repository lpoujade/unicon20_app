/// Headless background service task

import 'package:background_fetch/background_fetch.dart';
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

  var evp = event_list.refresh();
  List<Article> new_articles = await article_list.refresh();

	var count = 0;
	Article last = article_list.items.value.first;

  for (var article in new_articles) {
		if (article.read == 1) continue;
		count++;
		if (article.get_last_update().isAfter(last.get_last_update()))
			last = article;
	}
	notifier.show(
			last.title,
			count > 0 ? 'and $count more' : null,
			'${last.id}',
			last.categories.get_first()?.slug,
			last.categories.get_first()?.name
			);
	await evp;
	db.close();
	BackgroundFetch.finish(taskId);
}
