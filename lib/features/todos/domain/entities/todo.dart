import 'package:equatable/equatable.dart';

enum TodoPriority { low, medium, high }

class Todo extends Equatable {
  final String id;
  final String title;
  final bool isCompleted;
  final TodoPriority priority;

  const Todo({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.priority = TodoPriority.low,
  });

  Todo copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    TodoPriority? priority,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
    );
  }

  @override
  List<Object?> get props => [id, title, isCompleted, priority];
}
