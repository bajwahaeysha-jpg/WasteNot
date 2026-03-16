import 'package:flutter/material.dart';
import 'package:wastenot/services/goal_services.dart';
import 'package:wastenot/services/session_service.dart';

class DonorGoalScreen extends StatefulWidget {
  const DonorGoalScreen({super.key});

  @override
  State<DonorGoalScreen> createState() => _DonorGoalScreenState();
}

class _DonorGoalScreenState extends State<DonorGoalScreen> {
  static const Color mainGreen = Color(0xFF0E5E53);
  static const Color bgColor = Color(0xFFF6F7F7);
  static const Color cardColor = Colors.white;
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color mutedText = Color(0xFF6B7280);

  final TextEditingController controller = TextEditingController();
  final List<int> quickGoals = [400, 500, 750, 1000];
  final GoalService _goalService = GoalService();

  int selectedGoal = 150;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    controller.text = selectedGoal.toString();
  }

  void _selectGoal(int value) {
    setState(() {
      selectedGoal = value;
      controller.text = value.toString();
    });
  }

  Future<void> _saveGoal() async {
    final value = int.tryParse(controller.text.trim());

    if (value == null || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid monthly goal"),
        ),
      );
      return;
    }

    final donor = SessionService.user;
    if (donor == null || !donor.isDonor) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please log in as a donor to set a goal."),
        ),
      );
      return;
    }

    if (_isSaving) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _goalService.saveDonorGoal(
        donor: donor,
        monthlyTarget: value,
      );
      if (!mounted) {
        return;
      }
      Navigator.pop(context, value);
    } on GoalException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unable to save goal right now. Please try again."),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainGreen,
      appBar: AppBar(
        backgroundColor: mainGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Set Monthly Goal",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: bgColor,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "How much would you like to give monthly?",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Set a monthly meals target to stay consistent and increase your impact over time.",
                      style: TextStyle(
                        fontSize: 14.5,
                        color: mutedText,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 26),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: borderColor),
                      ),
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        onChanged: (value) {
                          final parsed = int.tryParse(value);
                          if (parsed != null && parsed > 0) {
                            setState(() {
                              selectedGoal = parsed;
                            });
                          }
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter monthly target",
                          hintStyle: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: quickGoals.map((goal) {
                        final isSelected = selectedGoal == goal;

                        return GestureDetector(
                          onTap: () => _selectGoal(goal),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeInOut,
                            width: 82,
                            height: 46,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? mainGreen : cardColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? mainGreen : borderColor,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: mainGreen.withOpacity(0.22),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Text(
                              "$goal",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F7F5),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFD9E8E3),
                        ),
                      ),
                      child: const Text(
                        "Start with a goal that feels realistic. Small, consistent donations can make a meaningful difference over the month.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 46,
                            width: 46,
                            decoration: BoxDecoration(
                              color: mainGreen.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.track_changes_rounded,
                              color: mainGreen,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Selected Monthly Goal",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: mutedText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "$selectedGoal meals",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            color: bgColor,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveGoal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Set Goal",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
