# UNICON20 mobile application

Show articles from a (configurable) Wordpress instance and events from one or more ICS calendar.

Documentation available [here](https://unicon20-app-doc.lpo.host)

Read articles from [unicon20.fr](https://unicon20.fr) by default.  
To use a local wordpress, run `docker-compose up -d` (on first launch, go to http://localhost:8080 and run the installation wizard). Logs can be viewed with `docker-compose logs -f`  
Then run `flutter run --dart-define=WP_HOST=<http(s)://ip:port>`, or use your IDE settings to set the env var


## Configuration
for the moment in `lib/config.dart`  

* `AppColors` defines colors used for general components (eg top/bottom bars)
* `api_host` is the Wordpress URL (can be overriden via env var `WP_HOST` to ease development)
* `api_path` API path for Wordpress, may need to change between WP versions
* `calendars` ICS URLs to fetch events; events will be shown using `color` (depending of calendar)
* `notif_titles_separator` string used to separate titles in notifications (rarely used if articles comes one by one)
* `calendar_utc_offset` UTC offset of timezone where events take place
