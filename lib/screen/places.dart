/// Locations page definition

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:unicon/data/event.dart';
import 'package:unicon/services/events_list.dart';
import 'package:unicon/ui/filters.dart';
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
			content.add(Row(
				children: [Text(ev.title), Text(DateFormat.Md(Localizations.localeOf(context).languageCode).format(ev.start))],
				mainAxisAlignment: MainAxisAlignment.spaceBetween));

	var banner_height = content.length * 20.0 > MediaQuery.of(context).size.height/1.5
		 ? MediaQuery.of(context).size.height/1.5
		 : content.length  * 20.0;
	return MaterialBanner(
		forceActionsBelow: true,
			content: SizedBox(height: banner_height, child: ListView(children: content, shrinkWrap: true)),
			actions: <Widget>[
				SizedBox(height: 15, child: IconButton(
						onPressed: ScaffoldMessenger.of(context).clearMaterialBanners,
						padding: EdgeInsets.zero,
						icon: const Icon(Icons.minimize)
					)
				)
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

				Widget marker = Stack(children: [
						const Positioned(bottom: 0, width: 30, child: Icon(Icons.place)),
						Row(children: children)
				]);


				var coords = places[p]['coords'];
				markers.add(u.U.Marker(coords, data: places[p]['events'], widget: marker));
			}

			return u.U.MarkerLayer(
					markers,
					onTap: (latlng, data) {
						ScaffoldMessenger.of(context).clearMaterialBanners();
						ScaffoldMessenger.of(context).showMaterialBanner(evlistMBanner(events, data, context));
					}
			);
}

places_page(EventList evlist) {
	u.LatLng? _center = u.LatLng(config.map_default_lat, config.map_default_lon);
	double? _zoom = 11;
	double? _rotation = 0;
	var controller = u.MapController();

	var map = ValueListenableBuilder(
			valueListenable: evlist.items, child: const CircularProgressIndicator(),
			builder: (context, List<Event> events, _child) {
			return u.U.OpenStreetMap(disableRotation: true, controller: controller, center: _center, rotation: _rotation,
					zoom: _zoom, markers: build_marker_layer(context, events), onChanged: (center, zoom, w)
					{_center = center; _zoom = zoom; _rotation = w;});
			});


	return Stack(
			children: [map,
			Positioned(
				left: 10.0, bottom: 10.0, width: 150,
				child: get_filters(evlist, legend_only:true)),
			]);
}
