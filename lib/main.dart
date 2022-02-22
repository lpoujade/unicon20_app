import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'config.dart' as config;
import 'homepage.dart';
import 'tools/headless_background_service.dart';

main() async {
  runApp(const UniconApp());
  BackgroundFetch.registerHeadlessTask(headless_task);
}

class UniconApp extends StatelessWidget {
  const UniconApp({Key? key}) : super(key: key);

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
