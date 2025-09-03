import 'package:flutter/material.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({
    super.key,
    required this.studentCode,
    required this.onOpenChat,
    required this.onOpenSchedule,
    required this.onQuickSOS,
  });

  final String studentCode;
  final VoidCallback onOpenChat;
  final VoidCallback onOpenSchedule;
  final VoidCallback onQuickSOS;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Pulse animation for SOS button
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
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
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Welcome, ${widget.studentCode}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: widget.onOpenChat,
            icon: const Icon(Icons.chat),
            label: const Text('Chat with Buddy'),
          ),
          ElevatedButton.icon(
            onPressed: widget.onOpenSchedule,
            icon: const Icon(Icons.schedule),
            label: const Text('View Schedule'),
          ),
          const SizedBox(height: 16),
          ScaleTransition(
            scale: _pulseAnimation,
            child: ElevatedButton.icon(
              onPressed: widget.onQuickSOS,
              icon: const Icon(Icons.sos),
              label: const Text('Send SOS'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
