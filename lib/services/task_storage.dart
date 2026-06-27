import 'dart:convert';
import '../models/task.dart';

import 'package:shared_preferences/shared_preferences.dart';

class TaskStorage {
  static const String tasksKey = 'tasks';

  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final taskMaps = tasks.map((task) => task.toMap()).toList();
    final jsonString = jsonEncode(taskMaps);
    await prefs.setString(tasksKey, jsonString);
  }

  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(tasksKey);
    if (jsonString == null) return [];
    final List<dynamic> decoded = jsonDecode(jsonString);
    final loadedTasks = decoded
        .map((item) => Task.fromMap(item as Map<String, dynamic>))
        .toList();
    return loadedTasks;
  }
}
