import 'package:instagram_clone/models/chat.dart';

enum MessageStatus {
  sending,
  sent,
  failed,
}

class LocalChat extends Chat {
  LocalChat.text({
    required super.chatId,
    required super.from,
    required super.message,
    this.messageStatus = MessageStatus.sending,
    required super.timeStamp,
  }) : super.text();

  LocalChat.image({
    required super.chatId,
    required super.from,
    this.messageStatus = MessageStatus.sending,
    required super.timeStamp,
    required super.imageUrl,
  }) : super.image();

  LocalChat.post({
    required super.chatId,
    required super.from,
    this.messageStatus = MessageStatus.sending,
    required super.timeStamp,
    required super.postId,
    required super.message,
  }) : super.post();

  final MessageStatus messageStatus;

  LocalChat updateMessageStatus(MessageStatus msgStatus) {
    if (type == MessageType.text) {
      return LocalChat.text(
        chatId: chatId,
        from: from,
        message: message,
        timeStamp: timeStamp,
        messageStatus: msgStatus,
      );
    } else if (type == MessageType.image) {
      return LocalChat.image(
        chatId: chatId,
        from: from,
        timeStamp: timeStamp,
        imageUrl: imageUrl,
        messageStatus: msgStatus,
      );
    } else {
      return LocalChat.post(
        chatId: chatId,
        from: from,
        timeStamp: timeStamp,
        postId: postId,
        message: message,
        messageStatus: msgStatus,
      );
    }
  }
}
