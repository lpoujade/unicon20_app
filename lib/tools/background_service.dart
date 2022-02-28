/// Utility to configure background service task

import 'dart:developer';
import 'package:background_fetch/background_fetch.dart';

BackgroundFetchConfig config =  BackgroundFetchConfig(
    minimumFetchInterval: 15,
    stopOnTerminate: false,
    startOnBoot: true,
    enableHeadless: true,
    requiresBatteryNotLow: true,
    requiresCharging: false,
    requiresStorageNotLow: false,
    requiresDeviceIdle: false,
    requiredNetworkType: NetworkType.ANY
    );


/// Initialize the background service used to fetch new event/posts
/// and show notifications
Future<void> initBackgroundService(callback) async {
  print("configuring background_fetch");
  await BackgroundFetch.configure(
      config,
      (String taskId) async {
        log("background fetch fired");
        callback();
        BackgroundFetch.finish(taskId);
      },
      (String taskId) async {
        log("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
        BackgroundFetch.finish(taskId);
  });
}


