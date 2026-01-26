import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'chat_store.dart';

class MessagesScreen extends StatefulWidget {
  final String donorName;

  const MessagesScreen({super.key, required this.donorName});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {

  static const Color mainGreen = Color(0xFF0E5E53);

  final List<Color> _softColors = [
    Color(0xFFFFE0E0),
    Color(0xFFE0F0FF),
    Color(0xFFE6FFE8),
  ];

  final List<Map<String, String>> _ngos = [
    {"name": "Khair Foundation", "last": "Thank you for your support", "time": "Now"},
    {"name": "Edhi Foundation", "last": "Pickup scheduled tomorrow", "time": "Yesterday"},
    {"name": "SOS Children's Village", "last": "Food received successfully", "time": "2 days ago"},
  ];

  List<Map<String, String>> _filtered = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = _ngos;
  }

  void _search(String value) {
    setState(() {
      _filtered = _ngos
          .where((d) => d["name"]!.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inMinutes < 60) return "Now";
    if (now.difference(time).inHours < 24) return "${now.difference(time).inHours}h ago";
    if (now.difference(time).inDays == 1) return "Yesterday";
    return "${now.difference(time).inDays} days ago";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),

      // ✅ Home Screen Style AppBar
      appBar: AppBar(
        backgroundColor: mainGreen,
        title: const Text("WasteNot", style: TextStyle(color: Colors.white)),
        actions: const [
          Icon(Icons.notifications_none, color: Colors.white),
          SizedBox(width: 10),
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text("A", style: TextStyle(color: mainGreen)),
            ),
          )
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // 📨 INBOX TITLE
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text("Inbox", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),

          // 🔍 Search Bar
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

          // 📋 Inbox List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final ngo = _filtered[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _softColors[index % _softColors.length],
                      child: Text(ngo["name"]![0], style: const TextStyle(color: Colors.black)),
                    ),
                    title: Text(ngo["name"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(ngo["last"]!, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Text(ngo["time"]!, style: const TextStyle(fontSize: 12)),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            donorName: widget.donorName,
                            ngoName: ngo["name"]!,
                          ),
                        ),
                      );

                      final msgs = ChatStore.getMessages("${widget.donorName}_${ngo["name"]}");
                      if (msgs.isNotEmpty) {
                        final last = msgs.last;
                        setState(() {
                          ngo["last"] = last.text;
                          ngo["time"] = _formatTime(last.time);
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
