import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String name;
  const ChatScreen({super.key, required this.name});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  _Message? _selectedMessage;

  List<_Message> messages = [];

  @override
  void initState() {
    super.initState();
    messages = [
      _Message("Asslam-o-Alaikum, ${widget.name}", true),
      _Message("Wa Alaikum Salam! How can we help you?", false),
    ];
  }

  // ───────────── MESSAGE ACTIONS ─────────────

  void _pinMessage() {
    if (_selectedMessage == null) return;
    setState(() {
      messages.remove(_selectedMessage);
      _selectedMessage!.pinned = true;
      messages.insert(0, _selectedMessage!);
      _selectedMessage = null;
    });
  }

  void _editMessage() {
    if (_selectedMessage == null) return;
    _controller.text = _selectedMessage!.text;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Edit Message"),
        content: TextField(controller: _controller),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedMessage!.text = _controller.text;
                _selectedMessage = null;
              });
              _controller.clear();
              Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  void _deleteMessage() {
    if (_selectedMessage == null) return;
    setState(() {
      messages.remove(_selectedMessage);
      _selectedMessage = null;
    });
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() => messages.add(_Message(_controller.text, true)));
    _controller.clear();
  }

  // ───────────── UI ─────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F5F54),
        leading: const BackButton(color: Colors.white),
        title: Text(widget.name, style: const TextStyle(color: Colors.white)),

        /// ⋮ TOP RIGHT MENU
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (_selectedMessage == null) return;
              if (value == "pin") _pinMessage();
              if (value == "edit") _editMessage();
              if (value == "delete") _deleteMessage();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: "pin", child: Text("Pin")),
              const PopupMenuItem(value: "edit", child: Text("Edit")),
              const PopupMenuItem(
                value: "delete",
                child: Text("Delete",
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          /// 💬 CHAT MESSAGES
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (_, i) {
                final msg = messages[i];
                return GestureDetector(
                  onTap: () => setState(() => _selectedMessage = msg),
                  child: _Bubble(
                    message: msg,
                    selected: _selectedMessage == msg,
                  ),
                );
              },
            ),
          ),

          /// ✍️ INPUT BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendMessage,
                  child: const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFF2E7D32),
                    child: Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ───────────── MESSAGE MODEL ─────────────

class _Message {
  String text;
  final bool isMe;
  bool pinned = false;

  _Message(this.text, this.isMe);
}

/// ───────────── CHAT BUBBLE ─────────────

class _Bubble extends StatelessWidget {
  final _Message message;
  final bool selected;

  const _Bubble({
    required this.message,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: message.isMe
              ? const Color(0xFFDFF7C8)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: selected
              ? Border.all(color: const Color(0xFF0F5F54), width: 1.2)
              : null,
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 3),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.pinned)
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(Icons.push_pin, size: 14),
              ),
            Flexible(
              child: Text(
                message.text,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
