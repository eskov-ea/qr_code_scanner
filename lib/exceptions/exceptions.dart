enum AppExceptionType { db, network, other, access, server }

class AppException {
  final String? message;
  final String? reason;
  final AppExceptionType type;
  final String? stackTrace;

  AppException({required this.type, this.message, this.reason, this.stackTrace});

  @override
  String toString() => "AppException $type, message: $message, stack trace: \r\n$stackTrace";

  String shownMessage() {
    switch (type) {
      case AppExceptionType.db:
        return "Произошла ошибка при чтении/записи данных в базу данных.";
      case AppExceptionType.network:
        return "Произошла ошибка при отправке данных. Убедитесь, что вы подключены к Интернету, соединение установлено и стабильное и попробуйте еще раз.";
      case AppExceptionType.other:
        return "Произошла непредвиденная ошибка, попробуйте еще раз.";
      case AppExceptionType.access:
        return "Ошибка подключения к Интернету.";
      case AppExceptionType.server:
        return "Ошибка соединения, сервер временно недоступен.";
    }
  }
}
