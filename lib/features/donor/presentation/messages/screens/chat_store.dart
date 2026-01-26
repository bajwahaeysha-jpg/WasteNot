class ChatMessage {
  final String text;
  final DateTime time;
  final bool fromNgo;

  ChatMessage({required this.text, required this.time, required this.fromNgo});
}

class ChatStore {
  static final Map<String, List<ChatMessage>> _store = {};

  static List<ChatMessage> getMessages(String chatId) {
    return _store[chatId] ?? [];
  }

  static void addMessage(String chatId, String msg, {bool fromNgo = false}) {
    _store.putIfAbsent(chatId, () => []);
    _store[chatId]!.add(ChatMessage(
      text: msg,
      time: DateTime.now(),
      fromNgo: fromNgo,
    ));
  }
}
