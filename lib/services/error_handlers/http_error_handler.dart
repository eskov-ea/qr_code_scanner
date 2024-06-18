import 'package:qrs_scaner/exceptions/exceptions.dart';
import 'package:http/http.dart' as http;

class HttpErrorHandler {

  static handleResponse(http.Response response) {
    if (response.statusCode >= 400 && response.statusCode < 500) {
      throw AppException(type: AppExceptionType.access);
    } else if (response.statusCode >= 500) {
      throw AppException(type: AppExceptionType.server);
    } else if (response.statusCode >= 300 && response.statusCode < 400) {
      throw AppException(type: AppExceptionType.access);
    }

    return null;
  }
}