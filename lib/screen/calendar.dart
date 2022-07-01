/// Calendar page definition
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:unicon/ui/filters.dart';

import '../config.dart' as config;
import '../data/event.dart';
import '../services/events_list.dart';
import '../tools/utils.dart';

class Calendar extends StatelessWidget {
	final EventList events;
	const Calendar({Key? key, required this.events}) : super(key: key);

	@override
		Widget build(BuildContext context) {
			var consumer = Consumer<EventList>(builder: (context, events, child) {
        List<Event> fitted_events = [];
        var min_time = const HourMinute(hour: 12);
        List<DateTime> dates = [];
        for (Event e in events.list) {
          Event tmp = Event.from(e);
          tmp.start = fit_date_to_cal(e.start);
          tmp.end = fit_date_to_cal(e.end);
          var start_day = DateTime(tmp.start.year, tmp.start.month, tmp.start.day);
          var end_day = DateTime(tmp.end.year, tmp.end.month, tmp.end.day);
          if (!dates.contains(start_day)) dates.add(start_day);
          if (end_day != start_day && !dates.contains(end_day)) dates.add(end_day);

          fitted_events.add(tmp);

          var ev_start = HourMinute(hour: tmp.start.hour, minute: tmp.start.minute);
          if (min_time > ev_start) min_time = ev_start;
        }
        min_time = min_time.subtract(const HourMinute(minute: 30));
        dates.sort((a, b) => a.compareTo(b));

			var view_height = MediaQuery.of(context).size.height * .9;

			var zoom_controller = WeekViewController();

  		var wk = Stack(children: [Padding(padding: const EdgeInsets.only(top: 20), child: WeekView(
					userZoomable: false,
  		    dates: dates,
  		    minimumTime: min_time,
  		    hoursColumnStyle: HoursColumnStyle(
  		        width: 25,
  		        textAlignment: Alignment.centerRight,
  		        timeFormatter: (time) => ('${time.hour.toString()} ')
  		    ),
  		    dayBarStyleBuilder: (date) => DayBarStyle(dateFormatter: (int year, int month, int day) {
  		      var date = DateTime(year, month, day);
  		      var year_str = (year == config.event_year
  		          ? DateFormat.Md(Localizations.localeOf(context).languageCode).format(date)
  		          : DateFormat.yMd(Localizations.localeOf(context).languageCode).format(date));
  		      var str = '${DateFormat.EEEE(Localizations.localeOf(context).languageCode).format(date)} $year_str';
  		      return str;
  		    }),
			    dayViewStyleBuilder: (date) => DayViewStyle(hourRowHeight: view_height / (24 - min_time.hour)),
  		          events: fitted_events.map((e) => get_wkview_event(context, e)).toList(),
			    controller: zoom_controller
  		      )),
					Positioned(
						left: 10.0, bottom: 10.0, width: 150,
						child: CalendarFilter(events: events)
						)]);

			var refresh_indicator = RefreshIndicator(
				onRefresh: events.refresh, child: wk);
			return refresh_indicator;
			});
			return ChangeNotifierProvider.value(value: events, child: consumer);
		}
}

/// Create a [FlutterWeekViewEvent] from a [Event]
FlutterWeekViewEvent get_wkview_event(context, Event calendar_event) {
  return FlutterWeekViewEvent(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: config.calendars[calendar_event.type]?['color']),
      eventTextBuilder: (event, context, dayView, h, w) {
        List<Widget> elements = [
          Expanded(child: Center(
            child: AutoSizeText(event.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    minFontSize: 5,
                    wrapWords: false
            ),
          ))
        ];

        return Column(children: elements);
      },
      title: calendar_event.title,
      description: calendar_event.description ?? '',
      start: calendar_event.start,
      backgroundColor: config.calendars[calendar_event.type]?['color'],
      end: calendar_event.end,
      padding: const EdgeInsets.all(1),
      margin: const EdgeInsets.fromLTRB(1, 1, 1, 1),
      onTap: () { show_event_popup(calendar_event, context); }
  );
}

/// Create and open an [Alert] popup to show [Event] info
void show_event_popup(Event event, BuildContext context) {
  List<DialogButton> buttons = [];
  if (event.location != null && event.location != 'TBD' && event.location != '') { // TODO remove once fixed upstream
    buttons.add(
      DialogButton(
        color: Colors.transparent,
        onPressed: () async {
          var url = (RegExp(r"-?[0-9]{1,2}\.[0-9]{6}, ?-?[0-9]{1,2}\.[0-9]{6}").hasMatch(event.location!))
              ? Uri(scheme: 'geo', host: event.location).toString()
              : Uri(scheme: 'geo', host: '0,0', queryParameters: {'q': event.location}).toString();
          launch_url(url);
        },
        child: Row(
                 mainAxisAlignment: MainAxisAlignment.end,
                 crossAxisAlignment: CrossAxisAlignment.center,
                 children: [
                   SizedBox(height: 80, width: 200, child:
                     AutoSizeText(event.location?.replaceAll(',', '\n') ?? '', textAlign: TextAlign.right, minFontSize: 6)
                   ),
                   const Icon(Icons.location_pin)
                 ]
               )
      ));
  }

  var start_hour = DateFormat.Hm().format(event.start);
  var end_hour = DateFormat.Hm().format(event.end);

  List<Widget> alert_children = [
    Container(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
      child: Text("$start_hour -> $end_hour",
        style: const TextStyle(fontSize: 10)),
    )
  ];

  if (event.summary != null)
    alert_children.add(Text(event.summary!));

  if (event.description != null) {
    alert_children.add(
      Html(
        data: event.description?.replaceAll('\\n', '<br/>'),
        onLinkTap: (s, u1, u2, u3) { launch_url(s.toString()); },
        style: { 'a': Style(color: const Color(config.AppColors.dark_blue)) }
      )
    );
  }

  var calendar_color = config.calendars[event.type] != null ?
      config.calendars[event.type]!['color']
      : config.default_calendar_color;

  var alert = Alert(
    context: context,
    style: AlertStyle(
      isCloseButton: false,
      animationDuration: const Duration(milliseconds: 100),
      backgroundColor: calendar_color,
      alertBorder: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2))),
      buttonAreaPadding: const EdgeInsets.all(0)
    ),
    buttons: buttons,
    content: Column(crossAxisAlignment: CrossAxisAlignment.start, children: alert_children)
  );

  alert.show();
}
