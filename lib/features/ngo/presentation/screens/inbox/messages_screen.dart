import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'chat_store.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key}); // ✅ const added

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final List<Color> _softColors = const [
    Color(0xFFFFE0E0),
    Color(0xFFE0F0FF),
    Color(0xFFE6FFE8),
  ];

  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _donors = [
    {
      "name": "Allah Malik",
      "last": "Hello! Allah Malik here.",
      "time": "Now"
    },
    {
      "name": "Hotel Jafson",
      "last": "Hello! Hotel Jafson here.",
      "time": "Yesterday"
    },
    {
      "name": "Taj Hotel",
      "last": "Hello! Taj Hotel here.",
      "time": "2 days ago"
    },
  ];

  late List<Map<String, String>> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = List.from(_donors);
  }

  @override
  void dispose() {
    _searchController.dispose(); // ✅ memory leak fix
    super.dispose();
  }

  void _search(String value) {
    setState(() {
      _filtered = _donors
          .where(
            (d) =>
                d["name"]!
                    .toLowerCase()
                    .contains(value.toLowerCase()),
          )
          .toList();
    });
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inMinutes < 60) return "Now";
    if (now.difference(time).inHours < 24) {
      return "${now.difference(time).inHours}h ago";
    }
    if (now.difference(time).inDays == 1) return "Yesterday";
    return "${now.difference(time).inDays} days ago";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7F6),
        elevation: 0,
        title: const Text(
          "Inbox",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _searchController,
              onChanged: _search,
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final donor = _filtered[index];

                return ListTile(
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        _softColors[index % _softColors.length],
                    child: Text(
                      donor["name"]![0],
                      style:
                          const TextStyle(color: Colors.black),
                    ),
                  ),
                  title: Text(
                    donor["name"]!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    donor["last"]!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    donor["time"]!,
                    style: const TextStyle(fontSize: 12),
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ChatScreen(donorName: donor["name"]!),
                      ),
                    );

                    if (!mounted) return; // ✅ context async fix

                    final msgs =
                        ChatStore.getMessages(donor["name"]!);

                    if (msgs.isNotEmpty) {
                      final lastMsg = msgs.last;
                      setState(() {
                        donor["last"] = lastMsg.text;
                        donor["time"] =
                            _formatTime(lastMsg.time);
                      });
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
