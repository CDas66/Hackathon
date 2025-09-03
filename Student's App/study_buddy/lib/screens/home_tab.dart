import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({
    super.key,
    required this.studentCode,
    required this.onOpenChat,
    required this.onOpenSchedule,
    required this.onQuickSOS,
  });

  final String studentCode;
  final VoidCallback onOpenChat;
  final VoidCallback onOpenSchedule;
  final VoidCallback onQuickSOS;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Welcome: $studentCode'));
  }
}
