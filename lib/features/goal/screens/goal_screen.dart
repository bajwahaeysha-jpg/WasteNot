import 'package:flutter/material.dart';
import 'package:wastenot/features/goal/models/goal_model.dart';
import 'package:wastenot/features/goal/services/goal_service.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/services/session_service.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({
    super.key,
    required this.unitLabel,
    required this.quickTargets,
    required this.themeColor,
  });

  factory GoalScreen.donor() {
    return const GoalScreen(
      unitLabel: 'donations',
      quickTargets: <int>[5, 10, 15, 20],
      themeColor: Color(0xFF0B4B3F),
    );
  }

  factory GoalScreen.ngo() {
    return const GoalScreen(
      unitLabel: 'meals',
      quickTargets: <int>[250, 450, 750, 1000],
      themeColor: Color(0xFF0B4B3F),
    );
  }

  final String unitLabel;
  final List<int> quickTargets;
  final Color themeColor;

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  final GoalService _goalService = GoalService();
  final TextEditingController _targetController = TextEditingController();

  MonthlyGoalRecord? _existingGoal;
  bool _isLoading = true;
  bool _isSaving = false;
  int _selectedTarget = 0;

  AppUserModel? get _user => SessionService.user;

  bool get _isNgo => _user?.isNgo == true;

  @override
  void initState() {
    super.initState();
    _selectedTarget = widget.quickTargets.first;
    _targetController.text = _selectedTarget.toString();
    _loadGoal();
  }

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _loadGoal() async {
    final user = _user;
    if (user == null || (!user.isDonor && !user.isNgo)) {
      if (!mounted) {
        return;
      }
      setState(() => _isLoading = false);
      return;
    }

    final goal = await _goalService.fetchCurrentMonthGoal(user: user);
    if (!mounted) {
      return;
    }

    setState(() {
      _existingGoal = goal;
      _isLoading = false;
      if (goal != null) {
        _selectedTarget = goal.target;
        _targetController.text = goal.target.toString();
      }
    });
  }

  Future<void> _saveGoal() async {
    final user = _user;
    final target = int.tryParse(_targetController.text.trim());

    if (user == null || (!user.isDonor && !user.isNgo)) {
      _showMessage('Please log in again to set your goal.');
      return;
    }
    if (target == null || target <= 0) {
      _showMessage('Please enter a valid monthly target.');
      return;
    }
    if (_isSaving) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _goalService.saveCurrentMonthGoal(
        user: user,
        target: target,
      );
      if (!mounted) {
        return;
      }
      Navigator.pop(context, true);
    } on GoalException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('Unable to save goal right now. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _selectTarget(int value) {
    setState(() {
      _selectedTarget = value;
      _targetController.text = value.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = _goalService.currentMonthLabel();
    final noun = _isNgo ? 'NGO' : 'donor';

    return Scaffold(
      backgroundColor: widget.themeColor,
      appBar: AppBar(
        backgroundColor: widget.themeColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Set Monthly Goal',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF6F7F7),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Set your $noun target for $monthLabel.',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'This goal is locked to the current calendar month and progress is calculated from completed ${widget.unitLabel}.',
                      style: const TextStyle(
                        fontSize: 14.5,
                        color: Color(0xFF6B7280),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _InfoCard(
                      title: 'Goal Month',
                      value: monthLabel,
                      subtitle:
                          'If you set a goal mid-month, it still applies only to this calendar month.',
                    ),
                    const SizedBox(height: 18),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_existingGoal != null) ...[
                      _InfoCard(
                        title: 'Goal Locked',
                        value: '${_existingGoal!.target} ${widget.unitLabel}',
                        subtitle:
                            'This month already has a goal. You can set a new one when the next month starts.',
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: TextField(
                          controller: _targetController,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final parsed = int.tryParse(value);
                            if (parsed != null && parsed > 0) {
                              setState(() => _selectedTarget = parsed);
                            }
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter target ${widget.unitLabel}',
                          ),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: widget.quickTargets.map((target) {
                          final isSelected = _selectedTarget == target;
                          return GestureDetector(
                            onTap: () => _selectTarget(target),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 88,
                              height: 46,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? widget.themeColor
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? widget.themeColor
                                      : const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Text(
                                '$target',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F7F5),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFD9E8E3)),
                        ),
                        child: Text(
                          'Progress counts only completed ${widget.unitLabel}. Editing is disabled after saving and the next goal becomes available on the first day of the next month.',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _InfoCard(
                        title: 'Selected Target',
                        value: '$_selectedTarget ${widget.unitLabel}',
                        subtitle:
                            'Choose carefully. This target is fixed for the rest of the month.',
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Container(
            color: const Color(0xFFF6F7F7),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading || _isSaving || _existingGoal != null
                      ? null
                      : _saveGoal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.themeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _existingGoal != null ? 'Goal Already Set' : 'Set Goal',
                    style: const TextStyle(
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
