import 'package:flutter/material.dart';
import 'expire_reason_screen.dart';

class DonationProfileScreen extends StatefulWidget {
  final Map<String, dynamic> donation;
  const DonationProfileScreen({super.key, required this.donation});

  @override
  State<DonationProfileScreen> createState() =>
      _DonationProfileScreenState();
}

class _DonationProfileScreenState extends State<DonationProfileScreen> {
  late Map<String, dynamic> d;

  @override
  void initState() {
    super.initState();
    d = widget.donation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F5F54),
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "Donation Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [

          /// ───── DONATION IMAGES ─────
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: d['images']?.length ?? 1,
              itemBuilder: (context, index) {
                String img = d['images'] != null
                    ? d['images'][index]
                    : 'assets/images/food.jpg';
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      img,
                      width: 160,
                      height: 160,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          /// ───── STATUS ─────
          Row(
            children: [
              const Text(
                "Status:",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                d['status'],
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _statusColor(d['status']),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          /// ───── BASIC INFO CARD ─────
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _row("Donor", d['donor']),
                  _row("Accepted by", d['ngo'] ?? "Not yet accepted"),
                  if (d['uploadedAt'] != null) _row("Uploaded at", d['uploadedAt']),
                  if (d['acceptedAt'] != null) _row("Accepted at", d['acceptedAt']),
                  if (d['pickedAt'] != null) _row("Picked up at", d['pickedAt']),
                ],
              ),
            ),
          ),

          const SizedBox(height: 26),

          /// ───── DONATION DETAILS CARD ─────
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Donation Details",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _row("Food", d['items']),
                  _row("Servings", d['quantity'].toString()),
                  if (d['status'] == "Expired" && d['expireReason'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        "Expired Reason:\n${d['expireReason']}",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 26),

          /// ───── ADMIN ACTIONS ─────
          if (d['status'] == "Active")
            _actionText(
              "Mark as Expired",
              color: Colors.red,
              onTap: _openExpireReason,
            ),

          if (d['status'] == "Pending")
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                "Waiting for NGO to accept donation",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ───────── HELPERS ─────────

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black54,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Completed":
        return Colors.green;
      case "Expired":
        return Colors.red;
      case "Active":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _actionText(
    String text, {
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color ?? const Color(0xFF0F5F54),
          ),
        ),
      ),
    );
  }

  Future<void> _openExpireReason() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExpireReasonScreen(donation: d),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        d['status'] = "Expired";
        d['expireReason'] = result['reason'];
      });
    }
  }
}