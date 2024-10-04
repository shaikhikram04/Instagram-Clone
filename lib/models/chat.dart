enum MessageType {
  text,
  image,
  post,
}

class Chat {
  Chat({
    required this.chatId,
    required this.from,
    required this.type,
    required this.message,
    required this.timeStamp,
  });

  final String chatId;
  final String from;
  final MessageType type;
  final String message;
  final DateTime timeStamp;

  Map<String, dynamic> get toJson {
    return {
      'chatId': chatId,
      'from': from,
      'message': message,
      'messageType': type.name.toString(),
      'timeStamp': timeStamp.toString(),
    };
  }
}
