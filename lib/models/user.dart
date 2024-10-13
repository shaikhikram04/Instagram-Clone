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
  final List likedPosts;
  final List savedPosts;
  String? deviceToken;

  User({
    required this.username,
    required this.email,
    required this.uid,
    required this.bio,
    required this.photoUrl,
    required this.deviceToken,
    required this.followers,
    required this.following,
    required this.likedPosts,
    required this.savedPosts,
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
        'likedPosts': likedPosts,
        'savedPosts': savedPosts,
        'deviceToken': deviceToken,
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
      likedPosts: snap['likedPosts'],
      savedPosts: snap['savedPosts'],
      deviceToken: snap['deviceToken'],
    );
  }

  set setDeviceToken(String token) {
    deviceToken = token;
  }

  // User copyWith({
  //   String? username,
  //   String? email,
  //   String? uid,
  //   String? bio,
  //   String? photoUrl,
  //   List? followers,
  //   List? following,
  //   String? gender,
  //   List? likedPosts,
  //   List? savedPosts,
  // }) {
  //   return User(
  //     username: username ?? this.username,
  //     email: email ?? this.email,
  //     uid: uid ?? this.uid,
  //     bio: bio ?? this.bio,
  //     photoUrl: photoUrl ?? this.photoUrl,
  //     followers: followers ?? this.followers,
  //     following: following ?? this.following,
  //     gender: gender ?? this.gender,
  //     likedPosts: this.likedPosts,
  //     savedPosts: this.savedPosts,
  //   );
  // }
}
