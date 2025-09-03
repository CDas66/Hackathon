import 'package:flutter/material.dart';

class SOSTab extends StatelessWidget {
  const SOSTab({
    super.key,
    required this.pendingSOS,
    required this.onQueueSOS,
    required this.onSyncSOS,
  });

  final List<String> pendingSOS;
  final VoidCallback onQueueSOS;
  final VoidCallback onSyncSOS;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: onQueueSOS,
          icon: const Icon(Icons.sos),
          label: const Text('Send SOS'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        ),
        ElevatedButton.icon(
          onPressed: onSyncSOS,
          icon: const Icon(Icons.sync),
          label: const Text('Sync SOS'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: pendingSOS.length,
            itemBuilder: (context, i) =>
                ListTile(title: Text('Pending SOS: ${pendingSOS[i]}')),
          ),
        ),
      ],
    );
  }
}
