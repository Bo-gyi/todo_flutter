import 'package:flutter/material.dart';
import '../models/task_filter.dart';

class FilterButton extends StatelessWidget {
  final String name;
  final TaskFilter filter;
  final TaskFilter selectedFilter;
  final VoidCallback onPressed;
  const FilterButton({
    super.key,
    required this.name,
    required this.filter,
    required this.selectedFilter,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = filter == selectedFilter;
    return TextButton(
      onPressed: onPressed,
      child: Text(
        name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          decoration: isSelected ? TextDecoration.underline : null,
        ),
      ),
    );
  }
}
