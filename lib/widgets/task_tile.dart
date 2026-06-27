import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        task.isDone ? Icons.check_box : Icons.check_box_outline_blank,
      ),
      title: Text(
        task.title,
        style: TextStyle(
          fontSize: 18,
          decoration: task.isDone ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: task.subtitle?.isNotEmpty == true ? Text(task.subtitle!) : null,

      trailing: IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
      onTap: onToggle,
      onLongPress: onEdit,
    );
  }
}
