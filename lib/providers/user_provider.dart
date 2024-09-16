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
          ),
        );

  void setUser(User user) {
    state = user;
  }

  void updateGender(String gender) {
    state = state.copyWith(gender: gender);
  }
}

final userProvider =
    StateNotifierProvider<UserNotifier, User>((ref) => UserNotifier());
