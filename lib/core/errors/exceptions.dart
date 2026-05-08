class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Не удалось получить данные с сервера']);
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Нет подключения к интернету']);
}
