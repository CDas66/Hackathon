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

class _HomeTabState extends State<HomeTab> {
  final FirestoreService _firestore = FirestoreService();
  UserData? _userData;

  late Stream<StepCount> _stepCountStream;
  int _steps = 0;
  final int _stepGoal = 10000;

  @override
  void initState() {
    super.initState();

    // Listen to Firestore user data
    FirestoreService().streamUserData(widget.username, widget.code).listen((
      data,
    ) {
      setState(() {
        _userData = data;
        _steps = data.steps;
      });
    });

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
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Step Count Error: $error')));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Welcome, ${widget.username}',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step progress ring and info
            Center(
              child: SizedBox(
                width: 160,
                height: 160,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: (_steps / _stepGoal).clamp(0.0, 1.0),
                      strokeWidth: 12,
                      color: Colors.green,
                      backgroundColor: Colors.green.shade100,
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$_steps',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'steps',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Goal: $_stepGoal',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Quick cards row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildQuickCard(
                  icon: Icons.check_circle_outline,
                  label: 'Tasks',
                  count: widget.tasks.length,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => _buildTasksSheet(),
                      isScrollControlled: true,
                    );
                  },
                  color: Colors.indigo,
                ),
                _buildQuickCard(
                  icon: Icons.favorite_outline,
                  label: 'Health',
                  count: 78, // static heart rate example
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Health details coming soon!'),
                      ),
                    );
                  },
                  color: Colors.pink,
                ),
                _buildQuickCard(
                  icon: Icons.star_outline,
                  label: 'Streak',
                  count: _userData?.streak ?? 0,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Keep your streak going!')),
                    );
                  },
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickCard({
    required IconData icon,
    required String label,
    required int count,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 14, color: color.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksSheet() {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Text(
                'Your Tasks',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: widget.tasks.isEmpty
                    ? const Center(
                        child: Text(
                          'No tasks yet!',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: widget.tasks.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final task = widget.tasks[index];
                          return ListTile(
                            leading: const Icon(
                              Icons.task_alt,
                              color: Colors.indigo,
                            ),
                            title: Text(task.title),
                            subtitle: task.deadline != null
                                ? Text(
                                    '${task.deadline!.day}/${task.deadline!.month} ${task.deadline!.hour.toString().padLeft(2, '0')}:${task.deadline!.minute.toString().padLeft(2, '0')}',
                                  )
                                : null,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
