import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMethod {
  final _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;

  //* signup user
  Future<String> signupUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    // required Uint8List file,
  }) async {
    String res = 'some error occurred';

    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          bio.isNotEmpty) {
        final userCred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        //* add user to firebase
        await _fireStore.collection('users').doc(userCred.user!.uid).set({
          'username': username,
          'uid': userCred.user!.uid,
          'email': email,
          'bio': bio,
          'followers': [],
          'following': [],
        });
        res = 'success';
      }
    } catch (err) {
      res = err.toString();
    }

    return res;
  }
}
