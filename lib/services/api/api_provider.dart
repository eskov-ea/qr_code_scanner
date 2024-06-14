import 'package:qrs_scaner/models/qr_code.dart';

class QRCodeApiProvider {
  QRCodeApiProvider();

  Future<List<QRCode>> atoneQRCodes(List<QRCode> codes) async {

    return Future.delayed(const Duration(seconds: 4)).then((value) => []);
  }
}