import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wastenot/models/ngo_request_model.dart';
import 'package:wastenot/services/firestore_service.dart';

import 'request_detail_screen.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  static const Color mainGreen = Color(0xFF0F4C45);

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: mainGreen,
        elevation: 0,
        title: const Text(
          'Requests',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<NgoRequestModel>>(
        stream: firestoreService.pendingNgoRequests(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!;
          if (requests.isEmpty) {
            return const Center(
              child: Text(
                'No pending NGO requests.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (_, i) => _requestTile(context, requests[i]),
          );
        },
      ),
    );
  }

  Widget _requestTile(BuildContext context, NgoRequestModel request) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RequestDetailScreen(request: request),
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
              backgroundColor: Colors.blue.withValues(alpha: .12),
              child: const Icon(Icons.apartment, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${request.organizationName} wants to join WasteNot',
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'PENDING NGO',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          DateFormat('dd MMM, hh:mm a').format(
                            request.createdAt,
                          ),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    request.email,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
