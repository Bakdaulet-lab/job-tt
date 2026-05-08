import '../../domain/entities/todo.dart';
import '../../domain/repositories/itodo_repository.dart';
import '../datasources/todo_remote_data_source.dart';

class TodoRepositoryImpl implements ITodoRepository {
  final TodoRemoteDataSource remoteDataSource;

  TodoRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Todo>> getTodos() async {
    return await remoteDataSource.getTodos();
  }

  @override
  Future<Todo> createTodo(String title, TodoPriority priority) async {
    return await remoteDataSource.createTodo(title, priority.name);
  }

  @override
  Future<void> deleteTodo(String id) async {
    await remoteDataSource.deleteTodo(id);
  }

  @override
  Future<Todo> updateTodoStatus(String id, bool isCompleted) async {
    return await remoteDataSource.updateTodoStatus(id, isCompleted);
  }
}
