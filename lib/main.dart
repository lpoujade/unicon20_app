import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'config.dart' as config;
import 'homepage.dart';
import 'tools/headless_background_service.dart';

// DBInstance db_instance;

/// Launching of the programme.
main() async {
  runApp(const UniconApp());
  BackgroundFetch.registerHeadlessTask(headless_task);
}

/// First creating page of the application.
class UniconApp extends StatelessWidget {
  const UniconApp({Key? key}) : super(key: key);

  /// The information of the first page we draw to screen.
  ///
  /// This create the main core of the application, here it create the mores basics information
  /// and call 'MyHomePage' class which contain all the others information.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      title: config.Strings.Title,
      theme: ThemeData(
          primaryColor: const Color(config.AppColors.green),
          fontFamily: 'Tahoma',
          appBarTheme: const AppBarTheme(color: Color(config.AppColors.green))
          ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: config.supported_locales.map((l) => Locale(l[0], l[1]))
    );
  }
}
