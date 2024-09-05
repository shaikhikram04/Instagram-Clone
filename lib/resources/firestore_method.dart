import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/models/comment.dart';
import 'package:instagram_clone/models/post.dart';
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

  Future<String> commentToPost(
    String postId,
    String description,
    String username,
    String profImage,
  ) async {
    String res = 'some error occurred';

    try {
      final commentId = uuid.v1();

      final comment = Comment(
        date: DateTime.now(),
        id: commentId,
        likes: 0,
        text: description,
        profPicture: profImage,
        username: username,
      );
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .set(comment.toJson());

      res = 'success';
    } catch (e) {
      res = e.toString();
    }

    return res;
  }

  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      return;
    }
  }
}