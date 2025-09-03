import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// relative imports for your modular screens + model
import 'screens/login_screen.dart';
import 'screens/home_tab.dart';
import 'screens/chat_tab.dart';
import 'screens/schedule_tab.dart';
import 'screens/sos_tab.dart';
import 'screens/profile_tab.dart';
import 'models/task.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StudyBuddyApp());
}

class StudyBuddyApp extends StatefulWidget {
  const StudyBuddyApp({super.key});

  @override
  State<StudyBuddyApp> createState() => _StudyBuddyAppState();
}

class _StudyBuddyAppState extends State<StudyBuddyApp> {
  bool _loggedIn = false;
  String _studentCode = '';
  final List<String> _pendingSOS = [];
  final List<Task> _tasks = [];

  void _login(String code) {
    if (code.trim().isEmpty) return;
    setState(() {
      _loggedIn = true;
      _studentCode = code.trim();
    });
    HapticFeedback.selectionClick();
  }

  void _logout() {
    setState(() {
      _loggedIn = false;
      _studentCode = '';
      _tasks.clear();
      _pendingSOS.clear();
    });
  }

  void _queueSOS() {
    final stamp = DateTime.now().toIso8601String();
    setState(() => _pendingSOS.add(stamp));
    HapticFeedback.heavyImpact();
  }

  void _syncSOS() {
    setState(() => _pendingSOS.clear());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pending SOS synced (simulated).')),
    );
  }

  void _addTask(Task t) => setState(() => _tasks.add(t));
  void _removeTask(int i) => setState(() {
    if (i >= 0 && i < _tasks.length) _tasks.removeAt(i);
  });

  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeTab(
        studentCode: _studentCode,
        onOpenChat: () => setState(() => _selected = 1),
        onOpenSchedule: () => setState(() => _selected = 2),
        onQuickSOS: _queueSOS,
      ),
      ChatTab(studentCode: _studentCode),
      ScheduleTab(tasks: _tasks, onAdd: _addTask, onRemove: _removeTask),
      SOSTab(
        pendingSOS: _pendingSOS,
        onQueueSOS: _queueSOS,
        onSyncSOS: _syncSOS,
      ),
      ProfileTab(studentCode: _studentCode, onLogout: _logout),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Study Buddy',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: _loggedIn
          ? Scaffold(
              appBar: AppBar(title: const Text('Study Buddy')),
              body: IndexedStack(index: _selected, children: pages),
              bottomNavigationBar: NavigationBar(
                selectedIndex: _selected,
                onDestinationSelected: (i) => setState(() => _selected = i),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.chat_bubble_outline),
                    label: 'Chat',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.schedule),
                    label: 'Schedule',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.sos_outlined),
                    label: 'SOS',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    label: 'Profile',
                  ),
                ],
              ),
            )
          : LoginScreen(onLogin: _login),
    );
  }
}
