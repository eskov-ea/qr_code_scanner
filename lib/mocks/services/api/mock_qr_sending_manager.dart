import 'package:get_it/get_it.dart';
import 'package:qrs_scaner/models/qr_code.dart';
import 'package:qrs_scaner/services/api/api_repository.dart';
import 'package:qrs_scaner/services/database/database_provider.dart';
import 'package:qrs_scaner/services/qr_sending_manager/qr_sending_manager.dart';
import 'package:qrs_scaner/services/qr_sending_manager/qr_sending_manager_interface.dart';

class Mock_QRCodeSendingManager extends IQRCodeSendingManager implements QRCodeSendingManager {

  Mock_QRCodeSendingManager({required this.repository});
  QRStreamState _currentState = QRStreamState.none;
  @override
  QRStreamState get currentState => _currentState;
  @override
  final int qrPortion = 5;
  @override
  final DBProvider db = GetIt.instance.get<DBProvider>();
  @override
  final QRCodeApiRepository repository;


  @override
  Future<void> addQRCodeToDB(QRCode qr) async {
    sinkQRCode(qr);
  }


  @override
  Future<void> setQrCodesAsAtoned(List<QRCode> codes) async {
    await Future.delayed(const Duration(seconds: 2));
    _currentState = QRStreamState.updated;
    sinkState(_currentState);
  }


  @override
  Future<void> sendQRCodesToServer(List<QRCode> codes) async {
    _currentState = QRStreamState.sending;
    sinkState(_currentState);
    await Future.delayed(const Duration(seconds: 4));

    _currentState = QRStreamState.none;
    final payload = QRStreamPayload(totalCodeCount: codes.length, successCodeCount: codes.length, failureCodeCount:
    0, currentCodeCount: codes.length, deletingCodes: null);

    await Future.delayed(const Duration(milliseconds: 500));
    sinkState(_currentState);

    /// now we can delete this codes from db and inform UI
    setQrCodesAsAtoned(codes);
  }


}