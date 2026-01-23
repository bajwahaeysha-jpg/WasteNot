import 'package:flutter/material.dart';

class DonationProfileScreen extends StatelessWidget {
  final Map donation;
  const DonationProfileScreen({super.key, required this.donation});

  @override
  Widget build(BuildContext context) {
    final d = donation;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F5F54),
        elevation: 0,
        title: const Text(
          "Donation Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(_details(d)),
          const SizedBox(height: 16),
          _card(_statusSection(d)),
          const SizedBox(height: 16),
          _card(_adminActions(context, d)),
        ],
      ),
    );
  }

  // ───────────── Details ─────────────

  Widget _details(Map d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _row("Donation ID", d['id']),
        _row("Donor", d['donor']),
        _row("NGO", d['ngo']),
        _row("Items", d['items']),
        _row("Meals", d['quantity']),
        _row("Date", d['date']),
      ],
    );
  }

  Widget _row(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              "$title:",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.toString(),
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────── Status Section ─────────────

  Widget _statusSection(Map d) {
    double progress = d['status'] == "Delivered"
        ? 1
        : d['status'] == "In Transit"
            ? 0.6
            : 0.25;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Delivery Status",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          d['status'],
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            color: const Color(0xFF0F5F54),
            backgroundColor: Colors.grey.shade200,
          ),
        ),
      ],
    );
  }

  // ───────────── Admin Actions ─────────────

  Widget _adminActions(BuildContext context, Map d) {
    return Column(
      children: [
        _centerButton(
          color: const Color(0xFF0F5F54),
          icon: Icons.visibility,
          label: "Track Delivery",
          onTap: () => _showLiveTracking(context, d),
        ),
        const SizedBox(height: 12),
        _centerButton(
          color: const Color(0xFFD32F2F),
          icon: Icons.cancel,
          label: "Mark as Expired",
          onTap: () => _confirmExpire(context, d),
        ),
      ],
    );
  }

  Widget _centerButton({
    required Color color,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 220, // 🔹 smaller & centered
      height: 46,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ───────────── Live Tracking ─────────────

  void _showLiveTracking(BuildContext context, Map d) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Live Delivery Tracking",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            ListTile(
              leading: const Icon(Icons.location_on,
                  color: Color(0xFF0F5F54)),
              title: const Text("Driver is en route"),
              subtitle: Text("Donation ID: ${d['id']}"),
            ),
            const ListTile(
              leading: Icon(Icons.timer, color: Color(0xFF0F5F54)),
              title: Text("Estimated Arrival"),
              subtitle: Text("18 minutes"),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────── Expire Confirmation ─────────────

  void _confirmExpire(BuildContext context, Map d) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          "Mark as Expired",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFD32F2F),
          ),
        ),
        content: const Text(
          "This donation will be moved to expired records.",
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              d['status'] = "Expired"; // ✅ status updates
              Navigator.pop(context);
              Navigator.pop(context, true); // ✅ back to list
            },
            child: const Text(
              "Confirm",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────── Card Wrapper ─────────────

  Widget _card(Widget child) {
    return Container(
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
      child: child,
    );
  }
}
