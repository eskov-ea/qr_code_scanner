import 'dart:ffi';

import 'package:flutter_test/flutter_test.dart';
import 'package:qrs_scaner/mocks/db/mock_db_provider.dart';
import 'package:qrs_scaner/models/log.dart';
import 'package:qrs_scaner/models/qr_code.dart';
import 'package:qrs_scaner/services/database/database_laers/config_db_layer.dart';
import 'package:qrs_scaner/services/database/database_laers/logs_db_layer.dart';
import 'package:qrs_scaner/services/database/database_laers/qr_code_db_layer.dart';
import 'package:qrs_scaner/services/database/database_laers/sqlite_db_layer.dart';
import 'package:qrs_scaner/services/database/database_provider.dart';
import 'package:qrs_scaner/services/database/tables.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';



void sqfliteTestInit() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

class Mock_DBProvider2 extends DBProvider {
  @override
  Future<Database> initDB() => initialiseTestDatabase();
  Mock_DBProvider2({required super.sqliteDbLayer, required super.configDBLayer, required super.logsDBLayer, required super.qrCodeDbLayer});

}

Future<Database> initialiseTestDatabase() async {
  return await openDatabase(inMemoryDatabasePath, version: 1,
    onCreate: (db, version) async {
      tables.forEach((key, sql) async {
        await db.execute(sql);
      });
    }
  );
}

Future main() async {

  setUpAll(() {
    sqfliteTestInit();
  });

  group('Database general functions', () {
    test('Open database and create tables', () async {
    final DBProvider dbProvider = Mock_DBProvider(sqliteDbLayer: SQLiteDBLayer(), qrCodeDbLayer: QRCodeDBLayer(), logsDBLayer: LogsDBLayer(), configDBLayer: ConfigDBLayer());
    final db = await dbProvider.database;
    print("Database is: $db");
    final List<Map<String, Object?>> rawTables = await db.rawQuery('SELECT * FROM sqlite_master');
    final List testTables = rawTables.map((el) => el["name"]).toList();
    int createdTables = 0;
    /// The point is we create all the tables and then check if
    /// DB tables contain each of the table
    tables.forEach((key, value) {
      if (testTables.contains(key)) ++createdTables;
    });

    expect(tables.length, createdTables);
    await db.close();
  });
    test('Check if table exist method', () async {
      final DBProvider dbProvider = Mock_DBProvider(sqliteDbLayer: SQLiteDBLayer(), qrCodeDbLayer: QRCodeDBLayer(), logsDBLayer: LogsDBLayer(), configDBLayer: ConfigDBLayer());
      final db = await dbProvider.database;
      print("Database is: $db");
      const tableName = "test";
      await db.execute('''
        CREATE TABLE "$tableName" (
            id INTEGER PRIMARY KEY,
            name TEXT
        )
      ''');
      final existingTables = await db.rawQuery('''
        SELECT * FROM sqlite_master;
      ''');

      expect(dbProvider.checkIfTableExists(existingTables, tableName), true);
      await db.close();
    });
    test('Check if table exist method', () async {
      final DBProvider dbProvider = Mock_DBProvider(sqliteDbLayer: SQLiteDBLayer(), qrCodeDbLayer: QRCodeDBLayer(), logsDBLayer: LogsDBLayer(), configDBLayer: ConfigDBLayer());
      final db = await dbProvider.database;
      print("Database is: $db");
      const tableName = "test";
      final existingTables = await db.rawQuery('''
        SELECT * FROM sqlite_master;
      ''');

      expect(dbProvider.checkIfTableExists(existingTables, tableName), false);
      await db.close();
    });
  });


  group('Database method: addQRCode', () {
    test('Insert QR Code into Database', () async {
      final DBProvider dbProvider = Mock_DBProvider(sqliteDbLayer: SQLiteDBLayer(), qrCodeDbLayer: QRCodeDBLayer(), logsDBLayer: LogsDBLayer(), configDBLayer: ConfigDBLayer());
      final db = await dbProvider.database;
      print("Test database $db");
      final result = await dbProvider.addQRCode(QRCode(value: "test_value122", status: 0, createdAt: DateTime.now(), deletedAt: null));
      expect(result, 1);
      await db.close();
    });
    test('Insert 4 QR Codes into Database and then retrieve it', () async {
      final DBProvider dbProvider = Mock_DBProvider(sqliteDbLayer: SQLiteDBLayer(), qrCodeDbLayer: QRCodeDBLayer(), logsDBLayer: LogsDBLayer(), configDBLayer: ConfigDBLayer());
      final db = await dbProvider.database;
      await dbProvider.addQRCode(QRCode(value: "test_value1", status: 0, createdAt: DateTime.now(), deletedAt: null));
      await dbProvider.addQRCode(QRCode(value: "test_value2", status: 0, createdAt: DateTime.now(), deletedAt: null));
      await dbProvider.addQRCode(QRCode(value: "test_value3", status: 0, createdAt: DateTime.now(), deletedAt: null));
      await dbProvider.addQRCode(QRCode(value: "test_value4", status: 0, createdAt: DateTime.now(), deletedAt: null));

      final result = await dbProvider.getActiveQRCodes();

      expect(result.length, 4);
      await db.close();
    });
    test('Insert  QR Code 2 times into Database, should save and retrieve only 1 entity', () async {
      final DBProvider dbProvider = Mock_DBProvider(sqliteDbLayer: SQLiteDBLayer(), qrCodeDbLayer: QRCodeDBLayer(), logsDBLayer: LogsDBLayer(), configDBLayer: ConfigDBLayer());
      final db = await dbProvider.database;
      await dbProvider.addQRCode(QRCode(value: "test_value1", status: 0, createdAt: DateTime.now(), deletedAt: null));
      await dbProvider.addQRCode(QRCode(value: "test_value1", status: 0, createdAt: DateTime.now(), deletedAt: null));

      final result = await dbProvider.getActiveQRCodes();

      expect(result.length, 1);
      await db.close();
    });
  });

  group('Database method: deleteAtonedQRCodes', () {
    test('Insert 4 QR Codes, then delete two and retrieve should return the other two', () async {
      final DBProvider dbProvider = Mock_DBProvider(sqliteDbLayer: SQLiteDBLayer(), qrCodeDbLayer: QRCodeDBLayer(), logsDBLayer: LogsDBLayer(), configDBLayer: ConfigDBLayer());
      final db = await dbProvider.database;
      final codes = [
        QRCode(value: "test_value1", status: 0, createdAt: DateTime.now().add(const Duration(hours: 1)), deletedAt: null),
        QRCode(value: "test_value2", status: 0, createdAt: DateTime.now().add(const Duration(hours: 2)), deletedAt: null),
        QRCode(value: "test_value3", status: 0, createdAt: DateTime.now().add(const Duration(hours: 3)), deletedAt: null),
        QRCode(value: "test_value4", status: 0, createdAt: DateTime.now().add(const Duration(hours: 4)), deletedAt: null)
      ];
      await dbProvider.addQRCode(codes[0]);
      await dbProvider.addQRCode(codes[1]);
      await dbProvider.addQRCode(codes[2]);
      await dbProvider.addQRCode(codes[3]);

      await dbProvider.setStatusToSent([codes[0], codes[1]]);
      final result = await dbProvider.getActiveQRCodes();

      expect(result.length, 2);
      expect(result[0], codes[3]);
      expect(result[1], codes[2]);

      await db.close();
    });
  });

  group('Database method: checkIfQRCodeExist', () {
    test('We insert QR code and check if it exists, should return true', () async {
      final DBProvider dbProvider = Mock_DBProvider(sqliteDbLayer: SQLiteDBLayer(), qrCodeDbLayer: QRCodeDBLayer(), logsDBLayer: LogsDBLayer(), configDBLayer: ConfigDBLayer());
      final db = await dbProvider.database;
      final qr = QRCode(value: "test_value1", status: 0, createdAt: DateTime.now(), deletedAt: null);
      await dbProvider.addQRCode(qr);


      expect(await dbProvider.checkIfQRCodeExist(qr), true);
      await db.close();
    });
    test('We insert QR code and check if another QR code exists, should return false', () async {
      final DBProvider dbProvider = Mock_DBProvider(sqliteDbLayer: SQLiteDBLayer(), qrCodeDbLayer: QRCodeDBLayer(), logsDBLayer: LogsDBLayer(), configDBLayer: ConfigDBLayer());
      final db = await dbProvider.database;
      final qr1 = QRCode(value: "test_value1", status: 0, createdAt: DateTime.now(), deletedAt: null);
      final qr2 = QRCode(value: "test_value2", status: 0, createdAt: DateTime.now(), deletedAt: null);
      await dbProvider.addQRCode(qr1);


      expect(await dbProvider.checkIfQRCodeExist(qr2), false);
      await db.close();
    });
    test('We don\'t insert QR code and check if it exists, should return false', () async {
      final DBProvider dbProvider = Mock_DBProvider(sqliteDbLayer: SQLiteDBLayer(), qrCodeDbLayer: QRCodeDBLayer(), logsDBLayer: LogsDBLayer(), configDBLayer: ConfigDBLayer());
      final db = await dbProvider.database;
      final qr1 = QRCode(value: "test_value1", status: 0, createdAt: DateTime.now(), deletedAt: null);

      expect(await dbProvider.checkIfQRCodeExist(qr1), false);
      await db.close();
    });
  });

  group('Database logs methods', () {

    List<Log> logSample = [
      Log(id: 1, name: "Log 1", description: null, createdAt: DateTime.now().add(const Duration(hours: 1))),
      Log(id: 2, name: "Log 2", description: null, createdAt: DateTime.now().add(const Duration(hours: 2))),
      Log(id: 3, name: "Log 3", description: null, createdAt: DateTime.now().add(const Duration(hours: 3))),
      Log(id: 4, name: "Log 4", description: null, createdAt: DateTime.now().add(const Duration(hours: 4))),
      Log(id: 5, name: "Log 5", description: null, createdAt: DateTime.now().add(const Duration(hours: 5))),
      Log(id: 6, name: "Log 6", description: null, createdAt: DateTime.now().add(const Duration(hours: 6)))
    ];
    
    test('Logs can be read', () async {
      final DBProvider dbProvider = Mock_DBProvider(sqliteDbLayer: SQLiteDBLayer(), qrCodeDbLayer: QRCodeDBLayer(), logsDBLayer: LogsDBLayer(), configDBLayer: ConfigDBLayer());
      final db = await dbProvider.database;
      final result = await dbProvider.readLogs();

      expect(result.runtimeType, List<Log>);
      expect(result.isEmpty, true);

      await db.close();
    });
    test('Logs can be saved', () async {
      final DBProvider dbProvider = Mock_DBProvider(sqliteDbLayer: SQLiteDBLayer(), qrCodeDbLayer: QRCodeDBLayer(), logsDBLayer: LogsDBLayer(), configDBLayer: ConfigDBLayer());
      final db = await dbProvider.database;

      await dbProvider.saveLogs(logSample);

      final result = await dbProvider.readLogs();
      expect(result.runtimeType, List<Log>);
      expect(result.length, 6);

      await db.close();
    });
    test('Logs can be deleted', () async {
      final DBProvider dbProvider = Mock_DBProvider(sqliteDbLayer: SQLiteDBLayer(), qrCodeDbLayer: QRCodeDBLayer(), logsDBLayer: LogsDBLayer(), configDBLayer: ConfigDBLayer());
      final db = await dbProvider.database;

      await dbProvider.saveLogs(logSample);

      final deletedCount = await dbProvider.deleteLogs();
      expect(deletedCount, 6);

      await db.close();
    });
  });
}

