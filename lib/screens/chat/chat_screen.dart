import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String? receiverId;
  final String? receiverName;

  const ChatScreen({
    super.key,
    this.receiverId,
    this.receiverName,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Chat Detail Screen Placeholder'),
      ),
    );
  }
}
