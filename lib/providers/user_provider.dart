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

  Future<void> setUser(User user) async {
    state = user;
  }
}

final userProvider =
    StateNotifierProvider<UserNotifier, User>((ref) => UserNotifier());
