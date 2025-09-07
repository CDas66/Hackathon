import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import '../models/task.dart';
import '../services/firestore_service.dart';
import '../models/user_data.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({
    super.key,
    required this.code,
    required this.username,
    required this.onOpenChat,
    required this.onOpenSchedule,
    required this.onQuickSOS,
    required this.tasks,
  });
  final String code;
  final String username;
  final VoidCallback onOpenChat;
  final VoidCallback onOpenSchedule;
  final VoidCallback onQuickSOS;
  final List<Task> tasks;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final Map<String, bool> _expandedCards = {
    'Tasks': false,
    'Health': false,
    'Steps': false,
    'Streak': false,
  };

  final FirestoreService _firestore = FirestoreService();
  UserData? _userData;

  late Stream<StepCount> _stepCountStream;
  int _steps = 0;
  final int _stepGoal = 10000;

  @override
  void initState() {
    super.initState();

    // Listen to Firestore user data
    _firestore.streamUserData(widget.username).listen((data) {
      _userData = data;
      _steps = data.steps;
    });

    // Setup pulsing animation for SOS button
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _pulseController.forward();
      }
    });
    _pulseController.forward();

    // Initialize pedometer stream
    _initPedometer();
  }

  void _initPedometer() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(
      (StepCount event) {
        setState(() {
          _steps = event.steps;
          _firestore.updateSteps(widget.username, widget.code, _steps);
        });
      },
      onError: (error) {
        if (kDebugMode) {
          print('Step Count Error: $error');
        }
      },
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleCard(String key) {
    setState(() {
      _expandedCards[key] = !(_expandedCards[key] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    const double spacing = 16;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Welcome, ${widget.username}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Tasks Card
          _buildExpandableCard(
            title: 'Tasks',
            subtitle: 'You have ${widget.tasks.length} pending tasks',
            colors: [Colors.indigo.shade100, Colors.indigo.shade50],
            icon: Icons.check_circle_outline,
            expanded: _expandedCards['Tasks']!,
            onTap: () => _toggleCard('Tasks'),
            expandedChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.tasks.isEmpty
                  ? const [Text("No tasks yet!")]
                  : widget.tasks
                        .map(
                          (t) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.task_alt,
                                  size: 20,
                                  color: Colors.black54,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    t.title,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                if (t.deadline != null)
                                  Text(
                                    '${t.deadline!.day}/${t.deadline!.month} ${t.deadline!.hour.toString().padLeft(2, '0')}:${t.deadline!.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black45,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
            ),
          ),

          SizedBox(height: spacing),

          // Health Card
          _buildExpandableCard(
            title: 'Health',
            subtitle: 'Heart rate: 78 bpm',
            colors: [Colors.pink.shade100, Colors.red.shade50],
            icon: Icons.favorite_outline,
            expanded: _expandedCards['Health']!,
            onTap: () => _toggleCard('Health'),
            expandedChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text('Steps recorded: $_steps'),
              ],
            ),
          ),

          SizedBox(height: spacing),

          // Steps Card
          _buildExpandableCard(
            title: 'Steps',
            subtitle: '$_steps steps today',
            colors: [Colors.green.shade100, Colors.green.shade50],
            icon: Icons.directions_walk,
            expanded: _expandedCards['Steps']!,
            onTap: () => _toggleCard('Steps'),
            expandedChild: Column(
              children: [
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_steps / _stepGoal).clamp(0.0, 1.0),
                  color: Colors.green,
                  backgroundColor: Colors.green.shade200,
                ),
                const SizedBox(height: 4),
                Text('Goal: $_stepGoal steps'),
              ],
            ),
          ),

          SizedBox(height: spacing),

          // Streak Card
          _buildExpandableCard(
            title: 'Daily Streak',
            subtitle: '${_userData?.streak ?? 0} days of check-in',
            colors: [Colors.orange.shade100, Colors.orange.shade50],
            icon: Icons.star_outline,
            expanded: _expandedCards['Streak']!,
            onTap: () => _toggleCard('Streak'),
            expandedChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SizedBox(height: 8),
                Text('Keep up your streak!'),
                Text('Next reward: 10 points'),
              ],
            ),
          ),

          SizedBox(height: spacing),

          // SOS Button
          ScaleTransition(
            scale: _pulseAnimation,
            child: ElevatedButton.icon(
              onPressed: widget.onQuickSOS,
              icon: const Icon(Icons.sos),
              label: const Text('Send SOS'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableCard({
    required String title,
    required String subtitle,
    required List<Color> colors,
    required IconData icon,
    required bool expanded,
    required VoidCallback onTap,
    required Widget expandedChild,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, size: 48, color: Colors.black54),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.black54,
                  size: 28,
                ),
              ],
            ),
            if (expanded) ...[const SizedBox(height: 12), expandedChild],
          ],
        ),
      ),
    );
  }
}
