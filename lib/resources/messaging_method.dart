import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class MessagingMethod {
  static final _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> requestNotificationPermission() async {
    final setting = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      sound: true,
      provisional: true,
    );
    if (kDebugMode) {
      print('');
      if (setting.authorizationStatus == AuthorizationStatus.authorized) {
        print('user granted permission');
      } else if (setting.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('user granted provisional permission');
      } else {
        print('user denied permission');
      }
      print('');
    }
  }

  static Future<String?> get deviceToken async {
    return await _firebaseMessaging.getToken();
  }
}
