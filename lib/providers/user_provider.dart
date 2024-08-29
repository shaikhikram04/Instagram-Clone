import 'package:flutter/foundation.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/resources/auth_method.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  final _authMethod = AuthMethod();

  User get getUser => _user!;

  Future<void> refreshUser() async {
    final user = await _authMethod.getUserDetail();
    _user = user;
    notifyListeners();
  }
}
