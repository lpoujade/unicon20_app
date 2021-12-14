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
    const initializationSettingsIOS = IOSInitializationSettings();
    const initializationSettings = InitializationSettings(
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
}
