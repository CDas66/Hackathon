import 'package:flutter/material.dart';
import '../models/task.dart';

class ScheduleTab extends StatelessWidget {
  const ScheduleTab({
    super.key,
    required this.tasks,
    required this.onAdd,
    required this.onRemove,
  });

  final List<Task> tasks;
  final void Function(Task) onAdd;
  final void Function(int) onRemove;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final t = tasks[index];
        return ListTile(
          title: Text(t.title),
          subtitle: Text(t.time.toString()),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => onRemove(index),
          ),
        );
      },
    );
  }
}
