import 'package:qrs_scaner/models/qr_code.dart';
import 'package:qrs_scaner/services/api/api_provider.dart';

class QRCodeApiRepository {
  final QRCodeApiProvider provider;

  const QRCodeApiRepository({required this.provider});

  Future<List<String>> atoneQRCodes(List<QRCode> codes) async => await provider.atoneQRCodes(codes);
  Future<String> login({required String email, required String password})  => provider.login(email, password);
}