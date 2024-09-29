import 'package:uuid/uuid.dart';

enum MessageType {
  text,
  image,
}

const _uuid = Uuid();

class Message {
  Message({
    required this.from,
    required this.to,
    required this.type,
    required this.message,
    required this.timeStamp,
  }) : messageId = _uuid.v4();

  final String messageId;
  final String from;
  final String to;
  final MessageType type;
  final String message;
  final DateTime timeStamp;
}


