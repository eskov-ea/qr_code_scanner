import 'package:get_it/get_it.dart';
import 'package:qrs_scaner/models/qr_code.dart';
import 'package:qrs_scaner/services/api/api_provider.dart';
import 'package:qrs_scaner/services/api/api_repository.dart';
import 'package:qrs_scaner/services/database/database_provider.dart';
import 'qr_sending_manager_interface.dart';

class QRCodeSendingManager extends IQRCodeSendingManager {

  QRCodeSendingManager({required this.repository});

  final QRCodeApiRepository repository;
  final DBProvider db = GetIt.instance.get<DBProvider>();
  QRStreamState _currentState = QRStreamState.none;
  QRStreamState get currentState => _currentState;
  final int qrPortion = 5;


  Future<void>  sendQRCodesToServer(List<QRCode> codes) async {
    final totalCount = codes.length;
    List<QRCode> currentQRCodes = <QRCode>[];
    int successfullySent = 0;
    int failedToSend = 0;
    int attempt = 0;
    QRStreamPayload? payload;
    /// This list would be used to delete successfully sent
    /// qr codes from db when we finish communicate to the server
    List<QRCode> atonedQRCodes = [];


    /// inform the listeners we are starting to upload codes
    _currentState = QRStreamState.sending;
    sinkState(_currentState);

    /// Wait for UI
    await Future.delayed(const Duration(milliseconds: 300));

    await Future.doWhile(() async {

      if (currentQRCodes.isEmpty) {
        /// we take [ qrPortion ] codes out of initial list
        if (codes.length >= qrPortion) {
          for (var i = 0; i <= qrPortion; ++i) {
            var item = codes.removeLast();
            currentQRCodes.add(item);
          }
        } else {
          currentQRCodes.addAll(codes);
          codes.clear();
        }
      }

      /// inform UI that we prepare portion to be sent
      payload = QRStreamPayload(totalCodeCount: totalCount, successCodeCount: successfullySent,
          failureCodeCount: failedToSend, currentCodeCount: currentQRCodes.length, deletingCodes: null);
      sinkEvent(QRStreamUploadingEvent(payload: payload!));

      /// send [ qrPortion ] codes to the server
      try {
        print("Execution work start ${DateTime.now()}");
        await repository.atoneQRCodes(currentQRCodes);
        print("Execution work finish ${DateTime.now()}");

        successfullySent = successfullySent + currentQRCodes.length;
        atonedQRCodes.addAll(currentQRCodes);
        currentQRCodes.clear();
        var payload = QRStreamPayload(totalCodeCount: totalCount, successCodeCount: successfullySent,
            failureCodeCount: failedToSend, currentCodeCount: currentQRCodes.length, deletingCodes: null);
        sinkEvent(QRStreamUploadingEvent(payload: payload));

      } catch(err, stackTrace) {
        print("Error while sending codes: $err, $stackTrace");
        if (attempt >= 5) {
          _currentState = QRStreamState.none;
          payload = QRStreamPayload(totalCodeCount: totalCount, successCodeCount: successfullySent,
              failureCodeCount: codes.length - successfullySent, currentCodeCount: currentQRCodes.length, deletingCodes: null);
          sinkEvent(QRStreamUploadingEvent(payload: payload!));
          rethrow;
          //TODO: handle error
        }
        ++attempt;
      }

      return codes.isNotEmpty;
    });
    /// we successfully sent all the codes, inform listeners
    _currentState = QRStreamState.none;
    payload = QRStreamPayload(totalCodeCount: totalCount, successCodeCount: successfullySent, failureCodeCount:
    failedToSend, currentCodeCount: currentQRCodes.length, deletingCodes: null);

    await Future.delayed(const Duration(milliseconds: 500));
    sinkState(_currentState);

    /// now we can delete this codes from db and inform UI
    setQrCodesAsAtoned(atonedQRCodes);
  }

  Future<void> setQrCodesAsAtoned(List<QRCode> codes) async {
    sinkState(QRStreamState.deleting);

    try {
      await db.setStatusToSent(codes);

      _currentState = QRStreamState.updated;
      sinkState(_currentState);
    } catch(err, stackTrace) {
      //TODO: handle error
      print("Delete codes error: $err");
      _currentState = QRStreamState.none;
      sinkState(_currentState);
    }
  }

  Future<void> addQRCodeToDB(QRCode qr) async {
    sinkQRCode(qr);
  }

}

enum QRStreamState {  sending, none, deleting, updated, finishSending  }

class QRStreamUploadingEvent {
  final QRStreamPayload payload;

  QRStreamUploadingEvent({required this.payload});

}

class QRStreamPayload {
  final int totalCodeCount;
  final int successCodeCount;
  final int failureCodeCount;
  final int currentCodeCount;
  final List<QRCode>? deletingCodes;

  QRStreamPayload({required this.totalCodeCount, required this.successCodeCount,
    required this.failureCodeCount, required this.currentCodeCount, required this.deletingCodes});

  @override
  String toString() => "Instance of QRStreamPayload: totalCodeCount: $totalCodeCount, "
      "successCodeCount: $successCodeCount, failureCodeCount: $failureCodeCount, "
      "currentCodeCount: $currentCodeCount, deletingCodes: $deletingCodes";
}
