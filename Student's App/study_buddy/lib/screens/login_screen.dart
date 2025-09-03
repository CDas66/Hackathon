import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onLogin});
  final void Function(String code) onLogin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;

  void _tryLogin() async {
    final code = _controller.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the class code.')),
      );
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    widget.onLogin(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const FlutterLogo(size: 96),
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
              FilledButton(
                onPressed: _loading ? null : _tryLogin,
                child: _loading
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : const Text('Join Class'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
