import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationUtils {
  NotificationUtils._();

  factory NotificationUtils() => _instance;
  static final NotificationUtils _instance = NotificationUtils._();

  final AwesomeNotifications awesomeNotifications = AwesomeNotifications();
  static ReceivePort? receivePort;

  Future<void> initializeNotifications(BuildContext context) async {
    await awesomeNotifications.initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic Notifications',
          defaultColor: Colors.teal,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          channelDescription: 'Basic Instant Notification',
          channelGroupKey: 'basic_channel_group',
        ),
      ],
      debug: true,
    );

    // Verifica se as notificações estão permitidas
    await checkAndRequestNotificationPermissions(context);
  }

  Future<void> checkAndRequestNotificationPermissions(
      BuildContext context) async {
    if (!await awesomeNotifications.isNotificationAllowed()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Allow Notifications'),
          content: const Text('Our app would like to send you notifications'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Don\'t Allow',
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
            ),
            TextButton(
              onPressed: () async {
                await awesomeNotifications
                    .requestPermissionToSendNotifications();
                Navigator.pop(context);
              },
              child: const Text(
                'Allow',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> scheduleNotification() async {
    try {
      await awesomeNotifications.createNotification(
        schedule: NotificationCalendar(
          day: DateTime.now().day + 7,
          month: DateTime.now().month,
          year: DateTime.now().year,
          hour: DateTime.now().hour,
          minute: DateTime.now().minute,
        ),
        content: NotificationContent(
          id: -1,
          channelKey: 'basic_channel',
          title: 'Lembrete Semanal',
          body: "Hora de verificar seu lixo produzido!",
          notificationLayout: NotificationLayout.Default,
        ),
      );
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  // Outras funções de notificação podem ser adicionadas conforme necessário

  Future<void> startListeningNotificationEvents() async {
    awesomeNotifications.setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (receivedAction.actionType == ActionType.SilentAction ||
        receivedAction.actionType == ActionType.SilentBackgroundAction) {
      print('Silent action received: "${receivedAction.buttonKeyInput}"');
      await executeLongTaskInBackground();
    } else {
      // Implemente a lógica para ação recebida
    }
  }

  static Future<void> executeLongTaskInBackground() async {
    print("Starting long task in background");
    await Future.delayed(const Duration(seconds: 4));
    final url = Uri.parse("http://google.com");
    final re = await http.get(url);
    print(re.body);
    print("Long task done");
  }

  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    print("Notification created: ${receivedNotification}");
  }

  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    print("Notification displayed: ${receivedNotification}");
  }

  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    print("Dismiss action received: ${receivedAction}");
  }
}
