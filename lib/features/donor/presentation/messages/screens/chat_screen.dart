import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wastenot/features/messaging/models/chat_models.dart';
import 'package:wastenot/features/messaging/services/messaging_service.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/services/session_service.dart';

class ChatScreen extends StatefulWidget {
  final String donorName;
  final String ngoName;
  final AppUserModel? ngoUser;
  final ConcernChatReference? concernReference;

  const ChatScreen({
    super.key,
    this.donorName = '',
    this.ngoName = '',
    this.ngoUser,
    this.concernReference,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessagingService _messagingService = MessagingService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Set<String> _selectedIds = <String>{};

  late final Future<AppUserModel?> _peerFuture;
  bool _isSending = false;
  bool _sentInitialReference = false;
  String? _markedConversationId;
  int _lastRenderedMessageCount = 0;

  bool get _isSelecting => _selectedIds.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _peerFuture = widget.ngoUser != null
        ? Future.value(widget.ngoUser)
        : _messagingService.findUserByDisplayNameAndRole(widget.ngoName, 'ngo');
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage({
    required AppUserModel currentUser,
    required AppUserModel peerUser,
  }) async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) {
      return;
    }

    setState(() => _isSending = true);

    try {
      await _messagingService.sendMessage(
        sender: currentUser,
        receiver: peerUser,
        text: text,
      );
      _controller.clear();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message could not be sent.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _showSelectionActions({
    required String conversationId,
    required List<ConversationMessage> messages,
    required String currentUserId,
  }) async {
    final selectedMessages = messages
        .where((message) => _selectedIds.contains(message.id))
        .toList();
    if (selectedMessages.isEmpty) {
      return;
    }

    final canUnsend =
        selectedMessages.every((message) => message.senderId == currentUserId);

    final action = await showDialog<_SelectedAction>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Message actions'),
          content: const Text('Choose what you want to do with the selected messages.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, _SelectedAction.cancel),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, _SelectedAction.deleteForMe),
              child: const Text('Delete for me'),
            ),
            if (canUnsend)
              TextButton(
                onPressed: () => Navigator.pop(context, _SelectedAction.unsend),
                child: const Text('Unsend'),
              ),
          ],
        );
      },
    );

    if (action == null || action == _SelectedAction.cancel) {
      if (mounted) {
        setState(() => _selectedIds.clear());
      }
      return;
    }

    try {
      for (final message in selectedMessages) {
        if (action == _SelectedAction.deleteForMe) {
          await _messagingService.deleteForMe(
            conversationId: conversationId,
            messageId: message.id,
            currentUserId: currentUserId,
          );
        } else if (action == _SelectedAction.unsend) {
          await _messagingService.unsendMessage(
            conversationId: conversationId,
            message: message,
            currentUserId: currentUserId,
          );
        }
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Action could not be completed.')),
      );
    }

    if (mounted) {
      setState(() => _selectedIds.clear());
    }
  }

  void _maybeSendConcernReference({
    required AppUserModel currentUser,
    required AppUserModel peerUser,
  }) {
    final reference = widget.concernReference;
    if (reference == null || _sentInitialReference) {
      return;
    }

    _sentInitialReference = true;
    _messagingService
        .ensureConcernReferenceSent(
          sender: currentUser,
          receiver: peerUser,
          reference: reference,
        )
        .catchError((_) {});
  }

  Widget _concernContextBanner(ConcernChatReference reference) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x220E5E53)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              reference.concernImageUrl,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 44,
                height: 44,
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported, size: 18),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Contacting regarding this concern',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF0E5E53),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reference.concernTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageContent(ConversationMessage message) {
    if (message.type == 'concern_reference' && message.concernReference != null) {
      final reference = message.concernReference!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.campaign, size: 16, color: Colors.black54),
              SizedBox(width: 6),
              Text(
                'Concern',
                style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              reference.concernImageUrl,
              width: 160,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 160,
                height: 90,
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            reference.concernTitle,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          if (message.text.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              message.text,
              style: const TextStyle(color: Colors.black87),
            ),
          ],
        ],
      );
    }

    return Text(message.text);
  }

  bool _isSameDay(DateTime? first, DateTime? second) {
    if (first == null || second == null) {
      return false;
    }
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  Widget _dayHeader(DateTime time) {
    final now = DateTime.now();
    String text;

    if (_isSameDay(time, now)) {
      text = 'Today';
    } else if (_isSameDay(time, now.subtract(const Duration(days: 1)))) {
      text = 'Yesterday';
    } else {
      text = DateFormat('d/M/y').format(time);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(text, style: const TextStyle(fontSize: 12)),
        ),
      ),
    );
  }

  String _timeOnly(DateTime? time) {
    if (time == null) {
      return '';
    }
    return DateFormat('h:mm a').format(time);
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  void _markConversationRead(String conversationId, String currentUserId) {
    if (_markedConversationId == conversationId) {
      return;
    }
    _markedConversationId = conversationId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _messagingService.markConversationAsRead(
        conversationId: conversationId,
        currentUserId: currentUserId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = SessionService.user;
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return FutureBuilder<AppUserModel?>(
      future: _peerFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F7F6),
            appBar: AppBar(
              backgroundColor: const Color(0xFF0E5E53),
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text(
                widget.ngoName.isEmpty ? 'Chat' : widget.ngoName,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final peerUser = snapshot.data;
        if (peerUser == null) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFF0E5E53),
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text(
                widget.ngoName.isEmpty ? 'Chat' : widget.ngoName,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            body: const Center(child: Text('NGO not found.')),
          );
        }

        final conversationId = _messagingService.conversationIdFor(
          currentUser.uid,
          peerUser.uid,
        );
        _maybeSendConcernReference(currentUser: currentUser, peerUser: peerUser);
        _markConversationRead(conversationId, currentUser.uid);

        return StreamBuilder<List<ConversationMessage>>(
          stream: _messagingService.messagesForConversation(
            conversationId,
            currentUser.uid,
          ),
          builder: (context, messageSnapshot) {
            final messages = messageSnapshot.data ?? const <ConversationMessage>[];

            if (messages.length != _lastRenderedMessageCount) {
              _lastRenderedMessageCount = messages.length;
              WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
            }

            return Scaffold(
              backgroundColor: const Color(0xFFF5F7F6),
              appBar: AppBar(
                backgroundColor: const Color(0xFF0E5E53),
                iconTheme: const IconThemeData(color: Colors.white),
                title: _isSelecting
                    ? Text(
                        '${_selectedIds.length} selected',
                        style: const TextStyle(color: Colors.white),
                      )
                    : Text(
                        peerUser.displayName,
                        style: const TextStyle(color: Colors.white),
                      ),
                actions: _isSelecting
                    ? [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
                          onPressed: () => _showSelectionActions(
                            conversationId: conversationId,
                            messages: messages,
                            currentUserId: currentUser.uid,
                          ),
                        ),
                      ]
                    : [],
              ),
              body: Column(
                children: [
                  if (widget.concernReference != null)
                    _concernContextBanner(widget.concernReference!),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: messages.length,
                      itemBuilder: (_, index) {
                        final message = messages[index];
                        final previousTime = index == 0 ? null : messages[index - 1].sentAt;
                        final showHeader = index == 0 || !_isSameDay(message.sentAt, previousTime);
                        final fromPeer = message.senderId == peerUser.uid;
                        final selected = _selectedIds.contains(message.id);

                        return Column(
                          children: [
                            if (showHeader && message.sentAt != null) _dayHeader(message.sentAt!),
                            GestureDetector(
                              onLongPress: () {
                                setState(() => _selectedIds.add(message.id));
                              },
                              onTap: () {
                                if (_isSelecting) {
                                  setState(() {
                                    if (selected) {
                                      _selectedIds.remove(message.id);
                                    } else {
                                      _selectedIds.add(message.id);
                                    }
                                  });
                                }
                              },
                              child: Align(
                                alignment: fromPeer
                                    ? Alignment.centerLeft
                                    : Alignment.centerRight,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? Colors.green.withValues(alpha: 0.35)
                                        : fromPeer
                                            ? Colors.white
                                            : const Color(0xFFDCF8C6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: IntrinsicWidth(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _messageContent(message),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              _timeOnly(message.sentAt),
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            if (!fromPeer && !message.hasPendingWrites) ...[
                                              const SizedBox(width: 4),
                                              const Icon(
                                                Icons.check,
                                                size: 14,
                                                color: Colors.black54,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade200,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: const Color(0xFF0E5E53),
                          child: IconButton(
                            icon: _isSending
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.send, color: Colors.white),
                            onPressed: _isSending
                                ? null
                                : () => _sendMessage(
                                      currentUser: currentUser,
                                      peerUser: peerUser,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

enum _SelectedAction {
  cancel,
  deleteForMe,
  unsend,
}
