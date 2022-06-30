/// Locations page definition

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    var coords_str = coords.toString();
    if (coords == null) continue;

    if (!places.keys.contains(coords_str))
      places[coords_str] = {
        'addr': addr,
        'coords': coords,
        'events': <Event>[],
        'colors': <dynamic>{}
      };

    places[coords_str]!['events'].add(event);
    places[coords_str]!['colors'].add(config.calendars[event.type]?['color']);
  }

  return places;
}

evlistMBanner(listenable, data, context) {
  List<Widget> content = [];
  data.sort((a, b) => (a.start as DateTime).compareTo(b.start));
  for (var ev in data)
    content
        .add(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(ev.title),
      Text(DateFormat.Md(Localizations.localeOf(context).languageCode)
          .format(ev.start))
    ]));

  var banner_height =
      content.length * 20.0 > MediaQuery.of(context).size.height / 1.5
          ? MediaQuery.of(context).size.height / 1.5
          : content.length * 20.0;
  return MaterialBanner(
    forceActionsBelow: true,
    content: SizedBox(
        height: banner_height,
        child: ListView(shrinkWrap: true, children: content)),
    actions: <Widget>[
      SizedBox(
          height: 15,
          child: IconButton(
              onPressed: ScaffoldMessenger.of(context).clearMaterialBanners,
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.minimize)))
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

  return u.U.MarkerLayer(markers, onTap: (latlng, data) {
    ScaffoldMessenger.of(context).clearMaterialBanners();
    ScaffoldMessenger.of(context)
        .showMaterialBanner(evlistMBanner(events, data, context));
  });
}

class Map extends StatelessWidget {
  final EventList events;
  const Map({Key? key, required this.events}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var consumer = Consumer<EventList>(builder: (context, events, child) {
      u.LatLng? map_center =
          u.LatLng(config.map_default_lat, config.map_default_lon);
      double? map_zoom = 11;
      double? map_rotation = 0;

      var map = u.U.OpenStreetMap(
          markers: build_marker_layer(context, events.list),
          disableRotation: true,
          center: map_center,
          rotation: map_rotation,
          zoom: map_zoom,
          onChanged: (center, zoom, w) {
            map_center = center;
            map_zoom = zoom;
            map_rotation = w;
          });

      return Stack(children: [
        map,
        Positioned(
            left: 10.0,
            bottom: 10.0,
            width: 150,
            child: CalendarFilter(events: events))
      ]);
    });
    return ChangeNotifierProvider.value(value: events, child: consumer);
  }
}
