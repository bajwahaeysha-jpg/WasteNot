class ChatMessage {
  final String text;
  final DateTime time;
  final bool isDonor;

  ChatMessage({required this.text, required this.time, required this.isDonor});
}

class ChatStore {
  static final Map<String, List<ChatMessage>> _data = {};

  static List<ChatMessage> getMessages(String donor) {
    return _data[donor] ?? [];
  }

  static void addMessage(String donor, String message, {bool isDonor = false}) {
    _data.putIfAbsent(donor, () => []);
    _data[donor]!.add(ChatMessage(
      text: message,
      time: DateTime.now(),
      isDonor: isDonor,
    ));
  }

  static void addDonorMessage(String donor, String message) {
    addMessage(donor, message, isDonor: true);
  }

  static void replaceMessages(String donor, List<ChatMessage> messages) {
    _data[donor] = messages;
  }
}
