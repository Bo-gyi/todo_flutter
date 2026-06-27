import 'package:flutter/material.dart';

import './pages/todo_page.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      theme: ThemeData(colorSchemeSeed: Colors.orange),
      home: const TodoPage(),
    );
  }
}
