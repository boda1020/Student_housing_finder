import 'package:flutter/material.dart';

// ============================================================
// MODELS
// ============================================================
enum MessageType { text, propertyCard, attachment }

class ChatMessage {
  final String id;
  final String senderId; // 'me' or agent id
  final String text;
  final DateTime timestamp;
  final MessageType type;
  final PropertyCardData? propertyCard;
  final AttachmentData? attachment;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.type = MessageType.text,
    this.propertyCard,
    this.attachment,
    this.isRead = false,
  });
}

class PropertyCardData {
  final String name;
  final String unit;
  final String price;
  final String imageUrl;
  final bool isAvailable;
  const PropertyCardData({
    required this.name,
    required this.unit,
    required this.price,
    required this.imageUrl,
    required this.isAvailable,
  });
}

class AttachmentData {
  final String fileName;
  final String fileSize;
  const AttachmentData({required this.fileName, required this.fileSize});
}

// ============================================================
// COLORS (Local defined to fix missing import errors)
// ============================================================
class AppColors {
  static const Color background = Color(0xFF0F1B2A);
  static const Color cardBackground = Color(0xFF1E2A3A);
  static const Color accentBlue = Color(0xFF2979FF);
  static const Color accentGreen = Color(0xFF4CAF50);
}

// ============================================================
// DUMMY DATA
// ============================================================
List<ChatMessage> _buildDummyMessages() => [
      ChatMessage(
        id: 'm1',
        senderId: 'agent',
        text:
            'Hi there! I saw you were interested in the North Avenue Studios. Would you like to schedule a virtual tour for tomorrow morning?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        isRead: true,
      ),
      ChatMessage(
        id: 'm2',
        senderId: 'me',
        text:
            'That sounds great! I have classes until 11 AM. Is 11:30 AM possible?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
        isRead: true,
      ),
      ChatMessage(
        id: 'm3',
        senderId: 'agent',
        text: '',
        timestamp: DateTime.now().subtract(const Duration(minutes: 7)),
        type: MessageType.propertyCard,
        propertyCard: const PropertyCardData(
          name: 'North Avenue Studios',
          unit: 'Unit 402',
          price: '\$1,250/mo',
          imageUrl:
              'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=400',
          isAvailable: true,
        ),
      ),
      ChatMessage(
        id: 'm4',
        senderId: 'agent',
        text:
            "11:30 AM works perfectly. I'll send the link a few minutes before our call. In the meantime, here's the floor plan.",
        timestamp: DateTime.now().subtract(const Duration(minutes: 6)),
        isRead: true,
      ),
      ChatMessage(
        id: 'm5',
        senderId: 'agent',
        text: '',
        timestamp: DateTime.now().subtract(const Duration(minutes: 6)),
        type: MessageType.attachment,
        attachment: const AttachmentData(
            fileName: 'FloorPlan_Unit402.pdf', fileSize: '1.2 MB'),
      ),
      ChatMessage(
        id: 'm6',
        senderId: 'me',
        text: 'Perfect, thank you! I\'ll be ready.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
        isRead: true,
      ),
    ];

// ============================================================
// SCREEN
// ============================================================
class ChatScreen extends StatefulWidget {
  final String chatId;

  const ChatScreen({super.key, required this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = _buildDummyMessages();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final String _agentName = 'Alex Rivera';
  final String _agentAvatar = 'https://i.pravatar.cc/150?img=11';
  final bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
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

    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'me',
        text: text,
        timestamp: DateTime.now(),
      ));
      _controller.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.cardBackground,
      elevation: 0,
      leadingWidth: 40,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            color: Colors.white70, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(_agentAvatar),
                backgroundColor: AppColors.cardBackground,
              ),
              if (_isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppColors.cardBackground, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_agentName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              Text(
                _isOnline ? 'Online now' : 'Offline',
                style: TextStyle(
                  color: _isOnline ? AppColors.accentGreen : Colors.white38,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.call_outlined, color: Colors.white70),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white70),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isMe = msg.senderId == 'me';

        final showDate = index == 0 ||
            !_isSameDay(_messages[index - 1].timestamp, msg.timestamp);

        return Column(
          children: [
            if (showDate) _DateSeparator(date: msg.timestamp),
            _buildBubble(msg, isMe),
          ],
        );
      },
    );
  }

  Widget _buildBubble(ChatMessage msg, bool isMe) {
    if (msg.type == MessageType.propertyCard && msg.propertyCard != null) {
      return _PropertyCardBubble(card: msg.propertyCard!);
    }
    if (msg.type == MessageType.attachment && msg.attachment != null) {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: _AttachmentBubble(
          data: msg.attachment!,
          isMe: isMe,
          time: _formatTime(msg.timestamp),
        ),
      );
    }
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: _TextBubble(
        text: msg.text,
        isMe: isMe,
        time: _formatTime(msg.timestamp),
        isRead: msg.isRead,
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      color: AppColors.cardBackground,
      padding: EdgeInsets.only(
        left: 12,
        right: 8,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                color: Colors.white38, size: 26),
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              maxLines: 4,
              minLines: 1,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: AppColors.background,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(Icons.emoji_emotions_outlined,
                color: Colors.white38, size: 24),
            onPressed: () {},
          ),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.accentBlue,
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateSeparator extends StatelessWidget {
  final DateTime date;
  const _DateSeparator({required this.date});

  String get _label {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) return 'Today';
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
              child: Divider(color: Colors.white.withValues(alpha: 0.08))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(_label,
                style: const TextStyle(color: Colors.white38, fontSize: 12)),
          ),
          Expanded(
              child: Divider(color: Colors.white.withValues(alpha: 0.08))),
        ],
      ),
    );
  }
}

class _TextBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String time;
  final bool isRead;

  const _TextBubble(
      {required this.text,
      required this.isMe,
      required this.time,
      required this.isRead});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? AppColors.accentBlue : AppColors.cardBackground,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isMe ? 18 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 18),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(text,
              style: const TextStyle(color: Colors.white, fontSize: 14.5)),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(time,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 10)),
              if (isMe) ...[
                const SizedBox(width: 4),
                Icon(
                  isRead ? Icons.done_all : Icons.done,
                  size: 13,
                  color: isRead
                      ? Colors.lightBlueAccent
                      : Colors.white.withValues(alpha: 0.5),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PropertyCardBubble extends StatelessWidget {
  final PropertyCardData card;
  const _PropertyCardBubble({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      width: MediaQuery.of(context).size.width * 0.72,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 110,
            width: double.infinity,
            child: Image.network(card.imageUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                      color: Colors.white10,
                      child: const Icon(Icons.home, color: Colors.white30),
                    )),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 2),
                Text('${card.unit} • ${card.price}',
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.accentGreen.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    card.isAvailable ? 'Available Now' : 'Unavailable',
                    style: TextStyle(
                        color: card.isAvailable
                            ? AppColors.accentGreen
                            : Colors.redAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentBubble extends StatelessWidget {
  final AttachmentData data;
  final bool isMe;
  final String time;
  const _AttachmentBubble(
      {required this.data, required this.isMe, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe ? AppColors.accentBlue : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.insert_drive_file_outlined,
                color: Colors.white70, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.fileName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(data.fileSize,
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.download_outlined, color: Colors.white60, size: 20),
        ],
      ),
    );
  }
}
