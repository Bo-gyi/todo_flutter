class Task {
  String title;
  String? subtitle;
  bool isDone;
  Task({required this.title, this.subtitle, this.isDone = false});

  Map<String, dynamic> toMap() {
    return {'title': title, 'subtitle': subtitle, 'isDone': isDone};
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      title: map['title'] as String,
      subtitle: map['subtitle'] as String?,
      isDone: map['isDone'] as bool? ?? false,
    );
  }
}
