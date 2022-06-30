import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

import '../data/competition.dart';
import '../services/competitions_list.dart';
import '../services/results_list.dart';

class PDFDialog extends StatelessWidget {
  final String pdf;
  final String name;
  const PDFDialog({Key? key, required this.pdf, required this.name})
      : super(key: key);

  @override
  build(context) {
    return Dialog(
        insetPadding: const EdgeInsets.all(1.0),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Text(name),
            ElevatedButton(
                onPressed: () => launchUrl(Uri.parse(pdf),
                    mode: LaunchMode.externalApplication),
                child: const Text('download'))
          ]),
          Expanded(
              child: const PDF(fitPolicy: FitPolicy.BOTH).cachedFromUrl(pdf,
                  placeholder: (progress) => Center(
                          child: Column(children: [
                        Text('$progress %'),
                        const CircularProgressIndicator.adaptive()
                      ])),
                  errorWidget: (error) =>
                      Center(child: Text(error.toString()))))
        ]));
  }
}

class ResultsDialog extends StatelessWidget {
  final ResultsList results;
  const ResultsDialog({Key? key, required this.results}) : super(key: key);

  @override
  build(context) {
    List<Widget> children = [];
    for (var res in results.list) {
      children.add(Center(
          child: ElevatedButton(
              child: Text(res.name),
              onPressed: () => {
                    showDialog(
                        context: context,
                        builder: (context) =>
                            PDFDialog(name: res.name, pdf: res.pdf))
                  })));
    }

    return SimpleDialog(
        title: const Text('Available results'), children: children);
  }
}

class CompCard extends StatelessWidget {
  final Competition competition;
  const CompCard({Key? key, required this.competition}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var competitor_or_startlist =
        competition.start_list_pdf ?? competition.competitor_list_pdf;
    List<Widget> buttons = [];

    if (competitor_or_startlist != null && competitor_or_startlist != '')
      buttons.add(IconButton(
          icon: const Icon(Icons.groups),
          onPressed: () async {
            showDialog(
                context: context,
                builder: (context) => PDFDialog(
                    name: competition.name, pdf: competitor_or_startlist));
          }));
    if (competition.results.list.isNotEmpty)
      buttons.add(IconButton(
          icon: const Icon(Icons.format_list_numbered),
          onPressed: () async {
            if (competition.results.list.length > 1)
              showDialog(
                  context: context,
                  builder: (context) =>
                      ResultsDialog(results: competition.results));
            else
              showDialog(
                  context: context,
                  builder: (context) => PDFDialog(
                      name: competition.name,
                      pdf: competition.results.list.first.pdf));
          }));
    return Padding(
        padding: const EdgeInsets.all(2),
        child: ListTile(
            title: Text(competition.name),
            tileColor: Colors.white,
            subtitle: Row(children: buttons),
            shape: RoundedRectangleBorder(
                side: const BorderSide(),
                borderRadius: BorderRadius.circular(5)),
            dense: true,
            onTap: () => {
                  if ((competitor_or_startlist == null ||
                          competitor_or_startlist == '') &&
                      competition.results.list.isEmpty)
                    Fluttertoast.showToast(
                        msg: "Data not yet available for this competition",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 2,
                        fontSize: 16.0)
                }));
  }
}

class CompetitionsInfo extends StatelessWidget {
  final CompetitionsList competitions;
  const CompetitionsInfo({Key? key, required this.competitions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('building competitions widget: $competitions');
    var consumer = Consumer<CompetitionsList>(
        builder: (context, CompetitionsList competitions, child) {
      List<Widget> children = [const Center(child: Text('...'))];
      if (competitions.list.isNotEmpty) {
        competitions.list
            .sort((a, b) => (a as Competition).name.compareTo(b.name));
        children = competitions.list
            .map((e) => CompCard(competition: e))
            .toList()
            .cast<Widget>();
      }
      var refresh_indicator = RefreshIndicator(
          onRefresh: competitions.refresh,
          child: GridView(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200, childAspectRatio: 2.0),
              children: children));
      return refresh_indicator;
    });
    return ChangeNotifierProvider.value(value: competitions, child: consumer);
  }
}
