import 'dart:async';
import 'package:qrs_scaner/models/log.dart';
import 'package:qrs_scaner/services/log_manager/log_manager.dart';


abstract class ILogManager {

  final _eventController = StreamController<Log>.broadcast();
  final _statusController = StreamController<LogManagerStatus>.broadcast();
  Stream<Log> get event => _eventController.stream.asBroadcastStream();
  Stream<LogManagerStatus> get status => _statusController.stream.asBroadcastStream();

  void sinkEvent(Log event) => _eventController.sink.add(event);
  void sinkStatus(LogManagerStatus status) => _statusController.sink.add(status);

}
