import 'package:dio/dio.dart';

class ApiClient {
  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://jsonplaceholder.typicode.com', // Используем мок-API
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    
    dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }
}
