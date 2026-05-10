import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/app_provider.dart';
import '../../data/services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  const ChatScreen({super.key, required this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String _currentUserId = Supabase.instance.client.auth.currentUser!.id;
  
  Map<String, dynamic>? _chatDetails;
  bool _isLoadingDetails = true;

  @override
  void initState() {
    super.initState();
    _loadChatDetails();
    _markMessagesAsRead();
  }

  Future<void> _markMessagesAsRead() async {
    try {
      await _chatService.markAsRead(widget.chatId);
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  Future<void> _loadChatDetails() async {
    try {
      final details = await _chatService.getChatDetails(widget.chatId);
      if (mounted) {
        setState(() {
          _chatDetails = details;
          _isLoadingDetails = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingDetails = false);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    _controller.clear();
    try {
      await _chatService.sendMessage(widget.chatId, text);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${appProvider.translate('error')}: $e')),
        );
      }
    }
  }

  String _formatTime(DateTime time) {
    final m = time.minute.toString().padLeft(2, '0');
    final suffix = time.hour >= 12 ? 'PM' : 'AM';
    final hour12 = time.hour % 12 == 0 ? 12 : time.hour % 12;
    return '$hour12:$m $suffix';
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final theme = Theme.of(context);
    final isAr = appProvider.isArabic;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: _buildAppBar(theme, isAr, appProvider),
        body: Column(
          children: [
            Expanded(child: _buildMessageStream(theme, isAr, appProvider)),
            _buildInputBar(theme, isAr, appProvider),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, bool isAr, AppProvider appProvider) {
    final partnerName = _chatDetails?['partner_name'] ?? appProvider.translate('messages');
    final partnerAvatar = _chatDetails?['partner_avatar'] ?? 'https://ui-avatars.com/api/?name=$partnerName';

    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: theme.primaryColor, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(partnerAvatar),
            backgroundColor: theme.primaryColor.withOpacity(0.1),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(partnerName,
                    style: theme.textTheme.titleLarge?.copyWith(fontSize: 16),
                    overflow: TextOverflow.ellipsis),
                Text(
                  appProvider.translate('active'),
                  style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageStream(ThemeData theme, bool isAr, AppProvider appProvider) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _chatService.getMessages(widget.chatId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final messages = snapshot.data ?? [];
        
        // Mark as read logic: If there are unread messages from the partner, mark them as read
        final hasUnread = messages.any((m) => m['sender_id'] != _currentUserId && m['is_read'] == false);
        if (hasUnread) {
          _markMessagesAsRead();
        }
        
        // Use a slight delay to ensure the list is rendered before scrolling
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) _scrollToBottom();
        });

        if (messages.isEmpty) {
          return Center(
            child: Text(
              appProvider.translate('no_conversations'),
              style: theme.textTheme.bodySmall,
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index];
            final isMe = msg['sender_id'] == _currentUserId;
            final isRead = msg['is_read'] ?? false;
            final timestamp = DateTime.parse(msg['created_at']);

            final showDate = index == 0 ||
                !_isSameDay(DateTime.parse(messages[index - 1]['created_at']), timestamp);

            return Column(
              children: [
                if (showDate) _DateSeparator(date: timestamp, appProvider: appProvider),
                _buildBubble(msg['content'], isMe, timestamp, isRead, theme),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBubble(String text, bool isMe, DateTime timestamp, bool isRead, ThemeData theme) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? theme.primaryColor : theme.cardTheme.color,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isMe ? Colors.white : theme.textTheme.bodyLarge?.color,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(timestamp),
                  style: TextStyle(
                    color: isMe ? Colors.white70 : theme.textTheme.bodySmall?.color,
                    fontSize: 10,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    isRead ? Icons.done_all_rounded : Icons.done_rounded,
                    size: 14,
                    color: isRead ? Colors.cyanAccent : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(ThemeData theme, bool isAr, AppProvider appProvider) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 8),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                hintText: appProvider.translate('type_message'),
                filled: true,
                fillColor: theme.cardTheme.color,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateSeparator extends StatelessWidget {
  final DateTime date;
  final AppProvider appProvider;
  const _DateSeparator({required this.date, required this.appProvider});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String label = '${date.day}/${date.month}/${date.year}';
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      label = appProvider.translate('today');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
