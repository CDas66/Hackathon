import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onLogin});
  final void Function(String username) onLogin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _tryLogin() async {
    final code = _controller.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the class code.')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('loginCodes')
          .doc(code)
          .get();

      if (!doc.exists) {
        ScaffoldMessenger.of(
          // ignore: use_build_context_synchronously
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid class code.')));
      } else {
        final data = doc.data()!;
        final username = data['username'] ?? "Guest";

        // Save username locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);

        // ✅ Pass username to onLogin
        widget.onLogin(username);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const FlutterLogo(size: 96),
                const SizedBox(height: 24),
                const Text(
                  'Study Buddy',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Class Code',
                  ),
                  onSubmitted: (_) => _tryLogin(),
                ),
                const SizedBox(height: 16),
                ScaleTransition(
                  scale: Tween<double>(begin: 1.0, end: 1.05).animate(
                    CurvedAnimation(
                      parent: _fadeController,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: FilledButton(
                    onPressed: _loading ? null : _tryLogin,
                    child: _loading
                        ? const CircularProgressIndicator(strokeWidth: 2)
                        : const Text('Join Class'),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
