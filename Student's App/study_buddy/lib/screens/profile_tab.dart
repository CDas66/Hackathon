import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({
    super.key,
    required this.studentCode,
    required this.onLogout,
  });

  final String studentCode;
  final VoidCallback onLogout;

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username'); // remove saved login
    onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Profile - Student Code: $studentCode'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _handleLogout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
