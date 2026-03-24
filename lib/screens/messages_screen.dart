import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1B2A),
        elevation: 0,
        title: const Text('Messages'),
      ),
      body: Center(
        child: Text(
          'Messages will appear here once the messaging flow is built.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
    );
  }
}
