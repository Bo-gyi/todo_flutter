import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_storage.dart';
import '../models/task_filter.dart';
import '../widgets/filter_button.dart';
import '../widgets/task_tile.dart';
import '../widgets/task_dialog.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final List<Task> tasks = [];
  final TaskStorage storage = TaskStorage();
  TaskFilter selectedFilter = TaskFilter.all;
  bool isLoading = false;
  List<Task> get visibleTasks {
    return switch (selectedFilter) {
      TaskFilter.all => tasks,
      TaskFilter.active => tasks.where((task) => !task.isDone).toList(),
      TaskFilter.completed => tasks.where((task) => task.isDone).toList(),
    };
  }

  String get emptyTasksMessage {
    return switch (selectedFilter) {
      TaskFilter.all => 'No tasks yet',
      TaskFilter.active => 'No active tasks',
      TaskFilter.completed => 'No completed tasks',
    };
  }

  @override
  void initState() {
    super.initState();
    loadSavedTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Tasks')),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilterButton(
                name: 'All',
                filter: TaskFilter.all,
                selectedFilter: selectedFilter,
                onPressed: () => selectFilter(TaskFilter.all),
              ),
              FilterButton(
                name: 'Active',
                filter: TaskFilter.active,
                selectedFilter: selectedFilter,
                onPressed: () => selectFilter(TaskFilter.active),
              ),
              FilterButton(
                name: 'Completed',
                filter: TaskFilter.completed,
                selectedFilter: selectedFilter,
                onPressed: () => selectFilter(TaskFilter.completed),
              ),
            ],
          ),
          Expanded(
            child: isLoading
                ? Center(child: Center(child: Icon(Icons.circle_outlined)))
                : (visibleTasks.isEmpty)
                ? Center(child: Text(emptyTasksMessage))
                : ListView.separated(
                    itemCount: visibleTasks.length,
                    itemBuilder: (context, index) {
                      final task = visibleTasks[index];
                      return TaskTile(
                        task: task,
                        onToggle: () => toggleTaskDone(task),
                        onEdit: () => showTaskDialog(task: task),
                        onDelete: () => deleteTask(task),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider();
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTaskDialog(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
    );
  }

  // ---- helper functions ----

  Future<void> loadSavedTasks() async {
    setState(() {
      isLoading = true;
    });
    try {
      final loadedTasks = await storage.loadTasks();
      //mounted tells you whether this State object is still attached to the widget tree.
      //For async methods that later call setState(), this is a very good habit.
      if (!mounted) return;
      setState(() {
        tasks.clear();
        tasks.addAll(loadedTasks);
      });
    } finally {
      // to make app state didn't stuck in loading stage if loading throws.
      setState(() {
        if (mounted) {
          isLoading = false;
        }
      });
    }
  }

  /// saves tasks by calling saveTasks method from storage class.
  Future<void> commit() async {
    await storage.saveTasks(tasks);
  }

  Future<bool> addTask(String taskTitle, String subtitle) async {
    if (taskTitle.trim().isEmpty) return false;

    setState(() {
      tasks.add(
        Task(
          title: taskTitle.trim(),
          subtitle: subtitle.trim().isEmpty ? null : subtitle.trim(),
        ),
      );
    });
    await commit();
    return true;
  }

  Future<bool> editTask(String title, String subtitle, Task task) async {
    if (title.trim().isEmpty) return false;

    setState(() {
      task.title = title.trim();
      task.subtitle = subtitle.trim().isEmpty ? null : subtitle.trim();
    });
    await commit();
    return true;
  }

  Future<void> deleteTask(Task task) async {
    final index = tasks.indexOf(task);
    setState(() {
      tasks.remove(task);
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Deleted!'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => undoDelete(task, index),
          ),
        ),
      );
    await commit();
  }

  Future<void> undoDelete(Task task, int index) async {
    setState(() {
      tasks.insert(index, task);
    });
    await commit();
  }

  Future<void> toggleTaskDone(Task task) async {
    setState(() {
      task.isDone = !task.isDone;
    });
    await commit();
  }

  void selectFilter(TaskFilter filter) {
    setState(() {
      selectedFilter = filter;
    });
  }

  void showTaskDialog({Task? task}) {
    final titleController = TextEditingController(text: task?.title ?? '');
    final subtitleController = TextEditingController(
      text: task?.subtitle ?? '',
    );

    final isEditing = task != null;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return TaskDialog(
          titleController: titleController,
          subtitleController: subtitleController,
          dialogTitle: isEditing ? 'Edit Task' : 'Add Task',
          actionLabel: isEditing ? 'Edit' : 'Add',
          onSubmit: () async {
            if (isEditing) {
              final edited = await editTask(
                titleController.text,
                subtitleController.text,
                task,
              );
              if (edited && mounted) Navigator.of(dialogContext).pop();
            } else {
              final added = await addTask(
                titleController.text,
                subtitleController.text,
              );
              if (added && mounted) Navigator.of(dialogContext).pop();
            }
          },
          onCancel: () {
            if (mounted) Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }
}
