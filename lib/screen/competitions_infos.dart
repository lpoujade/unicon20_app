import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/competitions_list.dart';

/*
class CompetitionsInfo extends StatefulWidget {
	final CompetitionsList competitions;
	const CompetitionsInfo({Key? key, required this.competitions}) : super(key: key);

	@override
		State<CompetitionsInfo> createState() => _CompetitionsInfoState();
}

class _CompetitionsInfoState extends State<CompetitionsInfo> with TickerProviderStateMixin {
  @override
    Widget build(BuildContext context) {
			return Center(child: Text('hey you want the list ${widget.competitions.list.length}'));
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
*/


class CompetitionsInfo extends StatelessWidget {
	final CompetitionsList competitions;
	const CompetitionsInfo({Key? key, required this.competitions}) : super(key: key);

	@override
		Widget build(BuildContext context) {
			var consumer = Consumer<CompetitionsList>(builder: (context, CompetitionsList competitions, child) {
					competitions.list.sort((a, b) => (b.updated_at as DateTime).compareTo(a.updated_at));
					var refresh_indicator = RefreshIndicator(
						onRefresh: competitions.refresh,
						child: ListView(children: competitions.list.map((e) => Text(e.name)).toList().cast<Widget>())
					);
				return refresh_indicator;
			});
			return ChangeNotifierProvider.value(value: competitions, child: consumer);
		}
}
