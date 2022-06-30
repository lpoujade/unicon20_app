import 'package:provider/provider.dart';

import '../config.dart' as config;
import 'package:flutter/material.dart';

import '../services/events_list.dart';

class CalendarFilter extends StatefulWidget {
  final EventList events;
  const CalendarFilter({Key? key, required this.events}) : super(key: key);

  @override
  State<CalendarFilter> createState() => _CalendarFilterState();
}

class _CalendarFilterState extends State<CalendarFilter> {
/*
  static final _CalendarFilterState _instance = _CalendarFilterState._internal();

  factory _CalendarFilterState() {
		return _instance;
  }

  _CalendarFilterState._internal();
	*/

  static final cal_status = {};
  static final selected_types = [];

  @override
  Widget build(BuildContext context) {
    var consumer = Consumer<EventList>(builder: (context, events, child) {
      var calendars = widget.events.get_calendars();
      var children = <Widget>[];

      for (var cal in calendars) {
        if (!cal_status.keys.contains(cal)) cal_status[cal] = false;
        children.add(Container(
            color: config.calendars[cal]?['color'],
            child: CheckboxListTile(
                checkColor: Colors.white,
                value: cal_status[cal],
                onChanged: (b) {
                  cal_status[cal] = !cal_status[cal];
                  selected_types.clear();
                  for (var c in cal_status.keys) {
                    if (cal_status[c] == true) selected_types.add(c);
                  }
                  setState(() => widget.events.filter([], selected_types));
                },
                dense: true,
                subtitle: null,
                visualDensity:
                    const VisualDensity(horizontal: -4, vertical: -4),
                title: Text(cal, style: const TextStyle(height: 1)))));
      }
      return Container(
          color: Colors.black.withOpacity(.3),
          child: ExpansionTile(
              title:
                  const Text('caption', style: TextStyle(color: Colors.white)),
              children: children));
    });
    return ChangeNotifierProvider.value(value: widget.events, child: consumer);
  }
}
