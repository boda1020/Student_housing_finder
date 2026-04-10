import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/message_model.dart';

class ChatService {
  final _supabase = Supabase.instance.client;

  // Stream messages for a specific conversation
  Stream<List<MessageModel>> getMessagesStream(String otherUserId) {
    final myId = _supabase.auth.currentUser!.id;
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .or('sender_id.eq.$myId,receiver_id.eq.$myId')
        .order('created_at')
        .map((data) {
          return data
              .where((e) => (e['sender_id'] == otherUserId && e['receiver_id'] == myId) || 
                            (e['sender_id'] == myId && e['receiver_id'] == otherUserId))
              .map((e) => MessageModel.fromJson(e))
              .toList();
        });
  }

  // Send a new message
  Future<void> sendMessage(String receiverId, String content) async {
    final myId = _supabase.auth.currentUser!.id;
    await _supabase.from('messages').insert({
      'sender_id': myId,
      'receiver_id': receiverId,
      'content': content,
    });
  }

  // Mark messages as read
  Future<void> markAsRead(String senderId) async {
    final myId = _supabase.auth.currentUser!.id;
    await _supabase
        .from('messages')
        .update({'is_read': true})
        .eq('sender_id', senderId)
        .eq('receiver_id', myId)
        .eq('is_read', false);
  }
}
