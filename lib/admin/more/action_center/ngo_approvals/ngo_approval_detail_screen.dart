import 'package:flutter/material.dart';

class NgoApprovalDetailScreen extends StatefulWidget {
  final String ngoName;

  const NgoApprovalDetailScreen({
    super.key,
    required this.ngoName,
  });

  @override
  State<NgoApprovalDetailScreen> createState() =>
      _NgoApprovalDetailScreenState();
}

class _NgoApprovalDetailScreenState
    extends State<NgoApprovalDetailScreen> {
  static const Color mainGreen = Color(0xFF0F5F54);

  final TextEditingController _reasonController =
      TextEditingController();

  void _handleAction(String action) async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          action == "approved"
              ? "Approval Reason"
              : "Rejection Reason",
        ),
        content: TextField(
          controller: _reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Enter reason...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, "confirm"),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );

    if (!mounted || result == null) return;

    bool undone = false;
    final messenger = ScaffoldMessenger.of(context);

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          "NGO ${action == "approved" ? "approved" : "rejected"}",
        ),
        duration: const Duration(seconds: 10),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: "UNDO",
          onPressed: () {
            undone = true;
          },
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 10));

    if (!mounted || undone) return;

    Navigator.pop(context, {
      "action": action,
      "reason": _reasonController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),

      appBar: AppBar(
        backgroundColor: mainGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "NGO Approval",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// 🏢 NGO Info
            Container(
              padding: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.ngoName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "This NGO has requested approval to operate on the platform.",
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const Text(
                    "Status: Pending Verification",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            /// ✅ / ❌ Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainGreen,
                      foregroundColor: Colors.white,
                      minimumSize:
                          const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _handleAction("approved"),
                    child: const Text(
                      "Approve",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      minimumSize:
                          const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _handleAction("rejected"),
                    child: const Text(
                      "Reject",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
