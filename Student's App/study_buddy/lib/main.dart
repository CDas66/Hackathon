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
  final savedUsername = prefs.getString('username'); // load saved username
  runApp(StudyBuddyApp(savedUsername: savedUsername));
}

class StudyBuddyApp extends StatefulWidget {
  final String? savedUsername;
  const StudyBuddyApp({super.key, this.savedUsername});

  @override
  State<StudyBuddyApp> createState() => _StudyBuddyAppState();
}

class _StudyBuddyAppState extends State<StudyBuddyApp> {
  bool _loggedIn = false;
  String _studentCode = '';
  final List<String> _pendingSOS = [];
  final List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    if (widget.savedUsername != null) {
      _loggedIn = true;
      _studentCode = widget.savedUsername!;
    }
  }

  void _login(String username) async {
    setState(() {
      _loggedIn = true;
      _studentCode = username;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);

    HapticFeedback.selectionClick();
  }

  void _logout() async {
    setState(() {
      _loggedIn = false;
      _studentCode = '';
    });

    // Remove saved username
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
  }

  void _queueSOS() {
    final stamp = DateTime.now().toIso8601String();
    setState(() => _pendingSOS.add(stamp));
    HapticFeedback.heavyImpact();
  }

  void _addTask(Task t) => setState(() => _tasks.add(t));

  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeTab(
        tasks: _tasks,
        studentCode: _studentCode,
        onOpenChat: () => setState(() => _selected = 1),
        onOpenSchedule: () => setState(() => _selected = 2),
        onQuickSOS: _queueSOS,
      ),
      ChatTab(),
      ScheduleTab(tasks: _tasks, onAdd: _addTask),
      SOSTab(),
      ProfileTab(studentCode: _studentCode, onLogout: _logout),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Study Buddy',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: _loggedIn
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
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? Colors.indigo : Colors.grey),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.indigo : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
