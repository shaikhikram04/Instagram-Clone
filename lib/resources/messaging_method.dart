import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:instagram_clone/responsive/mobile_screen_layout.dart';
import 'package:instagram_clone/screens/messaging/message_screen.dart';

class MessagingMethod {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final _localNotification = FlutterLocalNotificationsPlugin();

  static Future<void> requestNotificationPermission() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      sound: true,
      provisional: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
    );
  }

  static void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen(
      (message) {
        if (Platform.isAndroid && context.mounted) {
          initLocalNotification(context, message);
        }
        showNotification(message);
      },
    );
  }

  static Future<void> initLocalNotification(
    BuildContext context,
    RemoteMessage message,
  ) async {
    var androidInitialization =
        const AndroidInitializationSettings('@mipmap/launcher_icon');
    var iosInitialization = const DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(
      android: androidInitialization,
      iOS: iosInitialization,
    );

    await _localNotification.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (payload) {
        handleMessage(context, message);
      },
    );
  }

  static void handleMessage(BuildContext context, RemoteMessage message) {
    if (message.data['type'] == 'notification') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => const MobileScreenLayout(initialPage: 3)),
        (route) => false,
      );
    } else if (message.data['type'] == 'message') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const MessageScreen(),
        ),
        (route) => route.isFirst,
      );
    }
  }

  static Future<void> showNotification(RemoteMessage message) async {
    final channel = AndroidNotificationChannel(
      Random.secure().nextInt(100000).toString(),
      'High Importance Notification',
      importance: Importance.max,
      showBadge: true,
      playSound: true,
    );

    final androidNotificationDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: 'Your channel description',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: true,
    );

    const darwinNotificationDetails = DarwinNotificationDetails();

    final notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    await Future.delayed(
      Duration.zero,
      () {
        _localNotification.show(
          123,
          message.notification!.title,
          message.notification!.body,
          notificationDetails,
        );
      },
    );
  }

  static Future<void> setupInteractMessage(BuildContext context) async {
    //* When app is terminated
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null && context.mounted) {
      handleMessage(context, initialMessage);
    }

    //* When app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        if (!context.mounted) return;
        handleMessage(context, message);
      },
    );
  }

  static Future<String?> get deviceToken async {
    return await _firebaseMessaging.getToken();
  }

  static Future<String> getAccessToken() async {
    final serviceAccountString = dotenv.get('service_account');

    Map<String, dynamic> serviceAccountJson = jsonDecode(serviceAccountString);

    List<String> scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    auth.AccessCredentials credencials =
        await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
      client,
    );

    client.close();

    return credencials.accessToken.data;
  }

  static Future<void> sendFcmMessage(
      String fcmToken, String title, String body, String type) async {
    final String serverKey = await getAccessToken();
    final String projectId = dotenv.get('project_id');
    final String fcmEndPoint =
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

    final Map<String, dynamic> message = {
      'message': {
        'token': fcmToken,
        'notification': {
          'body': body,
          'title': title,
        },
        'data': {
          'type': type,
        },
      }
    };

    await http.post(
      Uri.parse(fcmEndPoint),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey',
      },
      body: jsonEncode(message),
    );
  }
}
