import 'package:flutter/material.dart';

class ChatTab extends StatelessWidget {
  const ChatTab({super.key, required this.studentCode});
  final String studentCode;

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Chat will appear here'));
  }
}
