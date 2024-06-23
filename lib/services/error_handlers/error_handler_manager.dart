import 'dart:async';

import 'package:qrs_scaner/exceptions/exceptions.dart';

class ErrorHandlerManager {

  final _eventController = StreamController<AppException>.broadcast();
  Stream<AppException> get events => _eventController.stream.asBroadcastStream();
  void sinkEvent(AppException error) => _eventController.sink.add(error);

}