import 'package:get_it/get_it.dart';
import 'package:qrs_scaner/models/log.dart';
import 'package:qrs_scaner/services/database/database_provider.dart';
import 'package:qrs_scaner/services/log_manager/log_manager_interface.dart';

enum LogManagerStatus { ready, busy }

class LogManager extends ILogManager {

  final DBProvider _db = GetIt.instance.get<DBProvider>();
  final List<Log> _state = <Log>[];
  LogManagerStatus _status = LogManagerStatus.ready;
  final List<Log> logStack = <Log>[];
  List<Log> get state => _state;
  LogManagerStatus get currentStatus => _status;
  int logStackLength = 10;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    final logs = await _db.readLogs();
    _state.addAll(logs);
    print("ALL LOGS: $logs");
    _initialized = true;
  }

  void addLogEntity(Log log) async {
    sinkEvent(log);

    _state.add(log);
    logStack.add(log);
    if (logStack.length >= logStackLength) {
      print("Stack max length is exceeded!");
      _status = LogManagerStatus.busy;
      sinkStatus(_status);
      await saveCodesToDb();
      logStack.clear();
      _status = LogManagerStatus.ready;
      sinkStatus(_status);
    }
  }

  Future<void> saveCodesToDb() async {
    print("Logs have been saved to disk. $logStack");
    await _db.saveLogs(logStack);
    logStack.clear();
    print("Logs have been saved to disk. SAVED!");
  }


}
