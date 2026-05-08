import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/itodo_repository.dart';
import 'todos_state.dart';

class TodosCubit extends Cubit<TodosState> {
  final ITodoRepository _repository;

  TodosCubit({required ITodoRepository repository})
      : _repository = repository,
        super(const TodosInitial());

  Future<void> fetchTodos() async {
    emit(const TodosLoading());
    try {
      final todos = await _repository.getTodos();
      emit(TodosLoaded(todos: todos));
    } on ServerException catch (e) {
      emit(TodosError(message: e.message));
    } on NetworkException catch (e) {
      emit(TodosError(message: e.message));
    } catch (e) {
      emit(const TodosError(message: 'Неожиданная ошибка. Попробуйте еще раз.'));
    }
  }

  Future<void> addTodo(String title, TodoPriority priority) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty || state is! TodosLoaded) return;

    final currentState = state as TodosLoaded;
    final previousTodos = List<Todo>.from(currentState.todos);
    final tempTodo = Todo(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: trimmedTitle,
      isCompleted: false,
      priority: priority,
    );

    emit(TodosLoaded(todos: _insertOnTop(previousTodos, tempTodo)));

    try {
      final createdTodo = await _repository.createTodo(trimmedTitle, priority);
      final confirmedTodo = createdTodo.copyWith(priority: priority);
      final loadedState = state is TodosLoaded ? state as TodosLoaded : currentState;
      final updatedTodos = _replaceTodo(
        loadedState.todos,
        tempTodo.id,
        confirmedTodo,
      );
      emit(TodosLoaded(todos: updatedTodos));
    } catch (e) {
      emit(TodosLoaded(todos: previousTodos));
    }
  }

  Future<void> toggleTodoStatus(Todo todo) async {
    if (state is! TodosLoaded) return;
    final currentState = state as TodosLoaded;
    final previousTodos = List<Todo>.from(currentState.todos);
    final updatedTodo = todo.copyWith(isCompleted: !todo.isCompleted);
    emit(TodosLoaded(todos: _replaceTodo(previousTodos, todo.id, updatedTodo)));

    try {
      await _repository.updateTodoStatus(todo.id, updatedTodo.isCompleted);
    } catch (e) {
      emit(TodosLoaded(todos: previousTodos));
    }
  }

  Future<void> deleteTodo(String id) async {
    if (state is! TodosLoaded) return;
    final currentState = state as TodosLoaded;
    final previousTodos = List<Todo>.from(currentState.todos);
    emit(TodosLoaded(todos: _removeTodo(previousTodos, id)));

    try {
      await _repository.deleteTodo(id);
    } catch (e) {
      emit(TodosLoaded(todos: previousTodos));
    }
  }

  List<Todo> _insertOnTop(List<Todo> todos, Todo todo) {
    final updatedTodos = List<Todo>.from(todos);
    updatedTodos.insert(0, todo);
    return updatedTodos;
  }

  List<Todo> _replaceTodo(List<Todo> todos, String todoId, Todo updatedTodo) {
    return todos.map((item) => item.id == todoId ? updatedTodo : item).toList();
  }

  List<Todo> _removeTodo(List<Todo> todos, String id) {
    return todos.where((todo) => todo.id != id).toList();
  }
}
