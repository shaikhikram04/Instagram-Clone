import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_clone/models/user.dart';

class UserNotifier extends StateNotifier<User> {
  UserNotifier()
      : super(
          User(
            username: '',
            email: '',
            uid: '',
            bio: '',
            photoUrl: '',
            followers: [],
            following: [],
            likedPosts: [],
            savedPosts: [],
            deviceToken: '',
            lastSeenNotificationId: '',
          ),
        );

  void setUser(User user) {
    state = user;
  }

  void updateField({
    String? username,
    String? email,
    String? uid,
    String? bio,
    String? photoUrl,
    List? followers,
    List? following,
    String? gender,
    List? likedPosts,
    List? savedPosts,
    String? deviceToken,
    String? lastSeenNotificationId,
  }) {
    state = User(
      username: username ?? state.username,
      email: email ?? state.email,
      uid: uid ?? state.uid,
      bio: bio ?? state.bio,
      photoUrl: photoUrl ?? state.photoUrl,
      followers: followers ?? state.followers,
      following: following ?? state.following,
      likedPosts: likedPosts ?? state.likedPosts,
      savedPosts: savedPosts ?? state.savedPosts,
      deviceToken: deviceToken ?? state.deviceToken,
      lastSeenNotificationId:
          lastSeenNotificationId ?? state.lastSeenNotificationId,
    );
  }
}

final userProvider =
    StateNotifierProvider<UserNotifier, User>((ref) => UserNotifier());
