import 'package:flutter/material.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {

  static const Color mainGreen = Color(0xFF0E5E53);

  String? selectedNgo;

  int rating = 0;

  final TextEditingController feedbackController = TextEditingController();

  final List<String> ngoList = [
    "Green Hands Foundation",
    "Hope For Life",
    "Helping Souls",
    "Save Earth NGO",
    "Children First",
    "Water For All",
    "Care & Share",
    "Plant Pakistan"
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        backgroundColor: mainGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Feedback",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(
              "Select NGO",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(

              value: selectedNgo,

              hint: const Text("Choose NGO"),

              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),

              items: ngoList.map((ngo) {

                return DropdownMenuItem(
                  value: ngo,
                  child: Text(ngo),
                );

              }).toList(),

              onChanged: (value) {

                setState(() {
                  selectedNgo = value;
                });

              },
            ),

            const SizedBox(height: 25),

            const Text(
              "Write Feedback",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(

              controller: feedbackController,
              maxLines: 4,

              decoration: InputDecoration(

                hintText: "Write your feedback here...",

                filled: true,
                fillColor: Colors.grey.shade100,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Rate NGO",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: List.generate(5, (index) {

                return IconButton(

                  icon: Icon(
                    Icons.star,
                    size: 34,
                    color: index < rating
                        ? Colors.amber
                        : Colors.grey,
                  ),

                  onPressed: () {

                    setState(() {
                      rating = index + 1;
                    });

                  },
                );
              }),
            ),

            const SizedBox(height: 30),

            SizedBox(

              width: double.infinity,
              height: 50,

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor: mainGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),

                onPressed: () {

                  if (selectedNgo == null) {

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please select an NGO"),
                      ),
                    );

                    return;
                  }

                  if (feedbackController.text.isEmpty) {

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please write feedback"),
                      ),
                    );

                    return;
                  }

                  if (rating == 0) {

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please give rating"),
                      ),
                    );

                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Feedback Submitted"),
                    ),
                  );
                },

                child: const Text(
                  "Submit Feedback",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
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