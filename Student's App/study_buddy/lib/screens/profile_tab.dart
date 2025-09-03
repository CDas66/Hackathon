import 'package:flutter/material.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({
    super.key,
    required this.studentCode,
    required this.onLogout,
  });
  final String studentCode;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Profile - Student Code: $studentCode'),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onLogout, child: const Text('Logout')),
        ],
      ),
    );
  }
}
