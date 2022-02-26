/// Locations page definition

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:unicon/data/event.dart';
import 'package:unicon/services/events_list.dart';
import 'package:universe/universe.dart' as u;
import '../config.dart' as config;

get_places(events) {
	var places = {};

	for (Event event in events) {
		var addr = event.location;
		var coords = event.coords;
		if (coords == null)
			continue;

		if (!places.keys.contains(addr))
			places[addr] =  {'coords': coords, 'events': <Event>[], 'colors': <dynamic>{}};

		places[addr]?['events'].add(event);
		places[addr]?['colors'].add(config.calendars[event.type]?['color']);
	}

	return places;
}

evlistMBanner(listenable, data, context) {
	List<Widget> content = [];
	for (var ev in data)
		content.add(Text(ev.title));

	return MaterialBanner(
			content: ListView(children: content, shrinkWrap: true),
			actions: <Widget>[
				TextButton(onPressed: ScaffoldMessenger.of(context).clearMaterialBanners,
				child: const Icon(Icons.close)),
			],
	);
}

build_marker_layer(context, events) {
			var places = get_places(events);
			var markers = [];
			for (var p in places.keys) {

				var c_width = 30 / places[p]['colors'].length;
				List<Widget> children = [];
				for (var color in places[p]['colors']) {
					children.add(Container(width: c_width, height: 30, color: color));
				}

				var coords = places[p]['coords'];
				markers.add(u.U.Marker(coords, data: places[p]['events'], widget: Row(children: children)));
			}

			return u.U.MarkerLayer(
					markers,
					onTap: (latlng, data) {
						ScaffoldMessenger.of(context).clearMaterialBanners();
						ScaffoldMessenger.of(context).showMaterialBanner(evlistMBanner(events, data, context));
					}
			);
}

var day_status = {};
build_day_filter_btns(events) {
return ValueListenableBuilder(
			valueListenable: events.items, child: const CircularProgressIndicator(),
			builder: (context, List<Event> events_list, _child) {
			var ev_days = events.get_day_extent();
			var children = <Widget>[];

			for (DateTime d in ev_days) {
				var timestamp = d.millisecondsSinceEpoch;
				if (!day_status.keys.contains(timestamp))
						day_status[timestamp] = false;
				children.add(CheckboxListTile(checkColor: Colors.white, value: day_status[timestamp], onChanged: (b) {
							day_status[timestamp] = !day_status[timestamp];
							List<DateTime> selected = [];
							for (var e in day_status.keys) {
								if (day_status[e] == true)
									selected.add(DateTime.fromMillisecondsSinceEpoch(e));
							}
							events.filter_by_days(selected);
						},
						dense: true, visualDensity: const VisualDensity(vertical: -4),
						contentPadding: EdgeInsets.zero,
						title: Text(DateFormat.E(Localizations.localeOf(context).languageCode).format(d)
							+ ' ' + DateFormat.Md(Localizations.localeOf(context).languageCode).format(d),
							style: const TextStyle(height: 1, color: Colors.white))
			));
			}
			return Column(children: children);
			});
}

var cal_status = {};
build_calendar_filter(events) {
return ValueListenableBuilder(
			valueListenable: events.items, child: const CircularProgressIndicator(),
			builder: (context, List<Event> events_list, _child) {
			var calendars = events.get_calendars();
			var children = <Widget>[];

			for (var cal in calendars) {
				if (!cal_status.keys.contains(cal))
						cal_status[cal] = false;
				children.add(Container(color: config.calendars[cal]?['color'],
				child: CheckboxListTile(
					checkColor: Colors.white,
					value: cal_status[cal],
					onChanged: (b) {
							cal_status[cal] = !cal_status[cal];
							var selected = [];
							for (var c in cal_status.keys) {
								if (cal_status[c] == true)
									selected.add(c);
							}
							events.filter_by_types(selected);
						},
						dense: true, subtitle: null, visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
						title: Text(cal,
							style: const TextStyle(height: 1))
			)));
			}
			return Column(children: children);
			});
}

places_page(EventList evlist) {
	u.LatLng? _center = u.LatLng(config.map_default_lat, config.map_default_lon);
	double? _zoom = 11;
	double? _rotation = 0;
	var controller = u.MapController();

	var map = ValueListenableBuilder(
			valueListenable: evlist.items, child: const CircularProgressIndicator(),
			builder: (context, List<Event> events, _child) {
			return u.U.OpenStreetMap(controller: controller, center: _center, rotation: _rotation,
					zoom: _zoom, markers: build_marker_layer(context, events), onChanged: (center, zoom, w)
					{_center = center; _zoom = zoom; _rotation = w;});
			});

	var buttons = Container(
	color: Colors.black.withOpacity(.3),
	child: Column(children: [
				ExpansionTile(
					title: const Text('days', style: TextStyle(color: Colors.white)),
					children: [build_day_filter_btns(evlist)]
					),
				 ExpansionTile(
					title: const Text('legend', style: TextStyle(color: Colors.white)),
					children: [build_calendar_filter(evlist)]
					)
	]));

	return Stack(
			children: [map,
			Positioned(
				left: 10.0, bottom: 10.0, width: 150,
				child: buttons),
			]);
}
