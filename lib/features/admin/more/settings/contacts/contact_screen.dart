import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wastenot/services/contact_service.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  static const Color primary = Color(0xFF0F4C45);
  static const Color background = Color(0xFFF5F7F6);

  @override
  Widget build(BuildContext context) {
    final contactService = ContactService();
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Contact Support",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: contactService.streamMessages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Unable to load messages.'));
          }

          final docs = snapshot.data?.docs ?? const [];
          if (docs.isEmpty) {
            return const Center(child: Text('No contact messages.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final name = (data['name'] as String?) ?? 'Unknown';
              final email = (data['email'] as String?) ?? 'Unknown';
              final role = (data['role'] as String?) ?? 'unknown';
              final message = (data['message'] as String?) ?? '';
              final status = (data['status'] as String?) ?? 'pending';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(email),
                      const SizedBox(height: 4),
                      Text('Role: $role'),
                      const SizedBox(height: 8),
                      Text(message),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Status: $status'),
                          Row(
                            children: [
                              TextButton(
                                onPressed: status == 'resolved'
                                    ? null
                                    : () async {
                                        await contactService.markResolved(
                                          doc.id,
                                        );
                                      },
                                child: const Text('Resolve'),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () async {
                                  await contactService.deleteMessage(doc.id);
                                },
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
