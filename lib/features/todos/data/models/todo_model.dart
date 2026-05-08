import 'dart:math';
import '../../domain/entities/todo.dart';

class TodoModel extends Todo {
  const TodoModel({
    required super.id,
    required super.title,
    required super.isCompleted,
    required super.priority,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    // Рандомный приоритет для тестового API, если его нет в JSON
    final priorityValue = json['priority'] != null
        ? TodoPriority.values.firstWhere(
            (e) => e.name == json['priority'],
            orElse: () => TodoPriority.low)
        : TodoPriority.values[Random().nextInt(TodoPriority.values.length)];

    return TodoModel(
      id: json['id'].toString(), // jsonplaceholder возвращает int
      title: json['title'] as String,
      isCompleted: json['completed'] as bool,
      priority: priorityValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'completed': isCompleted,
      'priority': priority.name,
    };
  }
}
