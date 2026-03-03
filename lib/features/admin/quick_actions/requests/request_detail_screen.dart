import 'package:flutter/material.dart';

class RequestDetailScreen extends StatelessWidget {
  final Map<String, dynamic> request;
  final VoidCallback onDelete; // callback to delete from previous screen

  const RequestDetailScreen({
    super.key,
    required this.request,
    required this.onDelete,
  });

  static const Color mainGreen = Color(0xFF0F5F54);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: mainGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Request Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo / Avatar
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(request['logo']),
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(height: 20),

            // Request Name
            Text(
              request['name'],
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Location / Business
            if (request['business'] != null)
              Text(
                request['business'],
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            if (request['location'] != null)
              Text(
                request['location'],
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            const SizedBox(height: 20),

            // Info card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoRow("Email", request['email']),
                    _infoRow("Phone", request['phone']),
                    if (request['location'] != null)
                      _infoRow("Location", request['location']),
                    if (request['business'] != null)
                      _infoRow("Business", request['business']),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Delete button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Delete Request"),
                      content: const Text(
                          "Are you sure you want to delete this request?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          onPressed: () {
                            onDelete(); // delete from parent screen
                            Navigator.pop(context); // close dialog
                            Navigator.pop(context); // go back
                          },
                          child: const Text("Delete"),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete),
                label: const Text(
                  "Delete Request",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black54)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}