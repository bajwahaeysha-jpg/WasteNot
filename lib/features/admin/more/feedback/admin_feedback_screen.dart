import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wastenot/core/constants/app_colors.dart';
import 'package:wastenot/services/firestore_service.dart';

import 'feedback_detail_screen.dart';
import 'feedback_model.dart';

class AdminFeedbackScreen extends StatelessWidget {
  const AdminFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Feedback',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.primary,
      ),
      body: StreamBuilder<List<FeedbackModel>>(
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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: feedbacks.length,
            itemBuilder: (context, index) {
              final feedback = feedbacks[index];
              return _FeedbackCard(feedback: feedback);
            },
          );
        },
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.feedback});

  final FeedbackModel feedback;

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _ProfileAvatar(
                  name: feedback.complainantName,
                  imageUrl: feedback.complainantProfileImage,
                  radius: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedback.complainantName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '${feedback.complainantRoleLabel} submitted feedback about ${feedback.targetRoleLabel.toLowerCase()}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatTimestamp(feedback.timestamp),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7F6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  _ProfileAvatar(
                    name: feedback.complaintTargetName,
                    imageUrl: feedback.complaintTargetProfileImage,
                    radius: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      feedback.complaintTargetName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              feedback.feedbackText,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(height: 1.4),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ...List.generate(
                  5,
                  (index) => Icon(
                    index < feedback.rating ? Icons.star : Icons.star_border,
                    color: Colors.amber.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${feedback.rating}/5',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime value) {
    return DateFormat('MMM d, yyyy - h:mm a').format(value);
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.name,
    required this.radius,
    this.imageUrl,
  });

  final String name;
  final String? imageUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
      backgroundImage:
          imageUrl != null && imageUrl!.isNotEmpty ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null || imageUrl!.isEmpty
          ? Text(
              initials.isEmpty ? 'WN' : initials,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: radius * 0.6,
              ),
            )
          : null,
    );
  }
}
