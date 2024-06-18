import 'dart:convert';
import 'dart:io';
import 'package:get_it/get_it.dart';
import 'package:qrs_scaner/exceptions/exceptions.dart';
import 'package:qrs_scaner/models/qr_code.dart';
import 'package:http/http.dart' as http;
import 'package:qrs_scaner/services/cache_manager/cache_manager.dart';
import 'package:qrs_scaner/services/error_handlers/http_error_handler.dart';

class QRCodeApiProvider {
  QRCodeApiProvider();
  final _cacheManager = GetIt.instance.get<CacheManager>();

  Future<List<String>> atoneQRCodes(List<QRCode> codes) async {
    final token = await _cacheManager.getToken();
    final data = <String, String>{};

    for (var i = 0; i < codes.length; ++i) {
      data.addAll({
        "$i": codes[i].value
      });
    }

    print("Sending data: $data with token: $token");

    try {
      final postData = jsonEncode(<String, Object>{'data': data});
      final response =
          await http.post(Uri.parse('https://erp.mcfef.com/api/product/qrdone'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': 'Bearer $token'
              },
              body: postData);
      print("Atone QR codes: ${response.statusCode} ${response.body} ");
      HttpErrorHandler.handleResponse(response);
      List<dynamic> collection = jsonDecode(response.body)["data"];
      return collection.map((val) => "$val").whereType<String>().toList();
    } on SocketException {
      throw AppException(type: AppExceptionType.network);
    } on AppException catch (err) {
      rethrow;
    } catch (err, st) {
      print("Exception: $err \r\n $st");
      throw AppException(type: AppExceptionType.other);
    }
  }

  Future<String> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('https://erp.mcfef.com/api/auth'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(
            <String, dynamic> {
              'data': {
                'email': email,
                'password': password,
                'device_name': "MCFEF scanner device"
              }
            }
        ),
      );

      final String authToken = json.decode(response.body)["data"]["token"];
      return authToken;
    } catch(err) {
      rethrow;
    }
  }
}