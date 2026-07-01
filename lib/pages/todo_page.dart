import 'package:flutter/material.dart';
import 'package:todo_app/controllers/task_controller.dart';
import '../models/task.dart';
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
  final controller = TaskController();

  @override
  initState() {
    super.initState();
    loadTasks();
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
                selectedFilter: controller.selectedFilter,
                onPressed: () => selectFilter(TaskFilter.all),
              ),
              FilterButton(
                name: 'Active',
                filter: TaskFilter.active,
                selectedFilter: controller.selectedFilter,
                onPressed: () => selectFilter(TaskFilter.active),
              ),
              FilterButton(
                name: 'Completed',
                filter: TaskFilter.completed,
                selectedFilter: controller.selectedFilter,
                onPressed: () => selectFilter(TaskFilter.completed),
              ),
            ],
          ),
          Expanded(
            child: controller.isLoading
                ? Center(child: Center(child: Icon(Icons.circle_outlined)))
                : (controller.tasks.isEmpty)
                ? Center(child: Text(controller.emptyTasksMessage))
                : ListView.separated(
                    itemCount: controller.tasks.length,
                    itemBuilder: (context, index) {
                      final task = controller.tasks[index];
                      return TaskTile(
                        task: task,
                        onToggle: () async {
                          controller.toggleTaskDone(task);
                          setState(() {});
                          await controller.commit();
                        },
                        onEdit: () => showTaskDialog(task: task),
                        onDelete: () async {
                          final deletedIndex = controller.deleteTask(task);
                          showSnackBar(task, deletedIndex);
                          setState(() {});
                          await controller.commit();
                        },
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
  Future<void> loadTasks() async {
    await controller.loadSavedTasks();
    setState(() {});
  }

  void showSnackBar(Task task, int index) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Deleted!'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              controller.undoDelete(task, index);
              await controller.commit();
              setState(() {});
            },
          ),
        ),
      );
  }

  void selectFilter(TaskFilter filter) {
    setState(() {
      controller.selectedFilter = filter;
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
              final edited = controller.editTask(
                titleController.text,
                subtitleController.text,
                task,
              );
              setState(() {});
              await controller.commit();
              if (edited && mounted) Navigator.of(dialogContext).pop();
            } else {
              final added = controller.addTask(
                titleController.text,
                subtitleController.text,
              );
              setState(() {});
              await controller.commit();
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
