class Conversation {
  Conversation({
    required this.id,
    required this.lastMessage,
    required this.participants,
    required this.timeStamp,
    required this.sendBy,
  });

  final String id;
  final String lastMessage;
  List participants;
  final DateTime timeStamp;
  final String sendBy;

  Map<String, dynamic> get toJson {
    return {
      'id': id,
      'lastMessage': lastMessage,
      'participants': participants,
      'timeStamp': timeStamp,
    };
  }
}
