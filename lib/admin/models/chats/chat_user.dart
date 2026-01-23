class ChatUser {
  final String id;
  final String name;
  final String role; // donor / ngo
  final String lastMessage;

  ChatUser({
    required this.id,
    required this.name,
    required this.role,
    required this.lastMessage,
  });
}
