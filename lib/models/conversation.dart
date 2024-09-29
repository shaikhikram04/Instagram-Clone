import 'package:uuid/uuid.dart';

const uuid = Uuid();

class Conversation {
  Conversation({
    required this.lastMessage,
    required this.participants,
    required this.timeStamp,
  }) : id = uuid.v4();

  final String id;
  final String lastMessage;
  List participants;
  final DateTime timeStamp;
}
