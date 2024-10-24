import 'package:firebase_messaging/firebase_messaging.dart';

class MessagingMethod {
  static final _firebaseMessaging = FirebaseMessaging.instance;

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

  static Future<String?> get deviceToken async {
    return await _firebaseMessaging.getToken();
  }
}
