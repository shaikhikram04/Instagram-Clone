import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_clone/models/chat.dart';
import 'package:instagram_clone/models/comment.dart';
import 'package:instagram_clone/models/conversation.dart';
import 'package:instagram_clone/models/notification.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/messaging_method.dart';
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

        final docRef = _firestore.collection('users').doc(followerId);

        final docSnap = await docRef.get();
        final fcmToken = docSnap.data()!['deviceToken'];

        await MessagingMethod.sendFcmMessage(
          fcmToken,
          'New Post',
          '$username updoaded new post',
          'notification',
        );
        await docRef
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
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([user.uid]),
        });

        //! remove postId from user LidedPost list
        await _firestore.collection('users').doc(user.uid).update({
          'likedPosts': FieldValue.arrayRemove([postId]),
        });

        likes.remove(postId);
        ref.read(userProvider.notifier).updateField(likedPosts: likes);
      } else {
        likes.add(postId);
        ref.read(userProvider.notifier).updateField(likedPosts: likes);

        //! is like post
        //*! add userId to likes list
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([user.uid]),
        });

        //! add postId from to LidedPost list
        await _firestore.collection('users').doc(user.uid).update({
          'likedPosts': FieldValue.arrayUnion([postId]),
        });

        // if (postUserId != user.uid) {
        //   //* sending notification to the user who posted
        //   final notificationId = uuid.v1();
        //   final notification = Notification(
        //     notificationId: notificationId,
        //     type: NotificationType.like,
        //     body: 'Likes your post',
        //     timestamp: Timestamp.now(),
        //     referenceId: postId,
        //     profileImageUrl: user.photoUrl,
        //     username: user.username,
        //   );

        //   final docRef = _firestore.collection('users').doc(postUserId);
        //   final docSnap = await docRef.get();
        //   final fcmToken = docSnap.data()!['deviceToken'];

        //   await MessagingMethod.sendFcmMessage(
        //     fcmToken,
        //     'Like',
        //     '${user.username} liked your post',
        //     'notification',
        //   );

        //   await docRef
        //       .collection('notifications')
        //       .doc(notificationId)
        //       .set(notification.toJson);
        // }
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
    String postUserId,
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

        //* sending notification
        if (postUserId != uid) {
          final notificationId = uuid.v1();

          final notification = Notification(
            notificationId: notificationId,
            type: NotificationType.comment,
            body: 'Comment to your post',
            timestamp: Timestamp.now(),
            referenceId: postId,
            profileImageUrl: profImage,
            username: username,
          );

          final docRef = _firestore.collection('users').doc(postUserId);
          final docSnap = await docRef.get();
          final fcmToken = docSnap.data()!['deviceToken'];

          await MessagingMethod.sendFcmMessage(
            fcmToken,
            'Comment',
            '$username comment on your post',
            'notification',
          );

          await docRef
              .collection('notifications')
              .doc(notificationId)
              .set(notification.toJson);
        }
      }
    } catch (e) {
      return;
    }
  }

  static Future<void> likeComment(
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

  static Future<void> followUser(String followId, WidgetRef ref) async {
    try {
      final user = ref.read(userProvider);

      final snap = await _firestore.collection('users').doc(user.uid).get();
      List following = snap.data()!['following'];

      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([user.uid])
        });
        await _firestore.collection('users').doc(user.uid).update({
          'following': FieldValue.arrayRemove([followId])
        });

        following.remove(followId);
        ref.read(userProvider.notifier).updateField(following: following);
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([user.uid])
        });
        await _firestore.collection('users').doc(user.uid).update({
          'following': FieldValue.arrayUnion([followId])
        });

        following.add(followId);
        ref.read(userProvider.notifier).updateField(following: following);

        //* sending notification
        final notificationId = uuid.v1();
        final notification = Notification(
          notificationId: notificationId,
          type: NotificationType.follow,
          body: 'Started following you',
          timestamp: Timestamp.now(),
          referenceId: user.uid,
          profileImageUrl: user.photoUrl,
          username: user.username,
        );

        final docRef = _firestore.collection('users').doc(followId);
        final docSnap = await docRef.get();
        final fcmToken = docSnap.data()!['deviceToken'];

        await MessagingMethod.sendFcmMessage(
          fcmToken,
          'New Follower',
          '${user.username} started following you',
          'notification',
        );

        await docRef
            .collection('notifications')
            .doc(notificationId)
            .set(notification.toJson);
      }
    } catch (e) {
      return;
    }
  }

  static Future<String> editProfile(
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
    required String username,
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

      //* storing userId of all participants except currUser
      final conversationSnap = await conversationDocRef.get();
      final List participantsId = conversationSnap.data()!['participantsId'];
      participantsId.remove(uid);

      final lastMessage = messageType == MessageType.text
          ? message
          : messageType == MessageType.image
              ? 'Sent Image'
              : 'Sent post';

      final userCollectionRef = _firestore.collection('users');
      for (final receiverUserId in participantsId) {
        final userSnap = await userCollectionRef.doc(receiverUserId).get();
        final token = userSnap.data()!['deviceToken'];
        await MessagingMethod.sendFcmMessage(
          token,
          'New Message',
          '$username : $lastMessage',
          'message',
        );
      }

      //* update conversation data
      await conversationDocRef.update({
        'lastMessage': lastMessage,
        'timeStamp': DateTime.now(),
        'sendBy': username,
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
    await _firestore.collection('users').doc(userId).update(
      {'deviceToken': token},
    );
  }
}
