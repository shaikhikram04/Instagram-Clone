import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String text;
  final DateTime date;
  final int likes;
  final String username;
  final String userImage;

  const Comment({
    required this.date,
    required this.id,
    required this.likes,
    required this.text,
    required this.userImage,
    required this.username,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'date': date,
        'likes': likes,
        'username': username,
        'userimage': userImage,
      };

  static Comment fromSnap(DocumentSnapshot<Map<String, dynamic>> snap) {
    return Comment(
      date: snap['date'],
      id: snap['id'],
      likes: snap['likes'],
      text: snap['text'],
      userImage: snap['userImage'],
      username: snap['username'],
    );
  }
}
