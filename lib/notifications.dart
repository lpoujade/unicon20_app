import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Wrapper for [FlutterLocalNotificationsPlugin]
class Notifications {
  final notifier = FlutterLocalNotificationsPlugin();

  Notifications();

  /// Initialize plugin and attach callback to handle
  /// notifications tap
  initialize(Future<dynamic> Function(String?) notif_callback) async {
    // app_icon from android/app/src/main/res/drawable
    const initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    final initializationSettingsIOS = IOSInitializationSettings();
    final initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS);

    await notifier.initialize(initializationSettings,
        onSelectNotification: notif_callback);

  }

  /// Show notification
  /// payload is only used to pass data to the notification
  /// tap handler
  Future<void> show(String title, String? text, String? payload) async {
    // TODO channel ?
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'news', 'News', 'Notifications about new articles',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    const platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics);
    await notifier.show(
        0, title, text, platformChannelSpecifics,
        payload: payload);
  }

/* TODO ios
Future onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) async {
  // display a dialog with the notification details, tap ok to go to another page
  showDialog(
    context: null,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text(title.toString()),
      content: Text(body.toString()),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          child: Text('Ok'),
          onPressed: () async {
            Navigator.of(context, rootNavigator: true).pop();
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyApp(),
              ),
            );
          },
        )
      ],
    ),
  );
*/
}
