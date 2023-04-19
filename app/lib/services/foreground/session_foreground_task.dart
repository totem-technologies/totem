import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

// The callback function should always be a top-level function.
@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(SessionTaskHandler());
}

class SessionTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    // You can use the getData function to get the data you saved.
    // right now the task doesn't need to do any processing other
    // than keep the session open
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    // Send data to the main isolate.
    // This doesn't have to do anything for now, but just sending
    // a timestamp to see the session is still alive for testing
    // purposes
    sendPort?.send(timestamp);
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    // You can use the clearAllData function to clear all the stored data.
    await FlutterForegroundTask.clearAllData();
  }

  @override
  void onButtonPressed(String id) {
    // Called when the notification button on the Android platform is pressed.
    debugPrint('onButtonPressed >> $id');
  }
}

class SessionForeground {
  static SessionForeground? _instance;

  static SessionForeground get instance {
    _instance ??= SessionForeground();
    return _instance!;
  }

  String? notificationTitle;
  String? notificationMessage;

  SessionForeground() {
    _initForegroundTask();
  }

  ReceivePort? _receivePort;

  Future<bool> startSessionTask() async {
    bool reqResult;
    if (await FlutterForegroundTask.isRunningService) {
      reqResult = await FlutterForegroundTask.restartService();
    } else {
      reqResult = await FlutterForegroundTask.startService(
        notificationTitle: notificationTitle ?? "",
        notificationText: notificationMessage ?? "",
        callback: startCallback,
      );
    }

    if (reqResult) {
      _receivePort = FlutterForegroundTask.receivePort;
      _receivePort?.listen((message) {
        if (message is DateTime) {
          debugPrint('receive timestamp: $message');
        } else if (message is int) {
          debugPrint('receive updateCount: $message');
        }
      });
      return true;
    }

    return false;
  }

  Future<bool> stopSessionTask() async {
    return await FlutterForegroundTask.stopService();
  }

  Future<void> _initForegroundTask() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'notification_channel_id',
        channelName: 'totem_session',
        channelDescription: 'totem foreground session',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
        buttons: [],
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        autoRunOnBoot: false,
        allowWifiLock: true,
      ),
    );
  }
}
