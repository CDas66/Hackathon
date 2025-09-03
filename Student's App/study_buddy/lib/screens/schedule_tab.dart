import 'package:flutter/material.dart';
import '../models/task.dart';

class ScheduleTab extends StatefulWidget {
  const ScheduleTab({super.key, required this.tasks, required this.onAdd});
  final List<Task> tasks;
  final void Function(Task) onAdd;

  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final Map<Task, Gradient> _gradients = {};

  @override
  void initState() {
    super.initState();
    for (var task in widget.tasks) {
      _gradients[task] = _randomGradient();
    }
  }

  Gradient _randomGradient() {
    final colors = [
      Colors.pink.shade200,
      Colors.orange.shade200,
      Colors.yellow.shade200,
      Colors.green.shade200,
      Colors.blue.shade200,
      Colors.purple.shade200,
      Colors.teal.shade200,
    ];
    colors.shuffle();
    return LinearGradient(
      colors: colors.take(2).toList(),
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Future<void> _addTask() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    DateTime? deadline;
    // Ask for optional deadline
    final pick = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pick != null) {
      final timePick = await showTimePicker(
        // ignore: use_build_context_synchronously
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (timePick != null) {
        deadline = DateTime(
          pick.year,
          pick.month,
          pick.day,
          timePick.hour,
          timePick.minute,
        );
      }
    }

    final task = Task(title: text, time: DateTime.now(), deadline: deadline);
    widget.onAdd(task);
    _gradients[task] = _randomGradient();
    _controller.clear();

    _listKey.currentState?.insertItem(
      widget.tasks.length - 1,
      duration: const Duration(milliseconds: 500),
    );
  }

  void _removeTask(int index) {
    final removedTask = widget.tasks.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) =>
          _buildItem(removedTask, animation, isRemoving: true),
      duration: const Duration(milliseconds: 500),
    );
    _gradients.remove(removedTask);
  }

  void _completeTask(int index) {
    // ignore: unused_local_variable
    final task = widget.tasks[index];
    _removeTask(index);
    // Optional: add some confetti or visual feedback here
  }

  Widget _buildItem(
    Task task,
    Animation<double> animation, {
    bool isRemoving = false,
  }) {
    return SizeTransition(
      sizeFactor: animation,
      child: GestureDetector(
        onTap: () {
          final index = widget.tasks.indexOf(task);
          if (index >= 0) _completeTask(index);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: _gradients[task],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: const Icon(Icons.task_alt, color: Colors.white),
            title: Text(
              task.title,
              style: TextStyle(
                color: Colors.white,
                decoration: isRemoving ? TextDecoration.lineThrough : null,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: task.deadline != null
                ? Text(
                    'Deadline: ${task.deadline!.day}/${task.deadline!.month}/${task.deadline!.year} ${task.deadline!.hour.toString().padLeft(2, '0')}:${task.deadline!.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.white70),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Add a new task...',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _addTask(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _addTask, child: const Text('Add')),
            ],
          ),
        ),
        Expanded(
          child: AnimatedList(
            key: _listKey,
            initialItemCount: widget.tasks.length,
            itemBuilder: (context, index, animation) {
              final task = widget.tasks[index];
              return Dismissible(
                key: ValueKey(task),
                background: Container(
                  color: Colors.green,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  child: const Icon(Icons.check, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.endToStart) {
                    _removeTask(index);
                  } else {
                    _completeTask(index);
                  }
                  return false;
                },
                child: _buildItem(task, animation),
              );
            },
          ),
        ),
      ],
    );
  }
}
