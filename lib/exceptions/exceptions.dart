enum AppExceptionType { db, network }

class AppException {
  final String? message;
  final String? reason;
  final AppExceptionType type;
  final String? stackTrace;

  AppException({required this.type, this.message, this.reason, this.stackTrace});

  String shownMessage() {
    switch (type) {
      case AppExceptionType.db:
        return "Произошла ошибка при чтении/записи данных в базу данных.";
      case AppExceptionType.network:
        return "Произошла ошибка при отправке данных. Убедитесь, что вы подключены к Интернету, соединение установлено и стабильное и попробуйте еще раз.";
    }
  }
}
