import 'package:flutter/material.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _allChats = [
    {
      "name": "Khair Foundation",
      "last": "Pickup confirmed for tonight",
      "time": "2 min ago",
      "color": Colors.green,
      "pinned": true,
      "image": "assets/images/ngo1.png",
    },
    {
      "name": "Edhi Foundation",
      "last": "Need more bread tomorrow",
      "time": "1 hr ago",
      "color": Colors.blue,
      "pinned": false,
      "image": "assets/images/ngo2.png",
    },
    {
      "name": "SOS Village",
      "last": "Food received, thanks admin!",
      "time": "Yesterday",
      "color": Colors.orange,
      "pinned": false,
      "image": "assets/images/ngo3.png",
    },
    {
      "name": "Al-Khidmat",
      "last": "Driver delayed 15 mins",
      "time": "2 days ago",
      "color": Colors.pink,
      "pinned": false,
      "image": "assets/images/ngo4.png",
    },
  ];

  List<Map<String, dynamic>> _filteredChats = [];

  @override
  void initState() {
    super.initState();
    _filteredChats = List.from(_allChats);
  }

  void _search(String query) {
    setState(() {
      _filteredChats = _allChats
          .where((c) =>
              c['name'].toLowerCase().contains(query.toLowerCase()) ||
              c['last'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    _filteredChats.sort(
        (a, b) => (b['pinned'] ? 1 : 0) - (a['pinned'] ? 1 : 0));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F5F54),
        title: const Text("Messages", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),

          /// 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: _search,
              decoration: InputDecoration(
                hintText: "Search messages...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          /// 💬 CHAT LIST
          Expanded(
            child: ListView.separated(
              itemCount: _filteredChats.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 80),
              itemBuilder: (context, index) {
                final chat = _filteredChats[index];

                return ListTile(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(name: chat['name']),
                    ),
                  ),
                  onLongPress: () => _showOptions(chat),

                  /// 🖼️ IMAGE
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundImage: AssetImage(chat['image']),
                  ),

                  /// 📝 TITLE + MESSAGE
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat['name'],
                          style: const TextStyle(
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        chat['time'],
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    chat['last'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  /// 📌 PIN
                  trailing: chat['pinned']
                      ? const Icon(Icons.push_pin,
                          size: 18, color: Colors.orange)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 🧭 ADMIN OPTIONS
  void _showOptions(Map chat) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.push_pin),
            title: const Text("Pin / Unpin"),
            onTap: () {
              setState(() => chat['pinned'] = !chat['pinned']);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Edit last message"),
            onTap: () {
              setState(() => chat['last'] = "Edited by admin");
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text("Delete chat"),
            onTap: () {
              setState(() => _allChats.remove(chat));
              _search(_searchController.text);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}