import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_clone/models/user.dart' as model;
import 'package:instagram_clone/resources/storage_methods.dart';

class AuthMethod {
  final _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;

  //* signup user
  Future<String> signupUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    String res = 'some error occurred';

    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          username.isNotEmpty &&
          bio.isNotEmpty) {
        final userCred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        String photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePics', file, false);

        final user = model.User(
          username: username,
          email: email,
          uid: userCred.user!.uid,
          bio: bio,
          photoUrl: photoUrl,
        );

        //* add user to firebase
        await _fireStore
            .collection('users')
            .doc(userCred.user!.uid)
            .set(user.toJson());
        res = 'success';
      } else {
        res = 'Please enter all the fields';
      }
    } catch (err) {
      res = err.toString();
    }

    return res;
  }

  //* logging in user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = 'some error occurred';

    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);

        res = 'success';
      } else {
        res = 'Please enter all the field';
      }
    } catch (err) {
      res = err.toString();
    }

    return res;
  }

  Future<void> signOutUser() async {
    await _auth.signOut();
  }
}
