import 'package:flutter/material.dart';

class EditPropertyScreen extends StatelessWidget {
  const EditPropertyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Property')),
      body: const Center(child: Text('Edit Property Screen')),
    );
  }
}
