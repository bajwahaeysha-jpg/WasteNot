import 'package:flutter/material.dart';

class NotificationChatScreen extends StatefulWidget {
  final String senderName;
  final String senderRole;
  final String initialMessage;

  const NotificationChatScreen({
    super.key,
    required this.senderName,
    required this.senderRole,
    required this.initialMessage,
  });

  @override
  State<NotificationChatScreen> createState() =>
      _NotificationChatScreenState();
}

class _NotificationChatScreenState extends State<NotificationChatScreen> {
  static const Color mainGreen = Color(0xFF0F5F54);

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [];
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();

    // 👤 initial incoming message
    _messages.add({
      "fromAdmin": false,
      "message": widget.initialMessage,
      "time": "Just now",
    });
  }

  void _sendReply() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        "fromAdmin": true,
        "message": _controller.text.trim(),
        "time": "Now",
      });
    });

    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _deleteSelectedMessage() {
    if (_selectedIndex == null) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete message"),
        content: const Text("Do you want to delete this message?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              setState(() {
                _messages.removeAt(_selectedIndex!);
                _selectedIndex = null;
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
      backgroundColor: const Color(0xFFF7F9F8),

      appBar: AppBar(
        backgroundColor: mainGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: _selectedIndex == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.senderName,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    widget.senderRole,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              )
            : const Text(
                "1 message selected",
                style: TextStyle(color: Colors.white),
              ),
        actions: [
          if (_selectedIndex != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteSelectedMessage,
            ),
        ],
      ),

      body: Column(
        children: [

          /// 💬 Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                final isAdmin = m["fromAdmin"];
                final isSelected = _selectedIndex == index;

                return GestureDetector(
                  onLongPress: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  onTap: () {
                    if (_selectedIndex != null) {
                      setState(() => _selectedIndex = null);
                    }
                  },
                  child: Align(
                    alignment: isAdmin
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      constraints: BoxConstraints(
                        maxWidth:
                            MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.red.shade100
                            : isAdmin
                                ? mainGreen
                                : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: isSelected
                            ? Border.all(color: Colors.red)
                            : null,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            m["message"],
                            style: TextStyle(
                              color: isAdmin
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            m["time"],
                            style: TextStyle(
                              fontSize: 10,
                              color: isAdmin
                                  ? Colors.white70
                                  : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          /// ✍️ Reply box
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 8,
                  offset: Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type your reply...",
                      filled: true,
                      fillColor: const Color(0xFFF2F2F2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: mainGreen,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendReply,
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
