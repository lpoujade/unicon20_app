import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notifications {
  final notifier = FlutterLocalNotificationsPlugin();

  Notifications();

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
  /// click handler
  Future<void> show(String title, String? text, String? payload) async {
    // TODO channel ?
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
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
