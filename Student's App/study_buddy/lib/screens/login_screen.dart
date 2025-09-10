import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  final Function(String code, String username) onLogin;
  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

Future<void> addUser(
  String code,
  String username,
  int steps,
  int points,
) async {
  await FirebaseFirestore.instance
      .collection("class_codes")
      .doc(code)
      .collection("users")
      .doc(username)
      .set({"steps": steps, "points": points}, SetOptions(merge: true));
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _code = TextEditingController();
  // ignore: unused_field
  bool _loading = false;

  late AnimationController _fadeController;
  // ignore: unused_field
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
    final code = _code.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the class code.')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('class_codes')
          .doc(code)
          .get();

      if (!doc.exists) {
        ScaffoldMessenger.of(
          // ignore: use_build_context_synchronously
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid class code.')));
      } else {
        final username = _username.text.trim();
        addUser(code, username, 0, 0);

        // Save class code & username locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('class_code', code);
        await prefs.setString('username', username);
        await prefs.setBool('loggedIn', true);

        // Pass the code to main app
        widget.onLogin(code, username);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 191, 211, 250),
                Color.fromARGB(255, 247, 195, 247),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(106, 0, 0, 0),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color.fromARGB(143, 255, 255, 255),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FlutterLogo(size: 96),
                      const SizedBox(height: 24),
                      const Text(
                        'Study Buddy',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _username,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.person_outline,
                            color: Colors.white70,
                          ),
                          labelText: 'Username',
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.white70),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _code,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.code,
                            color: Colors.white70,
                          ),
                          labelText: 'Class Code',
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.white70),
                          ),
                        ),
                        onSubmitted: (_) => _tryLogin(),
                      ),
                      const SizedBox(height: 24),
                      ScaleTransition(
                        scale: Tween<double>(begin: 1.0, end: 1.05).animate(
                          CurvedAnimation(
                            parent: _fadeController,
                            curve: Curves.easeInOut,
                          ),
                        ),
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              198,
                              255,
                              255,
                              255,
                            ),
                            foregroundColor: const Color.fromARGB(
                              255,
                              59,
                              36,
                              81,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: Colors.black45,
                          ),
                          onPressed: _loading ? null : _tryLogin,
                          child: _loading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF764BA2),
                                  ),
                                )
                              : const Text(
                                  'Join Class',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
