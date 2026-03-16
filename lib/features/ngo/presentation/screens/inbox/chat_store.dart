import 'package:wastenot/features/messaging/models/chat_models.dart';
import 'package:wastenot/features/messaging/services/messaging_service.dart';

typedef ChatMessage = ConversationMessage;

class ChatStore {
  static final MessagingService service = MessagingService();
}
