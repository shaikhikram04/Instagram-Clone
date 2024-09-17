import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String username;
  final String uid;
  final String email;
  final String bio;
  final List followers;
  final List following;
  final String photoUrl;
  final String gender;

  User({
    required this.username,
    required this.email,
    required this.uid,
    required this.bio,
    required this.photoUrl,
    required this.followers,
    required this.following,
    this.gender = 'Prefer not to say',
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'uid': uid,
        'email': email,
        'bio': bio,
        'followers': followers,
        'following': following,
        'photoUrl': photoUrl,
        'gender': gender,
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
      following: snap['following'],
      gender: snap['gender'],
    );
  }

  User copyWith({
    String? username,
    String? email,
    String? uid,
    String? bio,
    String? photoUrl,
    List<String>? followers,
    List<String>? following,
    String? gender,
  }) {
    return User(
      username: username ?? this.username,
      email: email ?? this.email,
      uid: uid ?? this.uid,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      gender: gender ?? this.gender,
    );
  }
}
