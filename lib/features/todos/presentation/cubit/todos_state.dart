import 'package:equatable/equatable.dart';
import '../../domain/entities/todo.dart';

abstract class TodosState extends Equatable {
  const TodosState();

  @override
  List<Object?> get props => [];
}

class TodosInitial extends TodosState {
  const TodosInitial();
}

class TodosLoading extends TodosState {
  const TodosLoading();
}

class TodosLoaded extends TodosState {
  final List<Todo> todos;

  const TodosLoaded({required this.todos});

  @override
  List<Object?> get props => [todos];
}

class TodosError extends TodosState {
  final String message;

  const TodosError({required this.message});

  @override
  List<Object?> get props => [message];
}
