import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/competition.dart';
import '../services/competitions_list.dart';
import '../services/results_list.dart';

class ResultsDialog extends StatelessWidget {
	final ResultsList results;
	const ResultsDialog({Key? key, required this.results}) : super(key: key);

  @override
  build(context) {
    List<Widget> children = [];
    for (var res in results.list) {
      children.add(Center(child: ElevatedButton(child: Text(res.name), onPressed: () async => {
            await launchUrl(Uri.parse(res.pdf), mode: LaunchMode.externalApplication)
      })));
    }

    return SimpleDialog(
        title: const Text('Available results'),
        children: children
      );
  }
}

class CompCard extends StatelessWidget {
	final Competition competition;
	const CompCard({Key? key, required this.competition}) : super(key: key);

	@override
	Widget build(BuildContext context) {
    var competitor_or_startlist = competition.start_list_pdf ?? competition.competitor_list_pdf;
    List<Widget> buttons = [];

    if (competitor_or_startlist != null && competitor_or_startlist != '')
				buttons.add(IconButton(icon: const Icon(Icons.groups), onPressed: () async {
            await launchUrl(Uri.parse(competitor_or_startlist), mode: LaunchMode.externalApplication);
        }));
    if (competition.results.list.isNotEmpty)
      buttons.add(
				IconButton(icon: const Icon(Icons.format_list_numbered), onPressed: () async {
          if (competition.results.list.length > 1) {
            showDialog(context: context, builder: (context) => ResultsDialog(results: competition.results));
          }
          else
            await launchUrl(Uri.parse(competition.results.list.first.pdf), mode: LaunchMode.externalApplication);
        }));
    var height = MediaQuery.of(context).size.height * .3;
		return SizedBox(height: height, child: GestureDetector(
        onTap: () => {
          if ((competitor_or_startlist == null || competitor_or_startlist == '')
            && competition.results.list.isEmpty)
            Fluttertoast.showToast(
              msg: "Data not yet available for this competition",
              toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 2, fontSize: 16.0
            )
        },
        child: Card(
				 margin: const EdgeInsets.all(4),
				 shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
				 child: ListTile(title: Text(competition.name), subtitle: Row(children: buttons))
		)));
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
