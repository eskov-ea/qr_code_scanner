import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:qrs_scaner/mocks/db/mock_db_service.dart';
import 'package:qrs_scaner/models/log.dart';
import 'package:qrs_scaner/services/database/database_laers/logs_db_layer.dart';
import 'package:qrs_scaner/services/database/database_laers/qr_code_db_layer.dart';
import 'package:qrs_scaner/services/database/database_laers/sqlite_db_layer.dart';
import 'package:qrs_scaner/services/database/database_provider.dart';
import 'package:qrs_scaner/services/log_manager/log_manager.dart';

Future main() async {

  setUpAll(() {
    GetIt.I.registerSingleton<DBProvider>(
        Mock_DatabaseService(sqliteDbLayer: SQLiteDBLayer(), qrCodeDbLayer: QRCodeDBLayer(), logsDBLayer: LogsDBLayer())
    );
    GetIt.I.registerSingleton<LogManager>(LogManager());
  });

  test('Initialize LogManager', () async {
    final manager = GetIt.instance.get<LogManager>();
    await manager.initialize();

    expect(manager.state.length, 6);
  });

  test('Insert log to manager. State and stack get this log', () async {
    final manager = GetIt.instance.get<LogManager>();
    final prevStateLength = manager.state.length;
    final prevStackLength = manager.logStack.length;
    final log = Log(id: 101, name: 'Log add test', description: "Try to insert log", createdAt: DateTime.now().add(const Duration(hours: 10)));

    manager.addLogEntity(log);

    expect(manager.state.length, prevStateLength + 1);
    expect(manager.state.last, log);
    expect(manager.logStack.length, prevStackLength + 1);
    expect(manager.logStack.last, log);
  });

  test('Testing save logs to db when stack is full', () async {
    final db = GetIt.instance.get<DBProvider>();
    final manager = GetIt.instance.get<LogManager>();
    manager.logStackLength = 3;
    manager.logStack.clear();
    final log1 = Log(id: 102, name: 'Log stack test 1', description: "Try to insert log", createdAt: DateTime.now().add(const Duration(hours: 11)));
    final log2 = Log(id: 103, name: 'Log stack test 2', description: "Try to insert log", createdAt: DateTime.now().add(const Duration(hours: 12)));
    final log3 = Log(id: 104, name: 'Log stack test 3', description: "Try to insert log", createdAt: DateTime.now().add(const Duration(hours: 13)));
    final log4 = Log(id: 105, name: 'Log stack test 4', description: "Try to insert log", createdAt: DateTime.now().add(const Duration(hours: 13)));

    manager.addLogEntity(log1);
    manager.addLogEntity(log2);
    manager.addLogEntity(log3);
    if (manager.currentStatus == LogManagerStatus.busy) {
      await manager.status.firstWhere((status) => status == LogManagerStatus.ready);
    }
    manager.addLogEntity(log4);

    print(await db.readLogs());
    print('\r\n\r\n${manager.logStack}');

    expect(manager.logStack.length, 1);
  });

  test('Testing save logs to db when stack is full', () async {
    final db = GetIt.instance.get<DBProvider>();
    final manager = GetIt.instance.get<LogManager>();

    /// Empty the db state
    await db.deleteLogs();
    expect(await db.readLogs(), <Log>[]);

    /// Empty and config logStack
    manager.logStackLength = 100;
    manager.logStack.clear();

    int count = 0;
    await Future.doWhile(() async {
      var log = Log(id: count, name: 'Log stack test $count', description: "Try to insert log", createdAt: DateTime.now().add(Duration(hours: count)));

      if (manager.currentStatus == LogManagerStatus.busy) {
        print("Wait until manager writes logs to DB!");
        await manager.status.firstWhere((status) => status == LogManagerStatus.ready);
      }
      manager.addLogEntity(log);

      ++count;
      return count < 2010;
    });

    final logs = await db.readLogs();
    expect(logs.length, 2000);
    expect(manager.logStack.length, 10);

  });





}