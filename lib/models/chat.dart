import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  image,
  post,
}

class Chat {
  Chat.text({
    required this.chatId,
    required this.from,
    required this.message,
    required this.timeStamp,
  })  : imageUrl = null,
        postId = null,
        type = MessageType.text;

  Chat.image({
    required this.chatId,
    required this.from,
    required this.timeStamp,
    required this.imageUrl,
  })  : message = null,
        postId = null,
        type = MessageType.image;

  Chat.post({
    required this.chatId,
    required this.from,
    required this.timeStamp,
    required this.postId,
    required this.message,
  })  : imageUrl = null,
        type = MessageType.post;

  final String chatId;
  final String from;
  final MessageType type;
  final String? message;
  final Timestamp timeStamp;
  final String? postId;
  final String? imageUrl;

  Map<String, dynamic> get toJson {
    return {
      'chatId': chatId,
      'from': from,
      'message': message,
      'messageType': type.name.toString(),
      'timeStamp': timeStamp,
      'postId': postId,
      'imageUrl': imageUrl,
    };
  }
}
