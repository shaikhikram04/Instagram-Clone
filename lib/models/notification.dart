import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  follow,
  like,
  comment,
  post,
  message,
}

class Notification {
  Notification({
    required this.notificationId,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.seen,
  });

  final String notificationId;
  final NotificationType type;
  final String title;
  final String body;
  final Timestamp timestamp;
  final bool seen;

  Map<String, dynamic> get toJson {
    return {
      'notificationId' : notificationId,
      'type' : type,
      'title' : title,
      'body' : body,
      'timestamp' : timestamp,
      'seen' : seen,
    };
  }
}
