import 'package:flutter/material.dart';
import 'chat_store.dart';

class ChatScreen extends StatefulWidget {
  final String donorName;
  final String ngoName;

  const ChatScreen({super.key, required this.donorName, required this.ngoName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late List<ChatMessage> _messages;
  final TextEditingController _controller = TextEditingController();

  final Set<int> _selected = {};
  bool get _isSelecting => _selected.isNotEmpty;

  String get _chatId => "${widget.donorName}_${widget.ngoName}";

  @override
  void initState() {
    super.initState();
    _messages = ChatStore.getMessages(_chatId);

    if (_messages.isEmpty) {
      ChatStore.addMessage(
          _chatId, "Hello ${widget.ngoName}, this is ${widget.donorName}.");
      _messages = ChatStore.getMessages(_chatId);
    }
  }

  void _send() {
    if (_controller.text.trim().isEmpty) return;

    ChatStore.addMessage(_chatId, _controller.text.trim());

    setState(() {
      _messages = ChatStore.getMessages(_chatId);
      _controller.clear();
    });
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete messages?"),
        content:
            const Text("Are you sure you want to delete selected messages?"),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _selected.clear());
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                final list = _selected.toList()
                  ..sort((a, b) => b.compareTo(a));

                for (final i in list) {
                  _messages.removeAt(i);
                }
                _selected.clear();
              });
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0E5E53),

        iconTheme: const IconThemeData(
          color: Colors.white, // back arrow white
        ),

        title: _isSelecting
            ? Text(
                "${_selected.length} selected",
                style: const TextStyle(color: Colors.white),
              )
            : Text(
                widget.ngoName,
                style: const TextStyle(color: Colors.white),
              ),

        actions: _isSelecting
            ? [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: _confirmDelete,
                )
              ]
            : [],
      ),

      body: Column(
        children: [

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (_, i) {

                final msg = _messages[i];
                final right = !msg.fromNgo;
                final selected = _selected.contains(i);

                return GestureDetector(
                  onLongPress: () {
                    setState(() => _selected.add(i));
                  },
                  onTap: () {
                    if (_isSelecting) {
                      setState(() {
                        selected
                            ? _selected.remove(i)
                            : _selected.add(i);
                      });
                    }
                  },
                  child: Align(
                    alignment: right
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.green.withValues(alpha: 0.35)
                            : right
                                ? const Color(0xFFDCF8C6)
                                : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(msg.text),
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                CircleAvatar(
                  backgroundColor: const Color(0xFF0E5E53),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _send,
                  ),
                )

              ],
            ),
          )

        ],
      ),
    );
  }
}