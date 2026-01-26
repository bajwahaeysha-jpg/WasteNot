import 'package:flutter/material.dart';
import 'support_chat_screen.dart';

class AdminSupportScreen extends StatelessWidget {
  const AdminSupportScreen({super.key});

  static const Color mainGreen = Color(0xFF0F5F54);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> notifications = [
      {
        "sender": "Allah Malik",
        "role": "Donor",
        "message": "Please check my donation status",
        "time": "5 min ago",
        "image": "assets/images/allah_malak.png",
      },
      {
        "sender": "Khair Foundation",
        "role": "NGO",
        "message": "Urgent approval required",
        "time": "1 hour ago",
        "image": "assets/images/ngo1.png",
      },
    ];

    return PopScope(
      canPop: true, // ✅ IMPORTANT
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        /// 🔙 ALWAYS BACK TO ADMIN HOME
        Navigator.popUntil(context, (route) => route.isFirst);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9F8),

        /// 🟢 APP BAR
        appBar: AppBar(
          backgroundColor: mainGreen,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Support Notifications",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        /// 📋 LIST
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final n = notifications[index];

            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotificationChatScreen(
                      senderName: n["sender"]!,
                      senderRole: n["role"]!,
                      initialMessage: n["message"]!,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [

                    /// 🖼 LOGO
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey.shade100,
                      backgroundImage: AssetImage(n["image"]!),
                    ),

                    const SizedBox(width: 12),

                    /// 📄 TEXT
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            n["sender"]!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${n["role"]} • ${n["message"]}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// ⏱ TIME
                    Text(
                      n["time"]!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
