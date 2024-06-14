import 'dart:async';
import 'package:qrs_scaner/models/qr_code.dart';
import 'qr_sending_manager.dart';


abstract class IQRCodeSendingManager {

  final _eventController = StreamController<QRStreamUploadingEvent>.broadcast();
  final _stateController = StreamController<QRStreamState>.broadcast();
  final _addingCodeController = StreamController<QRCode>.broadcast();
  Stream<QRStreamUploadingEvent> get events => _eventController.stream.asBroadcastStream();
  Stream<QRStreamState> get state => _stateController.stream.asBroadcastStream();
  Stream<QRCode> get codes => _addingCodeController.stream.asBroadcastStream();

  void sinkEvent(QRStreamUploadingEvent event) => _eventController.sink.add(event);
  void sinkState(QRStreamState state) => _stateController.sink.add(state);
  void sinkQRCode(QRCode qr) => _addingCodeController.sink.add(qr);

}

