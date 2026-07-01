import 'package:todo_app/models/task.dart';
import 'package:todo_app/models/task_filter.dart';

class TaskController {
  final List<Task> _tasks = [];
  TaskFilter selectedFilter = TaskFilter.all;
  bool isLoading = false;
  List<Task> get tasks {
    return switch (selectedFilter) {
      TaskFilter.all => _tasks,
      TaskFilter.active => _tasks.where((task) => !task.isDone).toList(),
      TaskFilter.completed => _tasks.where((task) => task.isDone).toList(),
    };
  }

  String get emptyTasksMessage {
    return switch (selectedFilter) {
      TaskFilter.all => 'No tasks yet',
      TaskFilter.active => 'No active tasks',
      TaskFilter.completed => 'No completed tasks',
    };
  }

  // CRUD methods
  bool addTask(String title, String subtitle) {
    if (title.trim().isEmpty) return false;
    _tasks.add(
      Task(
        title: title.trim(),
        subtitle: subtitle.trim().isEmpty ? null : subtitle.trim(),
      ),
    );
    return true;
  }

  int deleteTask(Task task) {
    final index = _tasks.indexOf(task);
    _tasks.removeAt(index);
    return index;
  }

  void undoDelete(Task task, int index) {
    _tasks.insert(index, task);
  }

  bool editTask(String title, String subtitle, Task task) {
    if (title.trim().isEmpty) return false;
    task.title = title.trim();
    task.subtitle = subtitle.trim();
    return true;
  }

  void toggleTaskDone(Task task) {
    task.isDone = !task.isDone;
  }

  Future<void> loadSavedTasks() async {}
}
