import '../entities/todo.dart';

abstract class ITodoRepository {
  Future<List<Todo>> getTodos();
  Future<Todo> createTodo(String title, TodoPriority priority);
  Future<void> deleteTodo(String id);
  Future<Todo> updateTodoStatus(String id, bool isCompleted);
}
