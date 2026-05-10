import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  final _supabase = Supabase.instance.client;

  // 1. Get or Create a chat (Grouped by Owner, not by Property)
  Future<String> getOrCreateChat({
    required String ownerId,
    required String propertyId,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    final studentId = user.id;

    // Check if a chat already exists between this student and owner
    final existingChat = await _supabase
        .from('chats')
        .select('id')
        .eq('student_id', studentId)
        .eq('owner_id', ownerId)
        .maybeSingle();

    if (existingChat != null) {
      return existingChat['id'].toString();
    }

    try {
      final newChat = await _supabase.from('chats').insert({
        'student_id': studentId,
        'owner_id': ownerId,
        'property_id': propertyId,
      }).select('id').single();

      return newChat['id'].toString();
    } catch (e) {
      // In case of race condition, try one more time to fetch
      final retryChat = await _supabase
          .from('chats')
          .select('id')
          .eq('student_id', studentId)
          .eq('owner_id', ownerId)
          .maybeSingle();
      
      if (retryChat != null) return retryChat['id'].toString();
      rethrow;
    }
  }

  // 2. Stream all chats with details
  Stream<List<Map<String, dynamic>>> getMyChats() {
    final userId = _supabase.auth.currentUser!.id;
    
    return _supabase
        .from('chats')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .asyncMap((chats) async {
          final myChats = chats.where((c) => c['student_id'] == userId || c['owner_id'] == userId).toList();
          
          if (myChats.isEmpty) return [];

          final partnerIds = myChats.map((c) => c['student_id'] == userId ? c['owner_id'] : c['student_id']).toSet().toList();
          final propertyIds = myChats.map((c) => c['property_id']).toSet().toList();

          final profiles = await _supabase.from('profiles').select('id, full_name, avatar_url').filter('id', 'in', partnerIds);
          final properties = await _supabase.from('properties').select('id, title').filter('id', 'in', propertyIds);

          List<Map<String, dynamic>> enrichedChats = [];
          
          for (var chat in myChats) {
            final partnerId = chat['student_id'] == userId ? chat['owner_id'] : chat['student_id'];
            final partner = profiles.firstWhere((p) => p['id'] == partnerId, orElse: () => {'full_name': 'User', 'avatar_url': null});
            final property = properties.firstWhere((p) => p['id'] == chat['property_id'], orElse: () => {'title': 'Unknown Property'});

            final lastMsgData = await _supabase
                .from('messages')
                .select('content, created_at, sender_id, is_read')
                .eq('chat_id', chat['id'])
                .order('created_at', ascending: false)
                .limit(1);

            final unreadData = await _supabase
                .from('messages')
                .select('id')
                .eq('chat_id', chat['id'])
                .eq('is_read', false)
                .neq('sender_id', userId);

            enrichedChats.add({
              ...chat,
              'partner_name': partner['full_name'],
              'partner_avatar': partner['avatar_url'],
              'property_title': property['title'],
              'unread_count': unreadData.length,
              'last_message': lastMsgData.isNotEmpty ? lastMsgData[0]['content'] : (chat['property_id'] != null ? 'Inquiry about property' : 'No messages yet'),
              'last_message_time': lastMsgData.isNotEmpty ? lastMsgData[0]['created_at'] : chat['created_at'],
              'last_message_sender': lastMsgData.isNotEmpty ? lastMsgData[0]['sender_id'] : null,
              'last_message_read': lastMsgData.isNotEmpty ? lastMsgData[0]['is_read'] : false,
            });
          }

          enrichedChats.sort((a, b) => DateTime.parse(b['last_message_time']).compareTo(DateTime.parse(a['last_message_time'])));
          return enrichedChats;
        });
  }

  // 3. Mark messages as read
  Future<void> markAsRead(String chatId) async {
    final userId = _supabase.auth.currentUser!.id;
    
    try {
      // 1. Mark messages as read
      await _supabase
          .from('messages')
          .update({'is_read': true})
          .eq('chat_id', chatId)
          .neq('sender_id', userId);

      // 2. Mark corresponding notifications as read (Don't delete them!)
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('data', chatId);

      // 3. Trigger chat list update
      await _supabase
          .from('chats')
          .update({'created_at': DateTime.now().toIso8601String()})
          .eq('id', chatId);
          
      debugPrint('Marked messages and notifications as read for chat: $chatId');
    } catch (e) {
      debugPrint('Error in markAsRead: $e');
    }
  }

  // 4. Send message
  Future<void> sendMessage(String chatId, String content) async {
    final myId = _supabase.auth.currentUser!.id;
    
    final chatResponse = await _supabase.from('chats').select().eq('id', chatId).limit(1);
    if (chatResponse.isEmpty) return;
    
    final chat = chatResponse[0];
    final receiverId = chat['student_id'] == myId ? chat['owner_id'] : chat['student_id'];

    // 1. إرسال الرسالة
    await _supabase.from('messages').insert({
      'chat_id': chatId,
      'sender_id': myId,
      'content': content,
      'is_read': false,
    });

    // 2. تحديث وقت المحادثة ليظهر التحديث فوراً في القائمة
    await _supabase.from('chats').update({
      'created_at': DateTime.now().toIso8601String(), // نستخدم created_at للترتيب حالياً
    }).eq('id', chatId);

    // 3. إرسال تنبيه للمستلم
    final profileResponse = await _supabase.from('profiles').select('full_name').eq('id', myId).limit(1);
    final myName = profileResponse.isNotEmpty ? profileResponse[0]['full_name'] : 'User';
    
    try {
      await _supabase.from('notifications').insert({
        'user_id': receiverId,
        'property_id': chat['property_id'],
        'title': 'new_message_notification',
        'body': '$myName: ${content.length > 50 ? '${content.substring(0, 50)}...' : content}',
        'type': 'chat',
        'data': chatId,
        'is_read': false,
      });
    } catch (_) {}
  }

  // 4. Delete Chat (Permanent)
  Future<void> deleteChat(String chatId) async {
    try {
      // First delete all messages in this chat
      await _supabase.from('messages').delete().eq('chat_id', chatId);
      // Then delete the chat itself
      final response = await _supabase.from('chats').delete().eq('id', chatId).select();
      
      if (response.isEmpty) {
        print('Chat not found or already deleted');
      }
    } catch (e) {
      print('Error deleting chat: $e');
      throw e;
    }
  }

  // 5. Stream messages for a chat
  Stream<List<Map<String, dynamic>>> getMessages(String chatId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at', ascending: true);
  }

  // 6. Get chat details (partner name, property info)
  Future<Map<String, dynamic>> getChatDetails(String chatId) async {
    final userId = _supabase.auth.currentUser!.id;
    final chatResponse = await _supabase
        .from('chats')
        .select('*, properties(title), student:profiles!student_id(full_name, avatar_url), owner:profiles!owner_id(full_name, avatar_url)')
        .eq('id', chatId)
        .limit(1);
    
    if (chatResponse.isEmpty) return {'partner_name': 'Unknown', 'property_title': 'Unknown'};
    
    final chat = chatResponse[0];
    final isStudent = chat['student_id'] == userId;
    final partner = isStudent ? chat['owner'] : chat['student'];
    
    return {
      'partner_name': partner['full_name'],
      'partner_avatar': partner['avatar_url'],
      'property_title': chat['properties']?['title'] ?? 'Unknown',
    };
  }

  // 7. Get total unread messages count as a stream
  Stream<int> getTotalUnreadCount() {
    final userId = _supabase.auth.currentUser!.id;
    
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .asyncMap((messages) async {
          final response = await _supabase
              .from('messages')
              .select('id')
              .eq('is_read', false)
              .neq('sender_id', userId);
          
          return (response as List).length;
        });
  }
}
