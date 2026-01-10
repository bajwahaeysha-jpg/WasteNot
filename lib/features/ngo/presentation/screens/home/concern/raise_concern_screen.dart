import 'package:flutter/material.dart';
import 'package:wastenot/core/state/ngo_concern.dart';

class RaiseConcernScreen extends StatefulWidget {
  const RaiseConcernScreen({super.key});

  @override
  State<RaiseConcernScreen> createState() => _RaiseConcernScreenState();
}

class _RaiseConcernScreenState extends State<RaiseConcernScreen> {
  final TextEditingController _controller = TextEditingController();
  final int _limit = 120;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F4C45),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: false,
        title: const Text(
          "Raise a Concern",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
    body: SingleChildScrollView(
  padding: const EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      // Top Content
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Welcome 👋",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Here you can raise growing concerns that need immediate attention. "
            "Your voice is respected and every report helps us improve our impact.",
            style: TextStyle(
              fontSize: 15,
              color: Colors.black,
              height: 1.4,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Please note: you can only raise one concern at a time. "
            "Submitting a new concern will automatically delete the previous one.",
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ],
      ),

      const SizedBox(height: 20),

      const Text(
        "Write your concern",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black,
        ),
      ),
      const SizedBox(height: 8),

      TextField(
        controller: _controller,
        maxLength: _limit,
        maxLines: 4,
        style: const TextStyle(fontSize: 15, color: Colors.black),
        decoration: InputDecoration(
          hintText: "Describe the issue briefly...",
          hintStyle: const TextStyle(color: Colors.black54),
          counterStyle: const TextStyle(color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      const SizedBox(height: 12),

      Center(
        child: SizedBox(
          width: 180,
          height: 44,
          child: SizedBox(
  width: 180,
  height: 44,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF0F4C45), // app green
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
    ),
    onPressed: () {
      final text = _controller.text.trim();
      if (text.isEmpty) return;

      NgoConcern.currentConcern = text;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Your concern has been raised"),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    },
    child: const Text(
      "Send",
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
),

        ),
      ),
    ],
  ),
),

    );
  }
}
