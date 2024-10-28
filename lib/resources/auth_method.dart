import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_clone/models/user.dart' as model;
import 'package:instagram_clone/resources/firestore_method.dart';
import 'package:instagram_clone/resources/messaging_method.dart';
import 'package:instagram_clone/resources/storage_methods.dart';

class AuthMethod {
  static final _auth = FirebaseAuth.instance;
  static final _fireStore = FirebaseFirestore.instance;

  static Future<DocumentSnapshot<Map<String, dynamic>>> getUserSnap() async {
    final currentUser = _auth.currentUser!;

    final snap =
        await _fireStore.collection('users').doc(currentUser.uid).get();

    return snap;
  }

  static Future<model.User> getUserDetail() async {
    final snap = await getUserSnap();

    return model.User.fromSeed(snap);
  }

  //* signup user
  static Future<String> signupUser({
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

        String photoUrl = await StorageMethods.uploadImageToStorage(
            'profilePics', file, false);

        String? deviceToken = await MessagingMethod.deviceToken;

        final user = model.User(
          username: username,
          email: email,
          uid: userCred.user!.uid,
          bio: bio,
          photoUrl: photoUrl,
          followers: [],
          following: [],
          likedPosts: [],
          savedPosts: [],
          deviceToken: deviceToken,
          lastSeenNotificationId: '',
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
  static Future<String> loginUser({
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

  static Future<void> signOutUser() async {
    try {
      final userId = _auth.currentUser!.uid;
      await FirestoreMethod.updateDeviceToken(userId, '');
      await _auth.signOut();
    } catch (e) {
      return;
    }
  }
}
