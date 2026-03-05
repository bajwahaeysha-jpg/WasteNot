import 'package:flutter/material.dart';
import 'chat_store.dart';

class ChatScreen extends StatefulWidget {
  final String donorName;

  const ChatScreen({super.key, required this.donorName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  late List<ChatMessage> _messages;

  final Set<int> _selected = {};
  bool get _isSelecting => _selected.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _messages = ChatStore.getMessages(widget.donorName);

    if (_messages.isEmpty) {
  ChatStore.addDonorMessage(
    widget.donorName,
    "Hello! ${widget.donorName} here.",
  );
  _messages = ChatStore.getMessages(widget.donorName);
}

  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    ChatStore.addMessage(widget.donorName, _controller.text.trim());

    setState(() {
      _messages = ChatStore.getMessages(widget.donorName);
      _controller.clear();
    });
  }

  Future<void> _confirmDelete() async {
    final bool? result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete messages?"),
        content: const Text("Are you sure you want to delete selected messages?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text("Delete"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (result == true) {
      _deleteSelected();
    } else {
      setState(() {
        _selected.clear();
      });
    }
  }

  void _deleteSelected() {
    setState(() {
      _selected.toList()
        ..sort((a, b) => b.compareTo(a))
        ..forEach((i) => _messages.removeAt(i));

      _selected.clear();
      ChatStore.replaceMessages(widget.donorName, _messages);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _dayHeader(DateTime time) {
    final now = DateTime.now();
    String text;

    if (_isSameDay(time, now)) {
      text = "Today";
    } else if (_isSameDay(time, now.subtract(const Duration(days: 1)))) {
      text = "Yesterday";
    } else {
      text = "${time.day}/${time.month}/${time.year}";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(text, style: const TextStyle(fontSize: 12)),
        ),
      ),
    );
  }

  String _timeOnly(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final ampm = time.hour >= 12 ? "PM" : "AM";
    return "$hour:${time.minute.toString().padLeft(2, '0')} $ampm";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
  backgroundColor: const Color(0xFF0F4C45),
  elevation: 1,

  iconTheme: const IconThemeData(color: Colors.white),

  title: _isSelecting
      ? Text(
          "${_selected.length} selected",
          style: const TextStyle(color: Colors.white),
        )
      : Text(
          widget.donorName,
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
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final showHeader = index == 0 || !_isSameDay(msg.time, _messages[index - 1].time);

                return Column(
                  children: [
                    if (showHeader) _dayHeader(msg.time),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: GestureDetector(
                        onLongPress: () {
                          setState(() => _selected.add(index));
                        },
                        onTap: () {
                          if (_isSelecting) {
                            setState(() {
                              _selected.contains(index)
                                  ? _selected.remove(index)
                                  : _selected.add(index);
                            });
                          }
                        },
                        child: Align(
                          alignment: msg.isDonor ? Alignment.centerLeft : Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _selected.contains(index)
                                  ? Colors.red.shade100
                                  : msg.isDonor
                                      ? Colors.white
                                      : const Color(0xFFDCF8C6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Colors.black, fontSize: 14),
                                children: [
                                  TextSpan(text: msg.text),
                                  const TextSpan(text: "  "),
                                  TextSpan(
                                    text: _timeOnly(msg.time),
                                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF0F0F0),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                CircleAvatar(
                  backgroundColor: Colors.green,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
