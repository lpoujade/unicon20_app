import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart' as config;

/// Function that create for every article a new page when the user click on it.
///
/// It does create a top bar and the text in the body of the app.
class TextPage extends StatelessWidget {
  const TextPage(
      {Key? key,
      required this.title,
      required this.content,
      required this.date})
      : super(key: key);

  final DateTime date;
  final String content;
  final String title;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            textTheme: const TextTheme(bodyText2: TextStyle(fontSize: 18))),
        home: Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(config.AppColors.green),
              title: Row(
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.arrow_back,
                          size: 25, color: Colors.white)),
                  Expanded(child: Text(title))
                ],
              ),
            ),
            body: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text(
                        DateFormat.yMd(
                                Localizations.localeOf(context).languageCode)
                            .format(date),
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 12))
                  ]),
                  Html(
                      data: content,
                      onLinkTap: (s, u1, u2, u3) => launchUrl(
                          Uri.parse(s.toString()),
                          mode: LaunchMode.externalApplication),
                      customRenders: {
                        imageMatcher():
                            CustomRender.widget(widget: (context, attributes) {
                          var img =
                              context.tree.element?.attributes['horizontal'];
                          return img != null
                              ? CachedNetworkImage(imageUrl: img)
                              : const Center(
                                  child: CircularProgressIndicator());
                        })
                      },
                      tagsList: Html.tags..addAll(['image']) // TODO ?
                      )
                ]))));
  }
}

CustomRenderMatcher imageMatcher() =>
    (context) => context.tree.element?.localName == 'image';
