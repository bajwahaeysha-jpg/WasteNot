import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wastenot/core/constants/app_colors.dart';
import 'package:wastenot/services/firestore_service.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F4),
      appBar: AppBar(
        title: const Text(
          'Feedback',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [

          /// 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                decoration: const InputDecoration(
                  hintText: 'Search sender...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          /// 📋 LIST
          Expanded(
            child: StreamBuilder<List<FeedbackModel>>(
              stream: firestoreService.feedbackStream(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final feedbacks = _filterFeedbacks(snapshot.data!);

                if (feedbacks.isEmpty) {
                  return const Center(child: Text("No feedback found"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: feedbacks.length,
                  itemBuilder: (context, index) {
                    return _FeedbackCard(feedback: feedbacks[index]);
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

class _FeedbackCard extends StatefulWidget {
  const _FeedbackCard({required this.feedback});

  final FeedbackModel feedback;

  @override
  State<_FeedbackCard> createState() => _FeedbackCardState();
}

class _FeedbackCardState extends State<_FeedbackCard> {

  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final feedback = widget.feedback;

    final senderName = feedback.senderName.trim().isEmpty
        ? 'Unknown Sender'
        : feedback.senderName;

    final targetName = feedback.targetName.trim().isEmpty
        ? 'Unknown User'
        : feedback.targetName;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
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

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 👤 TOP SECTION
          Row(
            children: [
              _ProfileAvatar(
                name: senderName,
                imageUrl: feedback.senderProfileImage,
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      senderName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "About: $targetName",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                DateFormat('h:mm a').format(feedback.timestamp),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// ⭐ RATING
          Row(
            children: [
              ...List.generate(
                5,
                (index) => Icon(
                  index < feedback.rating
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                  size: 18,
                ),
              ),
              const SizedBox(width: 6),
              Text("${feedback.rating}"),
            ],
          ),

          const SizedBox(height: 10),

          /// 💬 TEXT WITH EXPAND
          Text(
            feedback.feedbackText,
            maxLines: isExpanded ? null : 3,
            overflow: isExpanded
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15.5,
              height: 1.5,
              color: Color(0xFF1A1E1D),
            ),
          ),

          /// 🔽 MORE / LESS
          if (feedback.feedbackText.length > 100)
            GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  isExpanded ? "Less" : "More",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 🔥 PROFILE AVATAR (FINAL SAFE VERSION)
class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.name,
    this.imageUrl,
  });

  final String name;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.trim().isNotEmpty
            ? Image.network(
                imageUrl!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,

                /// ✅ ERROR HANDLING
                errorBuilder: (context, error, stackTrace) {
                  return _buildInitials();
                },

                /// ✅ LOADING HANDLING
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return _buildInitials();
                },
              )
            : _buildInitials(),
      ),
    );
  }

  Widget _buildInitials() {
    return Center(
      child: Text(
        _getInitials(name),
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          fontSize: 16,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .take(2)
        .toList();

    if (parts.isEmpty) return 'WN';
    if (parts.length == 1) return parts[0][0].toUpperCase();

    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}