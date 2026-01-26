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
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F5F54),
        title: const Text("Messages", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          /// 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4)
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _search,
                decoration: const InputDecoration(
                  hintText: "Search messages...",
                  border: InputBorder.none,
                  icon: Icon(Icons.search),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// 💬 CHAT LIST
          Expanded(
            child: ListView.builder(
              itemCount: _filteredChats.length,
              itemBuilder: (context, index) {
                final chat = _filteredChats[index];
                return _ChatTile(
                  name: chat['name'],
                  message: chat['last'],
                  time: chat['time'],
                  color: chat['color'],
                  pinned: chat['pinned'],
                  image: chat['image'],
                  onLongPress: () => _showOptions(chat),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(name: chat['name']),
                    ),
                  ),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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

/// ───────────── CHAT TILE (ENHANCED UI) ─────────────

class _ChatTile extends StatelessWidget {
  final String name, message, time;
  final Color color;
  final bool pinned;
  final String image;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ChatTile({
    required this.name,
    required this.message,
    required this.time,
    required this.color,
    required this.pinned,
    required this.image,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            /// 🖼️ NGO IMAGE
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withValues(alpha: .4),
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(width: 12),

            /// 💬 TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            /// 📌 PIN ICON
            if (pinned)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.push_pin,
                    size: 14,
                    color: Colors.orange,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
