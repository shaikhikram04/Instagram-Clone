import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_clone/models/chat.dart';
import 'package:instagram_clone/models/comment.dart';
import 'package:instagram_clone/models/conversation.dart';
import 'package:instagram_clone/models/notification.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethod {
  static final _firestore = FirebaseFirestore.instance;

  static const uuid = Uuid();

  //* upload post
  static Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    String username,
    String profImage,
    List followers,
  ) async {
    String res = 'some error occcurred';
    try {
      String imageUrl =
          await StorageMethods.uploadImageToStorage('posts', file, true);

      final postId = uuid.v1();
      final post = Post(
        description: description,
        uid: uid,
        username: username,
        postId: postId,
        datePublished: Timestamp.now(),
        postUrl: imageUrl,
        profImage: profImage,
        likes: [],
      );

      await _firestore.collection('posts').doc(postId).set(post.toJson());

      //* push data on notification collection of followers
      for (final followerId in followers) {
        final notificationId = uuid.v1();

        final notification = Notification(
          notificationId: notificationId,
          type: NotificationType.newPost,
          body: 'Posted a new image.',
          timestamp: Timestamp.now(),
          referenceId: postId,
          profileImageUrl: profImage,
          username: username,
        );

        await _firestore
            .collection('users')
            .doc(followerId)
            .collection('notifications')
            .doc(notificationId)
            .set(notification.toJson);
      }

      res = 'success';
    } catch (e) {
      res = e.toString();
    }

    return res;
  }

  static Future<void> likePost(
    String postId,
    String postUserId,
    List likes,
    WidgetRef ref,
  ) async {
    final user = ref.read(userProvider);
    try {
      //! if user already liked post
      if (likes.contains(user.uid)) {
        //*! remove userId from likes list
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([user.uid]),
        });

        //! remove postId from user LidedPost list
        _firestore.collection('users').doc(user.uid).update({
          'likedPosts': FieldValue.arrayRemove([postId]),
        });

        likes.remove(postId);
        ref.read(userProvider.notifier).updateField(likedPosts: likes);
      } else {
        //! is like post
        //*! add userId to likes list
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([user.uid]),
        });

        //! add postId from to LidedPost list
        _firestore.collection('users').doc(user.uid).update({
          'likedPosts': FieldValue.arrayUnion([postId]),
        });

        likes.add(postId);
        ref.read(userProvider.notifier).updateField(likedPosts: likes);

        //* sending notification to the user who posted
        final notificationId = uuid.v1();
        final notification = Notification(
          notificationId: notificationId,
          type: NotificationType.like,
          body: 'Likes your post',
          timestamp: Timestamp.now(),
          referenceId: postId,
          profileImageUrl: user.photoUrl,
          username: user.username,
        );

        await _firestore
            .collection('users')
            .doc(postUserId)
            .collection('notifications')
            .doc(notificationId)
            .set(notification.toJson);
      }
    } catch (e) {
      return;
    }
  }

  static void savePost(
      String uid, String postId, List savedPosts, WidgetRef ref) {
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

  static Future<void> commentToPost(
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
          date: Timestamp.now(),
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

  Future<void> followUser(String uid, String followId, WidgetRef ref) async {
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

        following.remove(followId);
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });

        following.add(followId);
      }

      ref.read(userProvider.notifier).updateField(following: following);
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
        StorageMethods.deleteImage('profilePics');
        imageUrl = await StorageMethods.uploadImageToStorage(
            'profilePics', newImage, false);
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

  static Future<String> establishConversation(
    String selfUid,
    String selfUsername,
    String selfPhotoUrl,
    String otherUid,
    String otherUsername,
    String otherPhotoUrl,
  ) async {
    String? err;
    final String id = uuid.v4();

    try {
      final participants = [selfUid, otherUid];
      participants.sort();

      final conversation = Conversation(
        id: id,
        lastMessage: '',
        participants: {
          selfUid: [
            selfUsername,
            selfPhotoUrl,
          ],
          otherUid: [
            otherUsername,
            otherPhotoUrl,
          ]
        },
        timeStamp: Timestamp.now(),
        sendBy: '',
        participantsId: participants,
      );

      await _firestore
          .collection('conversations')
          .doc(conversation.id)
          .set(conversation.toJson);
    } catch (e) {
      err = 'error occurred';
    }

    return err ?? id;
  }

  static Future<String> pushMessage({
    required String conversationId,
    required String uid,
    required MessageType messageType,
    String? message,
    String? postId,
    String? imageUrl,
  }) async {
    String res = 'some error occurred';

    try {
      final chatId = uuid.v4();
      late Chat chat;
      if (messageType == MessageType.text) {
        chat = Chat.text(
          chatId: chatId,
          from: uid,
          message: message,
          timeStamp: Timestamp.now(),
        );
      } else if (messageType == MessageType.image) {
        chat = Chat.image(
          chatId: chatId,
          from: uid,
          timeStamp: Timestamp.now(),
          imageUrl: imageUrl,
        );
      } else {
        chat = Chat.post(
          chatId: chatId,
          from: uid,
          timeStamp: Timestamp.now(),
          postId: postId,
          message: message,
        );
      }

      final conversationDocRef =
          _firestore.collection('conversations').doc(conversationId);

      final lastMessage = messageType == MessageType.text
          ? message
          : messageType == MessageType.image
              ? 'Sent Image'
              : 'Sent post';

      //* update conversation data
      await conversationDocRef.update({
        'lastMessage': lastMessage,
        'timeStamp': DateTime.now(),
        'sendBy': uid,
      });

      //* making docs for message
      await conversationDocRef.collection('chats').doc(chatId).set(chat.toJson);

      res = 'success';
    } catch (e) {
      res = e.toString();
    }

    return res;
  }

  static Future<void> updateDeviceToken(String userId, String? token) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .update({'deviceToken': token});
  }
}
