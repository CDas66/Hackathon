import 'package:flutter/material.dart';

class SOSTab extends StatefulWidget {
  const SOSTab({super.key});

  @override
  State<SOSTab> createState() => _SOSTabState();
}

class _SOSTabState extends State<SOSTab> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<Map<String, dynamic>> _messages = [];

  void _sendSOS() {
    final message = {
      'text':
          "SOS sent at ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
      'time': DateTime.now(),
    };
    _messages.insert(0, message); // newest on top
    _listKey.currentState?.insertItem(
      0,
      duration: const Duration(milliseconds: 400),
    );
  }

  Widget _buildItem(Map<String, dynamic> msg, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: 0,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.redAccent.shade200,
        child: ListTile(
          leading: const Icon(Icons.warning, color: Colors.white),
          title: Text(msg['text'], style: const TextStyle(color: Colors.white)),
          subtitle: Text(
            '${msg['time'].day}/${msg['time'].month} ${msg['time'].hour}:${msg['time'].minute.toString().padLeft(2, '0')}',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Center(
          child: InkWell(
            onTap: _sendSOS,
            borderRadius: BorderRadius.circular(50),
            splashColor: Colors.white24,
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.redAccent, Colors.orangeAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(50),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              child: const Text(
                "SEND SOS",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: AnimatedList(
            key: _listKey,
            initialItemCount: _messages.length,
            reverse: true, // newest messages on top
            itemBuilder: (context, index, animation) {
              final msg = _messages[index];
              return _buildItem(msg, animation);
            },
          ),
        ),
      ],
    );
  }
}
