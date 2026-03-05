import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationChatScreen extends StatelessWidget {

  final String senderName;
  final String senderRole;
  final String senderEmail;
  final String message;

  const NotificationChatScreen({
    super.key,
    required this.senderName,
    required this.senderRole,
    required this.senderEmail,
    required this.message,
  });

  static const Color mainGreen = Color(0xFF0F5F54);

  /// EMAIL FUNCTION
  Future<void> sendEmailReply() async {

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: senderEmail,
      query: Uri.encodeFull(
        "subject=WasteNot Support Reply&body=Hello $senderName,\n\nThank you for contacting WasteNot support.\n\n",
      ),
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;

    return Scaffold(

      backgroundColor: const Color(0xFFF7F9F8),

      appBar: AppBar(
        backgroundColor: mainGreen,
        iconTheme: const IconThemeData(color: Colors.white),

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              senderName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),

            Text(
              senderRole,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// TITLE
            Text(
              "Complaint Message",
              style: TextStyle(
                fontSize: width * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            /// MESSAGE CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:.05),
                    blurRadius: 8,
                  )
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// SENDER INFO
                  Row(
                    children: [

                      CircleAvatar(
                        backgroundColor: mainGreen.withValues(alpha:.1),
                        child: const Icon(
                          Icons.person,
                          color: mainGreen,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            senderName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            senderRole,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// MESSAGE TEXT
                  Text(
                    message,
                    style: const TextStyle(
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            /// EMAIL BUTTON
            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(

                icon: const Icon(
                  Icons.email,
                  color: Colors.white,
                ),

                label: const Text(
                  "Reply via Email",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: mainGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                onPressed: sendEmailReply,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}