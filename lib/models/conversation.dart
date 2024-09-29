class Conversation {
  Conversation({
    required this.id,
    required this.lastMessage,
    required this.participants,
    required this.timeStamp,
  });

  final String id;
  final String lastMessage;
  List participants;
  final DateTime timeStamp;

  Map<String, dynamic> get toJson {
    return {
      'id': id,
      'lastMessage': lastMessage,
      'participants': participants,
      'timeStamp': timeStamp,
    };
  }
}
