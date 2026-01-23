import 'package:flutter/material.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final requests = [
    {
      "id": "RQ-1001",
      "donor": "Green Leaf Restaurant",
      "location": "Johar Town",
      "meals": 120,
      "status": "Pending",
    },
    {
      "id": "RQ-1002",
      "donor": "Sunrise Bakery",
      "location": "DHA Phase 5",
      "meals": 85,
      "status": "Pending",
    },
    {
      "id": "RQ-1003",
      "donor": "City Hotel",
      "location": "Gulberg",
      "meals": 60,
      "status": "Approved",
    },
  ];

  static const Color mainGreen = Color(0xFF0F5F54);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: mainGreen,
        elevation: 0,
        title: const Text(
          "Food Requests",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: requests.length,
        itemBuilder: (_, i) => _requestCard(requests[i]),
      ),
    );
  }

  // ───────────── REQUEST CARD ─────────────

  Widget _requestCard(Map r) {
    final bool pending = r['status'] == "Pending";
    final Color statusColor =
        pending ? Colors.orange : (r['status'] == "Approved" ? Colors.green : Colors.red);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 🆔 ID + STATUS
          Row(
            children: [
              Text(
                r['id'],
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              _statusBadge(r['status'], statusColor),
            ],
          ),

          const SizedBox(height: 12),

          /// 🏪 DONOR INFO
          _infoRow(Icons.storefront, r['donor']),
          _infoRow(Icons.location_on, r['location']),

          const SizedBox(height: 8),

          /// 🍽️ MEALS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: mainGreen.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "${r['meals']} meals requested",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: mainGreen,
              ),
            ),
          ),

          if (pending) ...[
            const SizedBox(height: 16),

            /// ✅ ACTIONS
            Row(
              children: [
                _actionButton(
                  label: "Reject",
                  color: Colors.red.shade600,
                  onTap: () {
                    setState(() => r['status'] = "Rejected");
                  },
                ),
                const SizedBox(width: 12),
                _actionButton(
                  label: "Approve",
                  color: mainGreen,
                  onTap: () {
                    setState(() => r['status'] = "Approved");
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ───────────── STATUS BADGE ─────────────

  Widget _statusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // ───────────── INFO ROW ─────────────

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────── ACTION BUTTON ─────────────

  Widget _actionButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: SizedBox(
        height: 44,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
          onPressed: onTap,
          child: Text(label),
        ),
      ),
    );
  }
}
