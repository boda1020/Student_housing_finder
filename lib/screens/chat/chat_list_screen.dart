import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/app_provider.dart';
import '../../data/services/chat_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  String _searchQuery = '';

  String _formatTime(DateTime time, AppProvider appProvider) {
    final now = DateTime.now();
    final diff = now.difference(time);
    final isAr = appProvider.isArabic;
    
    if (diff.inMinutes < 1) {
      return appProvider.translate('just_now');
    }
    if (diff.inMinutes < 60) {
      return isAr 
        ? '${diff.inMinutes} ${appProvider.translate('mins_ago')}' 
        : '${diff.inMinutes}${appProvider.translate('mins_ago')}';
    }
    if (diff.inHours < 24) {
      return isAr 
        ? '${diff.inHours} ${appProvider.translate('hours_ago')}' 
        : '${diff.inHours}${appProvider.translate('hours_ago')}';
    }
    return isAr 
      ? '${diff.inDays} ${appProvider.translate('days_ago')}' 
      : '${diff.inDays}${appProvider.translate('days_ago')}';
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final theme = Theme.of(context);
    final isAr = appProvider.isArabic;
    final isDark = appProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appProvider.translate('messages'),
          style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : theme.primaryColor, fontSize: 22),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2530) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: theme.primaryColor.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: appProvider.translate('search_placeholder') ?? 'Search...',
                      hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 14),
                      prefixIcon: Icon(Icons.search_rounded, color: theme.primaryColor, size: 24),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _chatService.getMyChats(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    final chats = snapshot.data ?? [];
                    final filtered = chats.where((c) {
                      final name = c['partner_name'].toString().toLowerCase();
                      final property = c['property_title'].toString().toLowerCase();
                      return name.contains(_searchQuery.toLowerCase()) || property.contains(_searchQuery.toLowerCase());
                    }).toList();

                    if (filtered.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline_rounded, size: 64, color: theme.primaryColor.withOpacity(0.3)),
                                const SizedBox(height: 16),
                                Text(
                                  appProvider.translate('no_conversations'),
                                  style: TextStyle(color: isDark ? Colors.white54 : Colors.grey, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => Divider(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                        indent: isAr ? 20 : 85,
                        endIndent: isAr ? 85 : 20,
                      ),
                      itemBuilder: (context, index) {
                        final chat = filtered[index];
                        return Dismissible(
                          key: Key(chat['id']),
                          direction: isAr ? DismissDirection.startToEnd : DismissDirection.endToStart,
                          background: Container(
                            alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            color: Colors.redAccent,
                            child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
                                title: Text(appProvider.translate('delete_chat_title')),
                                content: Text(appProvider.translate('delete_chat_confirm')),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false), 
                                    child: Text(appProvider.translate('cancel'), style: TextStyle(color: isDark ? Colors.white60 : Colors.black54))
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true), 
                                    child: Text(appProvider.translate('delete'), style: const TextStyle(color: Colors.red))
                                  ),
                                ],
                              ),
                            );
                          },
                          onDismissed: (direction) {
                            _chatService.deleteChat(chat['id']);
                          },
                          child: _ChatTile(
                            chat: chat,
                            theme: theme,
                            isAr: isAr,
                            isDark: isDark,
                            timeLabel: _formatTime(DateTime.parse(chat['last_message_time']), appProvider),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(chatId: chat['id']),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final Map<String, dynamic> chat;
  final String timeLabel;
  final VoidCallback onTap;
  final ThemeData theme;
  final bool isAr;
  final bool isDark;

  const _ChatTile({
    required this.chat,
    required this.timeLabel,
    required this.onTap,
    required this.theme,
    required this.isAr,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final avatar = chat['partner_avatar'] ?? 'https://ui-avatars.com/api/?name=${chat['partner_name']}';
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white54 : Colors.grey[600];
    
    String lastMsg = chat['last_message'];
    if (lastMsg == 'No messages yet') {
      lastMsg = appProvider.translate('no_conversations');
    } else if (lastMsg == 'Inquiry about property') {
      lastMsg = appProvider.translate('inquiry_property');
    }

    final myId = Supabase.instance.client.auth.currentUser?.id;
    final isMe = chat['last_message_sender'] == myId;
    final isRead = chat['last_message_read'] ?? false;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: theme.primaryColor.withOpacity(0.2), width: 1),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(avatar),
              backgroundColor: theme.primaryColor.withOpacity(0.05),
            ),
          ),
          // Online Indicator (Niche Feature for Graduation Project)
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? const Color(0xFF14171A) : Colors.white, width: 2.5),
              ),
            ),
          ),
        ],
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              chat['partner_name'],
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: (chat['unread_count'] ?? 0) > 0 ? FontWeight.w900 : FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            timeLabel,
            style: TextStyle(
              color: (chat['unread_count'] ?? 0) > 0 ? theme.primaryColor : subColor, 
              fontSize: 11,
              fontWeight: (chat['unread_count'] ?? 0) > 0 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              if (isMe) ...[
                Icon(
                  isRead ? Icons.done_all_rounded : Icons.done_rounded,
                  size: 16,
                  color: isRead ? Colors.blue : subColor,
                ),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  lastMsg,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: (chat['unread_count'] ?? 0) > 0 ? (isDark ? Colors.white : Colors.black) : subColor, 
                    fontSize: 14,
                    fontWeight: (chat['unread_count'] ?? 0) > 0 ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              if ((chat['unread_count'] ?? 0) > 0)
                Container(
                  margin: const EdgeInsetsDirectional.only(start: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${chat['unread_count']}',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
