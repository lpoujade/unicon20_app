# UNICON20 mobile application

Documentation available at https://unicon20-app-doc.lpo.host

Read articles from unicon20.fr by default.  
To use a local wordpress, run `docker-compose up -d` (on first launch, go to http://localhost:8080 and run the installation wizard). Logs can be viewed with `docker-compose logs -f`  
Then run `flutter run --dart-define=API_HOST=<http(s)://ip:port>`, or use your IDE settings to set the env var

