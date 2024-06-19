import 'package:qrs_scaner/models/qr_code.dart';
import 'package:qrs_scaner/services/api/api_provider.dart';

class Mock_QRCodeApiProvider implements QRCodeApiProvider{

  @override
  Future<List<String>> atoneQRCodes(List<QRCode> codes) async {
    await Future.delayed(const Duration(seconds: 1));

    final result = <String>[];
    for (var i = 0; i < codes.length; ++i) {
      result.add(codes[i].value);
    }

    return result;
  }

  @override
  Future<String> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));

    return "SuperSecretAuthToken";
  }

}