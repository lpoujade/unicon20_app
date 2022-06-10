import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/competition.dart';
import '../services/competitions_list.dart';

class CompCard extends StatelessWidget {
	final Competition competition;
	const CompCard({Key? key, required this.competition}) : super(key: key);

	@override
	Widget build(BuildContext context) {
    var competitor_or_startlist = competition.start_list_pdf ?? competition.competitor_list_pdf;
		var buttons = Row(children: [
				IconButton(icon: const Icon(Icons.format_list_numbered), onPressed: () async {
          if (competitor_or_startlist != null && competitor_or_startlist.isNotEmpty)
            await launchUrl(Uri.parse(competitor_or_startlist), mode: LaunchMode.externalApplication);
        }),
				IconButton(icon: const Icon(Icons.groups), onPressed: () { print('lol'); })
		]);
		return SizedBox(height: 20, child: Card(
				 margin: const EdgeInsets.all(4),
				 shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
				 child: ListTile(title: Text(competition.name), subtitle: buttons)
		));
	}
}

class CompetitionsInfo extends StatelessWidget {
	final CompetitionsList competitions;
	const CompetitionsInfo({Key? key, required this.competitions}) : super(key: key);

	@override
		Widget build(BuildContext context) {
			var consumer = Consumer<CompetitionsList>(builder: (context, CompetitionsList competitions, child) {
					competitions.list.sort((a, b) => (b.updated_at as DateTime).compareTo(a.updated_at));
					var refresh_indicator = RefreshIndicator(
						onRefresh: competitions.refresh,
						child: GridView(
							gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 200, childAspectRatio: 2.0),
							children: competitions.list.map((e) => CompCard(competition: e)).toList().cast<Widget>()
						)
					);
				return refresh_indicator;
			});
			return ChangeNotifierProvider.value(value: competitions, child: consumer);
		}
}
