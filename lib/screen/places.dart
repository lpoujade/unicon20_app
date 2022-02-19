/// Locations page definition

import 'package:flutter/material.dart';
import 'package:unicon/data/event.dart';
import 'package:unicon/services/events_list.dart';
import 'package:universe/universe.dart';
import '../config.dart' as config;

get_places(events) {
	var places = {};

	for (Event event in events) {
		var addr = event.location;
		var coords = event.coords;
		if (coords == null)
			continue;

		if (!places.keys.contains(addr))
			places[addr] =  {'coords': coords, 'events': <Event>[], 'colors': Set()};

		places[addr]?['events'].add(event);
		places[addr]?['colors'].add(config.calendars[event.type]?['color']);
	}

	return places;
}

evlistMBanner(listenable, data, context) {
			return MaterialBanner(
								content: ValueListenableBuilder(
									valueListenable: listenable,
									builder: (context, List<Event> events, _child) {
										List<Widget> content = [];
										for (var ev in data)
											content.add(Text(ev.title));
										return ListView(children: content, shrinkWrap: true);
									}
								),
								actions: <Widget>[
								TextButton(onPressed: ScaffoldMessenger.of(context).clearMaterialBanners,
									child: const Icon(Icons.close)),
								],
				);
}

LatLng? _center = LatLng(45.1268, 5.7266);
double? _zoom = 11;
var controller = MapController();
double _currentSliderValue = 20;

ValueListenableBuilder<List<Event>> places_page(EventList evlist) {
	return ValueListenableBuilder(
			valueListenable: evlist.items,
			builder: (context, List<Event> events, Widget? _child) {

			var places = get_places(events);
			var markers = [];
			for (var p in places.keys) {

				var c_width = 30 / places[p]['colors'].length;
				List<Widget> children = [];
				for (var color in places[p]['colors']) {
					children.add(Container(width: c_width, color: color));
				}


				var coords = places[p]['coords'];
				markers.add(U.Marker(coords, data: places[p]['events'], widget: 
					SizedBox(height: 30, width: 30, child: ClipRRect(child: Row(children: children)))));
			}

			var marker_layer = U.MarkerLayer(
					markers,
					onTap: (latlng, data) {
						ScaffoldMessenger.of(context).clearMaterialBanners();
						ScaffoldMessenger.of(context).showMaterialBanner(evlistMBanner(evlist.items, data, context));
					}
			);

			return Stack(
				children: [ValueListenableBuilder(
					valueListenable: evlist.items,
					builder: (context, List<Event> events, _child) {
					return U.OpenStreetMap(controller: controller, center: _center,
							zoom: _zoom, markers: marker_layer, onChanged: (center, zoom, w)
							{_center = center; _zoom = zoom; }); // TODO debounce
					}),
          Positioned(
            left: 20.0, bottom: 10,
            child: Slider(
   				   value: _currentSliderValue,
						 divisions: 5,
   				   max: 100,
   				   label: _currentSliderValue.round().toString(),
   				   onChanged: (double value) { _currentSliderValue = value; },
   				 )
          ),
					]);
					}
			);
			}
