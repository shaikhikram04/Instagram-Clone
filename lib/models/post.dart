import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String description;
  final String uid;
  final String username;
  final String postId;
  final Timestamp datePublished;
  final String postUrl;
  final String profImage;
  final List likes;

  Post({
    required this.description,
    required this.uid,
    required this.username,
    required this.postId,
    required this.datePublished,
    required this.postUrl,
    required this.profImage,
    required this.likes,
  });

  Map<String, dynamic> toJson() => {
        'description': description,
        'uid': uid,
        'username': username,
        'postId': postId,
        'datePublished': datePublished,
        'postUrl': postUrl,
        'profImage': profImage,
        'likes': likes,
      };

  static Post fromSnap(DocumentSnapshot<Map<String, dynamic>> snap) {
    return Post(
      description: snap['description'],
      uid: snap['uid'],
      username: snap['username'],
      postId: snap['postId'],
      datePublished: snap['datePublished'],
      postUrl: snap['postUrl'],
      profImage: snap['profImage'],
      likes: snap['likes'],
    );
  }
}
