enum MessageType {
  text,
  image,
}

class Message {
  Message({
    required this.messageId,
    required this.from,
    required this.to,
    required this.type,
    required this.message,
    required this.timeStamp,
  });

  final String messageId;
  final String from;
  final String to;
  final MessageType type;
  final String message;
  final DateTime timeStamp;
}
