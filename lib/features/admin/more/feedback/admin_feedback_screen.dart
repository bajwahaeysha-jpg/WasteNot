import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wastenot/core/constants/app_colors.dart';
import 'package:wastenot/services/firestore_service.dart';

import 'feedback_detail_screen.dart';
import 'feedback_model.dart';

class AdminFeedbackScreen extends StatefulWidget {
  const AdminFeedbackScreen({super.key});

  @override
  State<AdminFeedbackScreen> createState() => _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState extends State<AdminFeedbackScreen> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FeedbackModel> _filterFeedbacks(List<FeedbackModel> feedbacks) {
    if (_searchQuery.trim().isEmpty) return feedbacks;

    final query = _searchQuery.trim().toLowerCase();

    return feedbacks.where((feedback) {
      return feedback.senderName.toLowerCase().contains(query);
    }).toList();
  }

  Map<String, List<FeedbackModel>> _groupFeedbacksByDay(
    List<FeedbackModel> feedbacks,
  ) {
    final Map<String, List<FeedbackModel>> grouped = {};

    for (final feedback in feedbacks) {
      final key = _getDayLabel(feedback.timestamp);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(feedback);
    }

    return grouped;
  }

  String _getDayLabel(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final feedbackDay = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (feedbackDay == today) return 'Today';
    if (feedbackDay == yesterday) return 'Yesterday';
    return DateFormat('d/MM/yyyy').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F4),
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text(
          'Feedback',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search sender...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF9A9A9A),
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF7B7B7B),
                    size: 22,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          icon: const Icon(
                            Icons.close,
                            color: Color(0xFF7B7B7B),
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<FeedbackModel>>(
              stream: firestoreService.feedbackStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Could not load feedback right now.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting &&
                    snapshot.data == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                final feedbacks = snapshot.data ?? const <FeedbackModel>[];
                final filteredFeedbacks = _filterFeedbacks(feedbacks);

                if (feedbacks.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No feedback has been submitted yet.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  );
                }

                if (filteredFeedbacks.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No feedback found for this sender.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  );
                }

                final groupedFeedbacks = _groupFeedbacksByDay(filteredFeedbacks);
                final sectionKeys = groupedFeedbacks.keys.toList();

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: sectionKeys.length,
                  itemBuilder: (context, sectionIndex) {
                    final sectionKey = sectionKeys[sectionIndex];
                    final sectionItems = groupedFeedbacks[sectionKey]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 2,
                            bottom: 12,
                            left: 2,
                          ),
                          child: Text(
                            sectionKey,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1B1F1E),
                            ),
                          ),
                        ),
                        ...sectionItems.map(
                          (feedback) => _FeedbackCard(feedback: feedback),
                        ),
                        const SizedBox(height: 14),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.feedback});

  final FeedbackModel feedback;

  @override
  Widget build(BuildContext context) {
    final senderName = feedback.senderName.trim().isEmpty
        ? 'Unknown Sender'
        : feedback.senderName.trim();

    final targetName = feedback.targetName.trim().isEmpty
        ? 'Unknown User'
        : feedback.targetName.trim();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FeedbackDetailScreen(feedback: feedback),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              backgroundImage: feedback.senderProfileImage != null &&
                      feedback.senderProfileImage!.trim().isNotEmpty
                  ? NetworkImage(feedback.senderProfileImage!)
                  : null,
              child: (feedback.senderProfileImage == null ||
                      feedback.senderProfileImage!.trim().isEmpty)
                  ? Text(
                      _getInitials(senderName),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontSize: 16,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    senderName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1E1D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'About: $targetName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF9A9A9A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTimeOnly(feedback.timestamp),
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...List.generate(
                      5,
                      (index) => Padding(
                        padding: const EdgeInsets.only(left: 1),
                        child: Icon(
                          index < feedback.rating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 15.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      feedback.rating.toString(),
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5A5F5D),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .toList();

    if (parts.isEmpty) return 'WN';
    if (parts.length == 1) return parts.first[0].toUpperCase();

    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String _formatTimeOnly(DateTime timestamp) {
    return DateFormat('h:mm a').format(timestamp);
  }
}