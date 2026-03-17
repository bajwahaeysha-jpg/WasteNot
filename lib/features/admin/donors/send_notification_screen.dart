import 'package:flutter/material.dart';

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  State<SendNotificationScreen> createState() =>
      _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {

  final titleController = TextEditingController();
  final messageController = TextEditingController();

  static const green =  Color(0xFF0F4C45);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),

      appBar: AppBar(
        backgroundColor: green,
        title: const Text(
          "Send Notification",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            /// CARD
            Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                  )
                ],
              ),

              child: Column(
                children: [

                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Title",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: messageController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: "Message",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// SEND BUTTON
            SizedBox(
              width: double.infinity,
              height: 48,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),

                onPressed: () {
                  if (titleController.text.trim().isEmpty ||
                      messageController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter title and message"),
                      ),
                    );
                    return;
                  }

                  Navigator.pop(context, {
                    "title": titleController.text.trim(),
                    "message": messageController.text.trim(),
                    "time": "Now"
                  });
                },

                child: const Text(
                  "Send Notification",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
