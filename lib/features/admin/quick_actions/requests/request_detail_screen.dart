import 'package:flutter/material.dart';

class RequestDetailScreen extends StatefulWidget {
  final Map<String, dynamic> request;
  final VoidCallback onDelete;

  const RequestDetailScreen({
    super.key,
    required this.request,
    required this.onDelete,
  });

  static const Color mainGreen = Color(0xFF0F4C45);

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {

  bool isAccepted = false;
  bool isRejected = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),

      appBar: AppBar(
        backgroundColor: RequestDetailScreen.mainGreen,
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

            /// 🖼 Logo
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(widget.request['logo']),
              backgroundColor: Colors.grey.shade200,
            ),

            const SizedBox(height: 20),

            /// Name
            Text(
              widget.request['name'],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            if (widget.request['business'] != null)
              Text(
                widget.request['business'],
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),

            if (widget.request['location'] != null)
              Text(
                widget.request['location'],
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),

            const SizedBox(height: 20),

            /// 📄 Info Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoRow("Email", widget.request['email']),
                    _infoRow("Phone", widget.request['phone']),
                    if (widget.request['location'] != null)
                      _infoRow("Location", widget.request['location']),
                    if (widget.request['business'] != null)
                      _infoRow("Business", widget.request['business']),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 35),

            /// ✅ ACCEPT / REJECT BUTTONS
            Row(
              children: [

                /// ACCEPT BUTTON
                Expanded(
                  child: ElevatedButton(
                    onPressed: isRejected
                        ? null
                        : () {

                            setState(() {
                              isAccepted = true;
                            });

                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Request Accepted"),
                                content: const Text(
                                  "Your request has been accepted.",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("OK"),
                                  )
                                ],
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RequestDetailScreen.mainGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Accept",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                /// REJECT BUTTON
                Expanded(
                  child: ElevatedButton(
                    onPressed: isAccepted
                        ? null
                        : () {
                            setState(() {
                              isRejected = true;
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Reject",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
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
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),

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