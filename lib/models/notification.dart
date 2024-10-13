import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  follow, //* userId
  like, //* postId
  comment, //* postId
  newPost, //* postId
}

class Notification {
  Notification({
    required this.notificationId,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.referenceId,
    required this.seen,
  });

  final String notificationId;
  final NotificationType type;
  final String title;
  final String body;
  final Timestamp timestamp;
  final String referenceId;
  final bool seen;

  Map<String, dynamic> get toJson {
    return {
      'notificationId': notificationId,
      'type': type,
      'title': title,
      'body': body,
      'timestamp': timestamp,
      'seen': seen,
      'referenceId': referenceId,
    };
  }
}
