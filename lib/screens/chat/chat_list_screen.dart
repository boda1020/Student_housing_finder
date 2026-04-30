import 'package:flutter/material.dart';
import 'chat_screen.dart';

class ChatPreview {
  final String id;
  final String agentName;
  final String agentAvatarUrl;
  final String propertyName;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;

  const ChatPreview({
    required this.id,
    required this.agentName,
    required this.agentAvatarUrl,
    required this.propertyName,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isOnline,
  });
}

final List<ChatPreview> _dummyChats = [
  ChatPreview(
    id: 'chat_001',
    agentName: 'Alex Rivera',
    agentAvatarUrl: 'https://i.pravatar.cc/150?img=11',
    propertyName: 'North Avenue Studios',
    lastMessage: '11:30 AM works perfectly. I\'ll send the link...',
    lastMessageTime: DateTime.now().subtract(const Duration(minutes: 2)),
    unreadCount: 2,
    isOnline: true,
  ),
  ChatPreview(
    id: 'chat_002',
    agentName: 'Sara Hassan',
    agentAvatarUrl: 'https://i.pravatar.cc/150?img=5',
    propertyName: 'Maple Residences',
    lastMessage: 'The lease starts on the 1st of next month.',
    lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
    unreadCount: 0,
    isOnline: false,
  ),
  ChatPreview(
    id: 'chat_003',
    agentName: 'Omar Nabil',
    agentAvatarUrl: 'https://i.pravatar.cc/150?img=15',
    propertyName: 'Sunrise Apartments',
    lastMessage: 'Can you share your ID for verification?',
    lastMessageTime: DateTime.now().subtract(const Duration(hours: 5)),
    unreadCount: 1,
    isOnline: true,
  ),
  ChatPreview(
    id: 'chat_004',
    agentName: 'Nada Salah',
    agentAvatarUrl: 'https://i.pravatar.cc/150?img=9',
    propertyName: 'Campus View Flats',
    lastMessage: 'Thank you! I\'ll be ready.',
    lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
    unreadCount: 0,
    isOnline: false,
  ),
];

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final List<ChatPreview> _chats = _dummyChats;
  final bool _isLoading = false;
  String _searchQuery = '';

  List<ChatPreview> get _filtered => _chats
      .where((c) =>
          c.agentName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.propertyName.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white70),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon:
                    const Icon(Icons.search, color: Colors.white38, size: 20),
                filled: true,
                fillColor: AppColors.cardBackground,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.accentBlue))
                : _filtered.isEmpty
                    ? const Center(
                        child: Text('No conversations yet.',
                            style: TextStyle(color: Colors.white38)))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => Divider(
                          color: Colors.white.withValues(alpha: 0.05),
                          indent: 80,
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final chat = _filtered[index];
                          return _ChatTile(
                            chat: chat,
                            timeLabel: _formatTime(chat.lastMessageTime),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(chatId: chat.id),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class AppColors {
  static const Color background = Color(0xFF0F1B2A);
  static const Color cardBackground = Color(0xFF1E2A3A);
  static const Color accentBlue = Color(0xFF2979FF);
  static const Color accentGreen = Color(0xFF4CAF50);
}

class _ChatTile extends StatelessWidget {
  final ChatPreview chat;
  final String timeLabel;
  final VoidCallback onTap;

  const _ChatTile({
    required this.chat,
    required this.timeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage: NetworkImage(chat.agentAvatarUrl),
                  backgroundColor: AppColors.cardBackground,
                ),
                if (chat.isOnline)
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.background, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.agentName,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: chat.unreadCount > 0
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    chat.propertyName,
                    style: const TextStyle(
                        color: AppColors.accentBlue, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: chat.unreadCount > 0
                          ? Colors.white70
                          : Colors.white38,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeLabel,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
                const SizedBox(height: 6),
                if (chat.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${chat.unreadCount}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
