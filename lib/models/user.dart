import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String username;
  final String uid;
  final String email;
  final String bio;
  final List followers;
  final List following;
  final String photoUrl;

  User({
    required this.username,
    required this.email,
    required this.uid,
    required this.bio,
    required this.photoUrl,
    required this.followers,
    required this.following,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'uid': uid,
        'email': email,
        'bio': bio,
        'followers': followers,
        'following': following,
        'photoUrl': photoUrl,
      };

  static User fromSeed(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    var snap = snapshot.data()!;

    return User(
        username: snap['username'],
        email: snap['email'],
        uid: snap['uid'],
        bio: snap['bio'],
        photoUrl: snap['photoUrl'],
        followers: snap['followers'],
        following: snap['following']);
  }
}
