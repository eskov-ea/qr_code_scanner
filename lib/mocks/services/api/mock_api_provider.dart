import 'package:qrs_scaner/models/qr_code.dart';
import 'package:qrs_scaner/services/api/api_provider.dart';

class Mock_QRCodeApiProvider implements QRCodeApiProvider{

  @override
  Future<List<QRCode>> atoneQRCodes(List<QRCode> codes) async {
    await Future.delayed(const Duration(seconds: 2));

    final result = <QRCode>[];
    for (var i = 0; i < codes.length; ++i) {
      result.add(codes[i]);
    }

    return result;
  }

}