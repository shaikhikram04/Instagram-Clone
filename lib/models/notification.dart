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
    required this.body,
    required this.timestamp,
    required this.referenceId,
    required this.profileImageUrl,
    required this.username,
  });

  final String notificationId;
  final NotificationType type;
  final String body;
  final Timestamp timestamp;
  final String referenceId;
  final String profileImageUrl;
  final String username;

  Map<String, dynamic> get toJson {
    return {
      'notificationId': notificationId,
      'type': type.name,
      'body': body,
      'timestamp': timestamp,
      'referenceId': referenceId,
      'profileImageUrl': profileImageUrl,
      'username': username,
    };
  }
}
