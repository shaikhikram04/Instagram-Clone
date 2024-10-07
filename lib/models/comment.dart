import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String text;
  final Timestamp date;
  final List<String> likes;
  final String uid;
  final String username;
  final String profPicture;

  const Comment({
    required this.date,
    required this.id,
    required this.likes,
    required this.text,
    required this.profPicture,
    required this.username,
    required this.uid,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'date': date,
        'likes': likes,
        'username': username,
        'profPicture': profPicture,
      };
}
