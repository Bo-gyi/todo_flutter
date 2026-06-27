import 'package:flutter/material.dart';

class TaskDialog extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController subtitleController;
  final String dialogTitle;
  final String actionLabel;
  final Future<void> Function() onSubmit;
  final VoidCallback onCancel;

  const TaskDialog({
    super.key,
    required this.titleController,
    required this.subtitleController,
    required this.dialogTitle,
    required this.actionLabel,
    required this.onSubmit,
    required this.onCancel,
  });
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(dialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Title'),
            autofocus: true,
          ),
          TextField(
            controller: subtitleController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: onCancel, child: const Text("Cancel")),
        TextButton(onPressed: onSubmit, child: Text(actionLabel)),
      ],
    );
  }
}
