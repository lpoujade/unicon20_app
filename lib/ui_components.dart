import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_week_view/flutter_week_view.dart';

import 'centered_circular_progress_indicator.dart';
import 'text_page.dart';
import 'notifications.dart';
import 'calendar_event.dart';
import 'article.dart';
import 'config.dart' as config;

/// Top bar
var appBar = AppBar(
        title: Row(
          children: [
            Image.asset(
              'res/topLogo.png',
              width: 75,
              height: 75,
            ),
            const Expanded(
              child: Center(
                child: Text(
                  config.Strings.DrawTitle,
                  style: TextStyle(color: Colors.white, fontSize: 30, fontFamily: 'aAnggota'),
                )
              )
            )
          ]
        )
      );

/// Return [Widget] for the news page
ValueListenableBuilder<List<Article>> news_page(ArticleList home_articles, Notifications notifier, var clicked_card) {
  return ValueListenableBuilder(valueListenable: home_articles.articles,
      builder: (context, articles, Widget? unused_child) {
        if (articles.isEmpty) {
          return const CenteredCircularProgressIndicator();
        }
        Widget child;
        articles.sort((a, b) {
          return b.date.compareTo(a.date);
        });
        child = ListView(children:
            articles.map((e) => build_card(e, clicked_card)).toList());
        return RefreshIndicator(
            onRefresh: () async {
              var new_articles = await home_articles.refresh();
              if (new_articles.isNotEmpty) {
                var articles_titles = new_articles.map((a) => a.title);
                String payload = new_articles.length == 1 ? new_articles.first.id.toString() : '';
                notifier.show('Fresh informations available !', articles_titles.join(' | '), payload);
              }
            }, child: child);
      });
}

/// Return [Widget] for calendar page
ValueListenableBuilder<List<CalendarEvent>> calendar_page(EventList events, BuildContext context) {
  return ValueListenableBuilder<List<CalendarEvent>>(valueListenable: events.events,
      builder: (context, events, Widget? unused_child) {
        if (events.isEmpty) {
          return const CenteredCircularProgressIndicator();
        }
        List<DateTime> dates = [];
        for (var e in events) {
          var day = DateTime(e.start.year, e.start.month, e.start.day);
          if (!dates.contains(day)) dates.add(day);
        }
        dates.sort((a, b) => a.compareTo(b));
        var wk = WeekView(
            dates: dates,
            initialTime: DateTime.now(),
            minimumTime: const HourMinute(hour: 5, minute: 30),
            events: events.map((e) => FlutterWeekViewEvent(
                    title: e.title,
                    description: e.description,
                    start: e.start,
                    backgroundColor: config.calendars[e.type]?['color'],
                    end: e.end,
                    padding: const EdgeInsets.all(1),
                    onTap: () { show_event_popup(e, context); }
            )).toList()
        );
        wk.controller.changeZoomFactor(.4);
        return wk;
      }
  );
}
        

/// Create and open an [Alert] popup to show [CalendarEvent] info
void show_event_popup(CalendarEvent event, BuildContext context) {
  var buttons = [
    DialogButton(child: const Text("add_to_agenda", style: TextStyle(fontSize: 15)),
        onPressed: () => Navigator.pop(context)
    )
  ];
  if (event.location.isNotEmpty) {
    buttons.add(
        DialogButton(child: const Text("go", style: TextStyle(fontSize: 15)),
            onPressed: () {
              // todo regex for coords
              var loc = event.location.replaceAll('\\', '');
              launch(Uri(scheme: 'geo', host: '0,0', queryParameters: {'q': loc}).toString());
            }
        ));
  }
  Alert(
      context: context,
      style: const AlertStyle(isCloseButton: false),
      buttons: buttons,
      // todo handle overflow
      content: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(event.title),
              Text("${event.start.hour}:${event.start.minute} -> ${event.end.hour}:${event.end.minute}",
                  style: const TextStyle(fontSize: 10))
            ]),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(event.type, style: const TextStyle(fontSize: 10)),
              Text(event.location, style: const TextStyle(fontSize: 10))
            ]),
        Html(data: event.description)
      ])
  ).show();
}

/// Create a [Card] widget from an [Article]
/// Expand to a [TextPage]
Widget build_card(Article article, var action) {
  var textPage = TextPage(title: article.title, paragraph: article.content);
  final img = (article.img.isEmpty ? const Icon(Icons.landscape) : Image.network(article.img));
  return Card(
      child: ListTile(
          title: Text(article.title,
              style: TextStyle(fontFamily: 'LinLiber',
                  color: (article.read ? Colors.grey : Colors.black))),
          leading: img,
          trailing: const Icon(Icons.arrow_forward_ios_outlined, color: Colors.grey),
          onTap: () { action(article); }
      ));
}
