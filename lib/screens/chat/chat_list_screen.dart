import 'package:flutter/material.dart';

import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  static const _dummyChats = [
    {
      'id': 'tenant-1',
      'name': 'Sara Williams',
      'message': 'Hi, is the studio still available?',
      'time': '2:14 PM',
    },
    {
      'id': 'tenant-2',
      'name': 'Ahmed Khalid',
      'message': 'I can come see it this weekend.',
      'time': '11:05 AM',
    },
    {
      'id': 'tenant-3',
      'name': 'Nour Hassan',
      'message': 'Can you share the exact address?',
      'time': 'Yesterday',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1B2A),
        elevation: 0,
        title: const Text('Messages'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12),
        separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
        itemCount: _dummyChats.length,
        itemBuilder: (context, index) {
          final chat = _dummyChats[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ChatScreen(
                  chatId: chat['id'] as String,
                  name: chat['name'] as String,
                ),
              ));
            },
            leading: CircleAvatar(
              backgroundColor: Colors.blueGrey.shade700,
              child: Text(
                (chat['name'] as String).substring(0, 1),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              chat['name'] as String,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              chat['message'] as String,
              style: TextStyle(color: Colors.white70),
            ),
            trailing: Text(
              chat['time'] as String,
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          );
        },
      ),
    );
  }
}
