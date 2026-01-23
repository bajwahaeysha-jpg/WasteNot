import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddDonationScreen extends StatefulWidget {
  const AddDonationScreen({super.key});

  @override
  State<AddDonationScreen> createState() => _AddDonationScreenState();
}

class _AddDonationScreenState extends State<AddDonationScreen> {
  final ImagePicker _picker = ImagePicker();

  XFile? pickedImage;
  String? selectedServing;

  final foodController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  final precautionController = TextEditingController();

  final List<String> servingOptions = [
    "1 - 10",
    "10 - 20",
    "20 - 30",
    "30 - 40",
    "40 - 50",
    "More than 50",
  ];

  Future<void> pickImage() async {
    final img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (img != null) setState(() => pickedImage = img);
  }

  void showConfirmationPopup() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF5F7F6),
        title: const Text("Donation Submitted"),
        content: const Text(
          "Your donation is now visible to all registered NGOs and is ready to be accepted.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E5E53),
        title: const Text("Add Donation", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          const Text("Your surplus, someone's meal",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text("Together, we can turn your generosity into a meal that truly matters."),

          const SizedBox(height: 12),

          const Text("Food", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          _textField("What food are you donating?", foodController),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 120,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text("Location", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Expanded(child: _textField("Enter pickup location", locationController)),
                  ]),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: SizedBox(
                  height: 120,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text("Images", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Expanded(
                      child: GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: pickedImage == null
                              ? const Center(child: Icon(Icons.add_a_photo, size: 30))
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(File(pickedImage!.path),
                                      fit: BoxFit.cover, width: double.infinity),
                                ),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          const Text("Details", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          _servingDropdown(),

          const SizedBox(height: 10),

          const Text("Description"),
          const SizedBox(height: 4),
          _textArea(descriptionController, minLines: 2),

          const SizedBox(height: 8),

          const Text("Precaution"),
          const SizedBox(height: 4),
          _textArea(precautionController, minLines: 1),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E5E53),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: showConfirmationPopup,
              child: const Text("Continue", style: TextStyle(color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _textField(String hint, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(border: InputBorder.none, hintText: hint),
      ),
    );
  }

  Widget _textArea(TextEditingController controller, {required int minLines}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        minLines: minLines,
        maxLines: null,
        decoration: const InputDecoration(border: InputBorder.none, hintText: "Write here..."),
      ),
    );
  }

  Widget _servingDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedServing,
          hint: const Text("Select servings"),
          isExpanded: true,
          items: servingOptions
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) => setState(() => selectedServing = val),
        ),
      ),
    );
  }
}
