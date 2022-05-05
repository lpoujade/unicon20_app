import 'package:flutter/material.dart';

import '../data/article.dart';
import '../services/articles_list.dart';

class CompetitionsInfo extends StatefulWidget {
	final ArticleList articles;
	const CompetitionsInfo({Key? key, required this.articles}) : super(key: key);

	@override
		State<CompetitionsInfo> createState() => _CompetitionsInfoState();
}

class _CompetitionsInfoState extends State<CompetitionsInfo> with TickerProviderStateMixin {
  @override
    Widget build(BuildContext context) {
			return Center(child: Text('hey you want the list ${widget.articles.list.length}'));
		}

  @override
    initState() {
      super.initState();
    }

	@override
		void didChangeDependencies() async { super.didChangeDependencies(); }

  @override
    void dispose() { super.dispose(); }

}
