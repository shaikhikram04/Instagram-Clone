import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_clone/models/local_chat.dart';

class LocalChatNotifier extends StateNotifier<List<LocalChat>> {
  LocalChatNotifier() : super([]);

  void setLocalChat(List<LocalChat> localChats) {
    state = localChats;
  }

  void addLocalChat(LocalChat localChat) {
    state = [localChat, ...state];
  }

  void updateStatus(String id, MessageStatus messageStatus) {
    state = state.map((msg) {
      if (msg.chatId == id) return msg.updateMessageStatus(messageStatus);
      return msg;
    }).toList();
  }
}

final localChatProvider =
    StateNotifierProvider<LocalChatNotifier, List<LocalChat>>(
  (ref) => LocalChatNotifier(),
);
