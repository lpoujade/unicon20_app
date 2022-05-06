# UNICON20 mobile application

Show articles from a Wordpress instance and events from one or more ICS calendar. Events are shown in a calendar view and those which have a valid location on a map, and you can filter by calendars or by days.

Documentation available [here](https://unicon20-app-doc.lpo.host)

To use a local wordpress, run `docker-compose up -d` and go to http://localhost:8080 and run the installation wizard.
Then run the app with a modified env var: `flutter run --dart-define=WP_HOST=http://localhost:8080`, or modify your IDE configuration

## Configuration
in `lib/config.dart`  

* `wordpress_host` is the Wordpress URL (can be overriden via env var `WP_HOST` to ease development)
* `AppColors` defines colors used for general components (eg top/bottom bars)
* `calendars` ICS URLs to fetch events; events will be shown using `color` (depending of calendar)
* `categories_weight` and `important_category_name` for emphasis on certains articles
* `map_default_lat`/`mai_default_lon` for default map center
* `geoservice` to define which geocoding service to use to place events on the map

## Calendar update

Handled with a server checking update on ICS URLs and serve only last update date. See `tools/caldav_diff.sh`

