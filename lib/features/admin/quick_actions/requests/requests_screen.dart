import 'package:flutter/material.dart';
import 'request_detail_screen.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  static const Color mainGreen =  Color(0xFF0F4C45);

  final List<Map<String, dynamic>> requests = [
    {
      "type": "ngo",
      "title": "Khair Foundation wants to join WasteNot",
      "name": "Khair Foundation",
      "email": "info@khair.org",
      "phone": "+92 300 1112233",
      "location": "Lahore",
      "logo": "assets/images/ngo1.png",
    },
    {
      "type": "ngo",
      "title": "Al-Khidmat Foundation wants to join WasteNot",
      "name": "Al-Khidmat Foundation",
      "email": "info@AlKhidmat.org",
      "phone": "+92 300 1112233",
      "location": "Lahore",
      "logo": "assets/images/ngo4.png",
    },
    {
      "type": "donor",
      "title": "Allah Malak wants to join WasteNot",
      "name": "Allah Malak",
      "business": "Resturant",
      "phone": "+92 321 9876543",
      "location": "DHA Phase 5",
      "logo": "assets/images/allah_malak.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: mainGreen,
        elevation: 0,
        title: const Text(
          "Requests",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (_, i) => _requestTile(context, requests[i], i),
      ),
    );
  }

  Widget _requestTile(BuildContext context, Map<String, dynamic> r, int index) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RequestDetailScreen(
              request: r,
              onDelete: () {
                setState(() {
                  requests.removeAt(index);
                });
                Navigator.pop(context); // close detail screen
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: AssetImage(r['logo']),
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r['title'],
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _badge(r['type']),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _badge(String type) {
    final bool isNgo = type == "ngo";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isNgo ? Colors.blue.withValues(alpha:.12) : mainGreen.withValues(alpha:.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isNgo ? "NGO REQUEST" : "DONOR REQUEST",
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isNgo ? Colors.blue : mainGreen,
        ),
      ),
    );
  }
}