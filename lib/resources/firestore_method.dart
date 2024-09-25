import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_clone/models/comment.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethod {
  final _firestore = FirebaseFirestore.instance;

  final uuid = const Uuid();

  //* upload post
  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    String username,
    String profImage,
  ) async {
    String res = 'some error occcurred';
    try {
      String imageUrl =
          await StorageMethods().uploadImageToStorage('posts', file, true);

      final postId = uuid.v1();
      final post = Post(
        description: description,
        uid: uid,
        username: username,
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: imageUrl,
        profImage: profImage,
        likes: [],
      );

      await _firestore.collection('posts').doc(postId).set(post.toJson());

      res = 'success';
    } catch (e) {
      res = e.toString();
    }

    return res;
  }

  Future<void> likePost(
      String postId, String uid, List likes, WidgetRef ref) async {
    try {
      //! if user already liked post
      if (likes.contains(uid)) {
        //*! remove userId from likes list
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });

        //! remove postId from user LidedPost list
        _firestore.collection('users').doc(uid).update({
          'likedPosts': FieldValue.arrayRemove([postId]),
        });

        likes.remove(postId);
        ref.read(userProvider.notifier).updateField(likedPosts: likes);
      } else {
        //! is like post
        //*! add userId to likes list
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });

        //! add postId from to LidedPost list
        _firestore.collection('users').doc(uid).update({
          'likedPosts': FieldValue.arrayUnion([postId]),
        });

        likes.add(postId);
        ref.read(userProvider.notifier).updateField(likedPosts: likes);
      }
    } catch (e) {
      return;
    }
  }

  void savePost(String uid, String postId, List savedPosts, WidgetRef ref) {
    //* already saved -> unsave
    if (savedPosts.contains(postId)) {
      //! remove postId from savedPost of firebase
      _firestore.collection('users').doc(uid).update({
        'savedPosts': FieldValue.arrayRemove([postId])
      });

      //! remove postId from list of provider
      savedPosts.remove(postId);
      ref.read(userProvider.notifier).updateField(savedPosts: savedPosts);
    } else {
      //! add postId to savedPost of firebase
      _firestore.collection('users').doc(uid).update({
        'savedPosts': FieldValue.arrayUnion([postId])
      });

      //! remove postId from list of provider
      savedPosts.add(postId);
      ref.read(userProvider.notifier).updateField(savedPosts: savedPosts);
    }
  }

  Future<void> commentToPost(
    String postId,
    String text,
    String uid,
    String username,
    String profImage,
  ) async {
    try {
      if (text.isNotEmpty) {
        final commentId = uuid.v1();
        final comment = Comment(
          date: DateTime.now(),
          id: commentId,
          likes: [],
          text: text,
          profPicture: profImage,
          username: username,
          uid: uid,
        );

        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set(comment.toJson());
      }
    } catch (e) {
      return;
    }
  }

  Future<void> likeComment(
    String postId,
    String commentId,
    String uid,
    List likes,
  ) async {
    try {
      if (likes.contains(uid)) {
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
    } catch (e) {
      return;
    }
  }

  void deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      return;
    }
  }

  Future<void> followUser(String uid, String followId) async {
    try {
      final snap = await _firestore.collection('users').doc(uid).get();
      List following = snap.data()!['following'];

      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }
    } catch (e) {
      return;
    }
  }

  Future<String> editProfile(
    String uid,
    String username,
    String bio,
    String gender,
    String imageUrl,
    Uint8List? newImage,
  ) async {
    String res = 'some error';

    try {
      if (newImage != null) {
        StorageMethods().deleteImage('profilePics');
        imageUrl = await StorageMethods()
            .uploadImageToStorage('profilePics', newImage, false);
      }

      _firestore.collection('users').doc(uid).update({
        'username': username,
        'bio': bio,
        'gender': gender,
        'photoUrl': imageUrl,
      });
      res = 'success';
    } catch (e) {
      res = e.toString();
    }

    return res;
  }
}
