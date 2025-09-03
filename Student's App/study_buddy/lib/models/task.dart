class Task {
  final String title;
  final DateTime time;
  final DateTime? deadline; // <-- add this

  Task({required this.title, required this.time, this.deadline});
}
