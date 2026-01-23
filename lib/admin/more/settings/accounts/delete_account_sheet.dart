import 'package:flutter/material.dart';

class DeleteAccountSheet extends StatelessWidget {
  const DeleteAccountSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        Row(
          children: [
            const Text(
              "Delete account",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ],
        ),

        const SizedBox(height: 12),

        const Text(
          "You will lose access to all your data and settings. "
          "This action can’t be undone. Are you sure you want to delete your account?",
          style: TextStyle(color: Colors.black54),
        ),

        const SizedBox(height: 24),

        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            side: const BorderSide(color: Colors.red),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            "Yes, delete my account",
            style: TextStyle(color: Colors.red),
          ),
        ),

        const SizedBox(height: 12),

        ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
          onPressed: () => Navigator.pop(context),
          child: const Text("No"),
        ),
      ]),
    );
  }
}
