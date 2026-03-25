import 'package:flutter/material.dart';
import 'package:wastenot/features/messaging/models/chat_models.dart';
import 'package:wastenot/features/messaging/services/messaging_service.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/services/chat_privacy_service.dart';
import 'package:wastenot/services/session_service.dart';

import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  final String donorName;

  const MessagesScreen({super.key, required this.donorName});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {

  final MessagingService _messagingService = MessagingService();
  final ChatPrivacyService _privacyService = ChatPrivacyService();
  final TextEditingController _searchController = TextEditingController();

  final List<Color> _softColors = const [
    Color(0xFFFFE0E0),
    Color(0xFFE0F0FF),
    Color(0xFFE6FFE8),
  ];

  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime? time) {
    if (time == null) {
      return '';
    }

    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inMinutes < 1) {
      return 'Now';
    }
    if (difference.inHours < 24) {
      return difference.inHours == 0 ? '${difference.inMinutes}m' : '${difference.inHours}h';
    }
    if (difference.inDays == 1) {
      return 'Yesterday';
    }
    return '${difference.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = SessionService.user;
    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      body: StreamBuilder<List<AppUserModel>>(
        stream: _messagingService.usersForRole('ngo'),
        builder: (context, userSnapshot) {
          final ngos = (userSnapshot.data ?? const <AppUserModel>[])
              .where((user) => user.uid != currentUser.uid)
              .toList();

          return StreamBuilder<List<ConversationSummary>>(
            stream: _messagingService.conversationsForUser(currentUser.uid),
            builder: (context, conversationSnapshot) {
              final conversations =
                  conversationSnapshot.data ?? const <ConversationSummary>[];
              final tiles = _buildTiles(
                currentUser: currentUser,
                ngos: ngos,
                conversations: conversations,
              );

              return Column(
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _searchQuery = value.trim().toLowerCase()),
                        decoration: const InputDecoration(
                          hintText: 'Search conversation...',
                          border: InputBorder.none,
                          icon: Icon(Icons.search),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: tiles.isEmpty
                        ? const Center(child: Text('No NGOs found.'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: tiles.length,
                            itemBuilder: (context, index) {
                              final item = tiles[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: _softColors[index % _softColors.length],
                                    backgroundImage: item.user.profileImageUrl != null &&
                                            item.user.profileImageUrl!.isNotEmpty
                                        ? NetworkImage(item.user.profileImageUrl!)
                                        : null,
                                    child: (item.user.profileImageUrl == null ||
                                            item.user.profileImageUrl!.isEmpty)
                                        ? Text(
                                            item.user.displayName.isEmpty
                                                ? 'N'
                                                : item.user.displayName[0].toUpperCase(),
                                            style: const TextStyle(color: Colors.black),
                                          )
                                        : null,
                                  ),
                                  title: Text(
                                    item.user.displayName,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    item.preview.isEmpty ? 'Tap to start conversation' : item.preview,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: SizedBox(
                                    width: 52,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          _formatTime(item.previewTime),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        if (item.unreadCount > 0) ...[
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 7,
                                              vertical: 2,
                                            ),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              borderRadius: BorderRadius.all(Radius.circular(12)),
                                            ),
                                            child: Text(
                                              item.unreadCount > 99
                                                  ? '99+'
                                                  : item.unreadCount.toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  onTap: () {
                                    _openChat(item.user);
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openChat(AppUserModel peerUser) async {
    final allowed = await _privacyService.canSendMessage(peerUser.uid);
    if (!allowed) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This user has disabled direct messages')),
      );
      return;
    }

    if (!mounted) {
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(ngoUser: peerUser),
      ),
    );
  }

  List<_MessageListItem> _buildTiles({
    required AppUserModel currentUser,
    required List<AppUserModel> ngos,
    required List<ConversationSummary> conversations,
  }) {
    final conversationByPeerId = <String, ConversationSummary>{};
    for (final conversation in conversations) {
      final peerId = conversation.otherParticipantId(currentUser.uid);
      if (peerId.isNotEmpty) {
        conversationByPeerId[peerId] = conversation;
      }
    }

    final filtered = ngos.where((user) {
      return _searchQuery.isEmpty ||
          user.displayName.toLowerCase().contains(_searchQuery);
    }).toList();

    filtered.sort((a, b) {
      final aConversation = conversationByPeerId[a.uid];
      final bConversation = conversationByPeerId[b.uid];
      final aTime = aConversation?.updatedAt ?? aConversation?.previewTimeFor(currentUser.uid);
      final bTime = bConversation?.updatedAt ?? bConversation?.previewTimeFor(currentUser.uid);

      if (aTime != null && bTime != null) {
        return bTime.compareTo(aTime);
      }
      if (aTime != null) {
        return -1;
      }
      if (bTime != null) {
        return 1;
      }
      return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
    });

    return filtered.map((user) {
      final conversation = conversationByPeerId[user.uid];
      return _MessageListItem(
        user: user,
        preview: conversation?.previewFor(currentUser.uid) ?? '',
        previewTime: conversation?.previewTimeFor(currentUser.uid),
        unreadCount: conversation?.unreadFor(currentUser.uid) ?? 0,
      );
    }).toList();
  }
}

class _MessageListItem {
  const _MessageListItem({
    required this.user,
    required this.preview,
    required this.previewTime,
    required this.unreadCount,
  });

  final AppUserModel user;
  final String preview;
  final DateTime? previewTime;
  final int unreadCount;
}
