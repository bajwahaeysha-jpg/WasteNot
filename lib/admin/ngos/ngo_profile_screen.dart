import 'package:flutter/material.dart';

class NGOProfileScreen extends StatefulWidget {
  final Map ngo;
  const NGOProfileScreen({super.key, required this.ngo});

  @override
  State<NGOProfileScreen> createState() => _NGOProfileScreenState();
}

class _NGOProfileScreenState extends State<NGOProfileScreen> {
  late bool isApproved;

  final List<Map> activityTimeline = [
    {"title": "Food received", "time": "Today, 10:30 AM"},
    {"title": "Pickup completed", "time": "Yesterday, 5:15 PM"},
    {"title": "Warning issued", "time": "2 days ago"},
    {"title": "New donation assigned", "time": "3 days ago"},
  ];

  final List<Map> deliveryHistory = [
    {"id": "#D101", "status": "Delivered", "date": "12 Jun"},
    {"id": "#D102", "status": "Delivered", "date": "11 Jun"},
    {"id": "#D103", "status": "Delayed", "date": "10 Jun"},
  ];

  @override
  void initState() {
    super.initState();
    isApproved = widget.ngo['status'] == "Approved";
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.ngo;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F5F54),
        elevation: 0,
        title: Text(
          n['name'],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(_infoSection(n)),
          const SizedBox(height: 16),
          _card(_performanceSection()),
          const SizedBox(height: 16),
          _card(_activityTimeline()),
          const SizedBox(height: 16),
          _card(_adminActions()),
        ],
      ),
    );
  }

  // ───────────── INFO ─────────────

  Widget _infoSection(Map n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow("Location", n['location']),
        _infoRow("Meals Received", "${n['mealsReceived']}"),
        _infoRow("Success Rate", "${n['successRate']}%"),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────── PERFORMANCE OVERVIEW ─────────────

  Widget _performanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Performance Overview",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        SizedBox(height: 10),
        _PerformanceItem("On-time deliveries", "87%"),
        _PerformanceItem("Complaint ratio", "3%"),
        _PerformanceItem("Beneficiaries served", "4,500+"),
      ],
    );
  }

  // ───────────── ACTIVITY TIMELINE ─────────────

  Widget _activityTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "NGO Activity Timeline",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: 12),
        ...activityTimeline.map(
          (a) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F5F54).withValues(alpha:0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.timeline,
                    size: 16,
                    color: Color(0xFF0F5F54),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a['title'],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        a['time'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ───────────── ADMIN ACTIONS ─────────────

  Widget _adminActions() {
    return Column(
      children: [
        SwitchListTile(
          inactiveThumbColor: const Color(0xFF0F5F54),
          value: isApproved,
          onChanged: (v) => setState(() => isApproved = v),
          title: Text(
            isApproved ? "Approved" : "Suspended",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 16),

        _centerButton(
          icon: Icons.warning_amber_rounded,
          label: "Issue Warning",
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Warning issued to NGO")),
          ),
        ),

        const SizedBox(height: 12),

        _centerButton(
          icon: Icons.history,
          label: "View Delivery History",
          onTap: _openDeliveryHistory,
        ),
      ],
    );
  }

  Widget _centerButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 220,
      height: 44,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F5F54),
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }

  // ───────────── DELIVERY HISTORY ─────────────

  void _openDeliveryHistory() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: deliveryHistory
              .map(
                (d) => ListTile(
                  leading: const Icon(
                    Icons.local_shipping,
                    color: Color(0xFF0F5F54),
                  ),
                  title: Text(d['id']),
                  subtitle: Text("${d['status']} • ${d['date']}"),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  // ───────────── CARD ─────────────

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

/// 🔹 PERFORMANCE ITEM
class _PerformanceItem extends StatelessWidget {
  final String label;
  final String value;
  const _PerformanceItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
