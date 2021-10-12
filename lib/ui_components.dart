import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';

import 'centered_circular_progress_indicator.dart';
import 'text_page.dart';
import 'notifications.dart';
import 'calendar_event.dart';
import 'article.dart';
import 'config.dart' as config;

/// Top bar
var appBar = AppBar(
        title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                  'res/topLogo.png',
                  width: 75,
                  height: 75,
                  color: Colors.black
              ),
              const Text(
                  config.Strings.DrawTitle,
                  style: TextStyle(color: Colors.white, fontSize: 30, fontFamily: 'Futura', fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 75)
            ]
        )
      );

/// News page (first app screen)
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
                notifier.show(new_articles.first.title, articles_titles.join(' | '), payload);
              }
            }, child: child);
      });
}


/// Calendar page
ValueListenableBuilder<List<CalendarEvent>> calendar_page(EventList events, BuildContext context) {
  return ValueListenableBuilder<List<CalendarEvent>>(valueListenable: events.events,
      builder: (context, events, Widget? unused_child) {
        if (events.isEmpty) {
          return const CenteredCircularProgressIndicator();
        }
        List<DateTime> dates = [];
        for (var e in events) {
          var day = DateTime(e.start.year, e.start.month, e.start.day);
          if (day.year != 2022) continue; // TODO remove once fixed on calendar
          if (!dates.contains(day)) dates.add(day);
        }
        dates.sort((a, b) => a.compareTo(b));
        var wk = WeekView(
            dates: dates,
            initialTime: DateTime.now(),
            minimumTime: const HourMinute(hour: 7, minute: 30),
            hoursColumnStyle: HoursColumnStyle(
                width: 25,
                textAlignment: Alignment.centerRight,
                timeFormatter: (time) => (time.hour.toString() + ' ')
            ),
            dayBarStyleBuilder: (date) => DayBarStyle(dateFormatter: (int year, int month, int day) {
              var date = DateTime(year, month, day);
              return DateFormat.EEEE(Localizations.localeOf(context).languageCode).format(date)
                  + ' ' + DateFormat.Md(Localizations.localeOf(context).languageCode).format(date);
            }),
            events: events.map((e) => FlutterWeekViewEvent(
                            eventTextBuilder: (event, context, dayView, h, w) {
                              List<Widget> elements = [
                                  Expanded(child: AutoSizeText(event.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                    minFontSize: 5,
                                    wrapWords: false
                                  ))
                              ];

                              return Column(children: elements);
                            },
                            title: e.title,
                            description: e.description,
                            start: e.start,
                            backgroundColor: config.calendars[e.type]?['color'],
                            end: e.end,
                            padding: const EdgeInsets.all(1),
                            margin: const EdgeInsets.fromLTRB(0, 1, 0, 0),
                            onTap: () { show_event_popup(e, context); }
                    )).toList()
        );
        wk.controller.changeZoomFactor(.45);
        return wk;
      }
  );
}
        

/// Create and open an [Alert] popup to show [CalendarEvent] info
void show_event_popup(CalendarEvent event, BuildContext context) {
  List<DialogButton> buttons = [];
  if (event.location.isNotEmpty && event.location != 'TBD') { // TODO remove once calendar fixed
    buttons.add(
        DialogButton(
            height: 80,
            width: 300,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    AutoSizeText(event.location.replaceAll(',', '\n'), textAlign: TextAlign.right),
                    const Icon(Icons.location_pin)
                ]),
            color: Colors.transparent,
            onPressed: () {
              // TODO regex for coords ?
              launch(Uri(scheme: 'geo', host: '0,0', queryParameters: {'q': event.location}).toString());
            }
    ));
  }
  var start_hour = DateFormat.Hm().format(event.start);
  var end_hour = DateFormat.Hm().format(event.end);
  Alert(
      context: context,
      style: AlertStyle(
          isCloseButton: false,
          animationDuration: const Duration(milliseconds: 100),
          backgroundColor: config.calendars[event.type]!['color'],
          alertBorder: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2))),
          buttonAreaPadding: const EdgeInsets.all(0)
          ),
      buttons: buttons,
      // TODO scrollview
      content: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                child: Text("$start_hour -> $end_hour",
                    style: const TextStyle(fontSize: 10)),
            ),
            Text(event.summary),
            Html(
                data: event.description.replaceAll('\\n', '<br />'),
                onLinkTap: (s, u1, u2, u3) { launch(s.toString()); },
                style: { 'a': Style(color: const Color(config.AppColors.darker_blue)) }
            )
          ])
  ).show();
}

/// Create a [Card] widget from an [Article]
/// Expand to a [TextPage]
Widget build_card(Article article, var action) {
  final img = (article.img.isEmpty ? null : Image.network(article.img));
  return Card(
      child: ListTile(
          title: Text(article.title,
              style: TextStyle(color: (article.read ? Colors.grey : Colors.black))),
          leading: img,
          trailing: const Icon(Icons.arrow_forward_ios_outlined, color: Colors.grey),
          onTap: () { action(article); }
      ));
}
