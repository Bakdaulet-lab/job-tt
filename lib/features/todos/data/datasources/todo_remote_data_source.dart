import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/todo.dart';
import '../models/todo_model.dart';

abstract class TodoRemoteDataSource {
  Future<List<TodoModel>> getTodos();
  Future<TodoModel> createTodo(String title, String priority);
  Future<void> deleteTodo(String id);
  Future<TodoModel> updateTodoStatus(String id, bool isCompleted);
}

class TodoRemoteDataSourceImpl implements TodoRemoteDataSource {
  final ApiClient apiClient;

  TodoRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<TodoModel>> getTodos() async {
    try {
      final response = await apiClient.dio.get(
        '/todos',
        queryParameters: {'_limit': 20},
      );
      final List<dynamic> data = response.data is List<dynamic>
          ? response.data as List<dynamic>
          : const <dynamic>[];
      return data
          .map((json) => TodoModel.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();
    } on DioException catch (e) {
      throw _mapDioException(e, 'Не удалось загрузить задачи');
    }
  }

  @override
  Future<TodoModel> createTodo(String title, String priority) async {
    try {
      final response = await apiClient.dio.post(
        '/todos',
        data: {
          'title': title,
          'completed': false,
          'userId': 1,
          'priority': priority,
        },
      );

      final responseData = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{};

      return TodoModel(
        id: responseData['id']?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
        title: responseData['title']?.toString() ?? title,
        isCompleted: _asBool(responseData['completed']) ?? false,
        priority: _priorityFromString(priority),
      );
    } on DioException catch (e) {
      throw _mapDioException(e, 'Не удалось создать задачу');
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    try {
      await apiClient.dio.delete('/todos/$id');
    } on DioException catch (e) {
      throw _mapDioException(e, 'Не удалось удалить задачу');
    }
  }

  @override
  Future<TodoModel> updateTodoStatus(String id, bool isCompleted) async {
    try {
      final response = await apiClient.dio.patch(
        '/todos/$id',
        data: {
          'completed': isCompleted,
        },
      );

      final responseData = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{};

      return TodoModel(
        id: responseData['id']?.toString() ?? id,
        title: responseData['title']?.toString() ?? 'Задача',
        isCompleted: isCompleted,
        priority: responseData['priority'] is String
            ? _priorityFromString(responseData['priority'] as String)
            : TodoPriority.low,
      );
    } on DioException catch (e) {
      throw _mapDioException(e, 'Не удалось изменить статус задачи');
    }
  }

  Exception _mapDioException(DioException exception, String fallbackMessage) {
    if (_isNetworkIssue(exception)) {
      return NetworkException();
    }

    return ServerException(exception.message ?? fallbackMessage);
  }

  bool _isNetworkIssue(DioException exception) {
    if (exception.type == DioExceptionType.connectionError ||
        exception.type == DioExceptionType.connectionTimeout ||
        exception.type == DioExceptionType.receiveTimeout ||
        exception.type == DioExceptionType.sendTimeout) {
      return true;
    }

    final errorText = [exception.message, exception.error?.toString()]
        .whereType<String>()
        .join(' ')
        .toLowerCase();

    return errorText.contains('xmlhttprequest') ||
        errorText.contains('network error') ||
        errorText.contains('socket') ||
        errorText.contains('failed host lookup') ||
        errorText.contains('connection refused') ||
        errorText.contains('internet') ||
        errorText.contains('offline');
  }

  bool? _asBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    return null;
  }

  TodoPriority _priorityFromString(String value) {
    return TodoPriority.values.firstWhere(
      (priority) => priority.name == value,
      orElse: () => TodoPriority.low,
    );
  }
}
