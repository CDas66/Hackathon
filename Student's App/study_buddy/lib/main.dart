import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/login_screen.dart';
import '../screens/home_tab.dart';
import '../screens/chat_tab.dart';
import '../screens/schedule_tab.dart';
import '../screens/sos_tab.dart';
import '../screens/profile_tab.dart';
import '../models/task.dart';

// ignore: unused_element
late Interpreter _interpreter;

void loadModel() async {
  _interpreter = await Interpreter.fromAsset('assets/AI.tflite');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final prefs = await SharedPreferences.getInstance();
  final studentCode = prefs.getString('class_code');
  final username = prefs.getString('username');
  runApp(StudyBuddyApp(studentCode: studentCode, username: username));
}

class StudyBuddyApp extends StatefulWidget {
  final String? studentCode;
  final String? username;
  final int? health;
  final int? steps;
  final int? streak;
  final int? score;
  const StudyBuddyApp({
    super.key,
    required this.studentCode,
    required this.username,
    this.health,
    this.score,
    this.steps,
    this.streak,
  });

  @override
  State<StudyBuddyApp> createState() => _StudyBuddyAppState();
}

class _StudyBuddyAppState extends State<StudyBuddyApp> {
  String _code = '';
  // ignore: unused_field
  String _username = '';
  final List<String> _pendingSOS = [];
  final List<Task> _tasks = [];
  bool? _loggedIn;

  @override
  void initState() {
    super.initState();
    if (widget.studentCode != null || widget.username != null) {
      _code = widget.studentCode!;
      _username = widget.username!;
    }
    _checkLogin();
  }

  void _login(String code, String username) async {
    setState(() {
      _code = code;
      _username = username;
      _loggedIn = true;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggedIn', true);
    await prefs.setString('username', _username);
    await prefs.setString('class_code', _code);

    HapticFeedback.selectionClick();
  }

  void _logout() async {
    setState(() {
      _code = '';
      _username = '';
      _loggedIn = false;
    });

    // Remove saved username
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('loggedIn');
    await prefs.remove('class_code');
  }

  void _queueSOS() {
    final stamp = DateTime.now().toIso8601String();
    setState(() => _pendingSOS.add(stamp));
    HapticFeedback.heavyImpact();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('loggedIn') ?? false;
    setState(() {
      _loggedIn = loggedIn;
    });
  }

  void _addTask(Task t) => setState(() => _tasks.add(t));

  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    _loggedIn ??= false;
    final pages = <Widget>[
      HomeTab(
        code: _code,
        tasks: _tasks,
        username: _username,
        onOpenChat: () => setState(() => _selected = 1),
        onOpenSchedule: () => setState(() => _selected = 2),
        onQuickSOS: _queueSOS,
      ),
      ChatTab(),
      ScheduleTab(tasks: _tasks, onAdd: _addTask),
      SOSTab(),
      ProfileTab(studentCode: _username, onLogout: _logout),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Study Buddy',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: _loggedIn!
          ? Scaffold(
              body: Stack(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.2, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: 100,
                        ), // space for floating nav
                        child: IndexedStack(index: _selected, children: pages),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 20,
                    left: 24,
                    right: 24,
                    child: SafeArea(
                      child: Material(
                        elevation: 10,
                        borderRadius: BorderRadius.circular(24),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _NavButton(
                                icon: Icons.home_outlined,
                                label: 'Home',
                                selected: _selected == 0,
                                onTap: () => setState(() => _selected = 0),
                              ),
                              _NavButton(
                                icon: Icons.chat_bubble_outline,
                                label: 'Chat',
                                selected: _selected == 1,
                                onTap: () => setState(() => _selected = 1),
                              ),
                              _NavButton(
                                icon: Icons.schedule,
                                label: 'Schedule',
                                selected: _selected == 2,
                                onTap: () => setState(() => _selected = 2),
                              ),
                              _NavButton(
                                icon: Icons.sos_outlined,
                                label: 'SOS',
                                selected: _selected == 3,
                                onTap: () => setState(() => _selected = 3),
                              ),
                              _NavButton(
                                icon: Icons.person_outline,
                                label: 'Profile',
                                selected: _selected == 4,
                                onTap: () => setState(() => _selected = 4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : LoginScreen(onLogin: _login),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.indigo : Colors.grey;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      splashColor: Colors.transparent,
      // ignore: deprecated_member_use
      highlightColor: Colors.indigo.withOpacity(0.15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: selected ? const EdgeInsets.all(5) : EdgeInsets.zero,
              decoration: BoxDecoration(color: Colors.transparent),
              child: Icon(icon, color: color, size: selected ? 28 : 24),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
