import 'package:flutter_test/flutter_test.dart';
import 'package:qrs_scaner/mocks/db/mock_db_provider.dart';
import 'package:qrs_scaner/models/qr_code.dart';
import 'package:qrs_scaner/services/database/database_laers/qr_code_db_layer.dart';
import 'package:qrs_scaner/services/database/database_laers/sqlite_db_layer.dart';
import 'package:qrs_scaner/services/database/database_provider.dart';
import 'package:qrs_scaner/services/database/tables.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';



void sqfliteTestInit() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

Future main() async {

  sqfliteTestInit();

  group('Database general functions', () {
    test('Open database and create tables', () async {
    final DBProvider dbProvider = Mock_DBProvider(sqliteDbLayer: SQLiteDBLayer(), qrCodeDbLayer: QRCodeDBLayer());
    final db = await dbProvider.database;
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
      final DBProvider dbProvider = Mock_DBProvider(sqliteDbLayer: SQLiteDBLayer(), qrCodeDbLayer: QRCodeDBLayer());
      final db = await dbProvider.database;
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
      final DBProvider dbProvider = Mock_DBProvider(sqliteDbLayer: SQLiteDBLayer(), qrCodeDbLayer: QRCodeDBLayer());
      final db = await dbProvider.database;
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
      final DBProvider dbProvider = Mock_DBProvider(sqliteDbLayer: SQLiteDBLayer(), qrCodeDbLayer: QRCodeDBLayer());
      final db = await dbProvider.database;
      print("Test database $db");
      final result = await dbProvider.addQRCode(QRCode(value: "test_value122", status: 0, createdAt: DateTime.now(), deletedAt: null));
      expect(result, 1);
      await db.close();
    });
    test('Insert 4 QR Codes into Database and then retrieve it', () async {
      final DBProvider dbProvider = Mock_DBProvider(sqliteDbLayer: SQLiteDBLayer(), qrCodeDbLayer: QRCodeDBLayer());
      final db = await dbProvider.database;
      await dbProvider.addQRCode(QRCode(value: "test_value1", status: 0, createdAt: DateTime.now(), deletedAt: null));
      await dbProvider.addQRCode(QRCode(value: "test_value2", status: 0, createdAt: DateTime.now(), deletedAt: null));
      await dbProvider.addQRCode(QRCode(value: "test_value3", status: 0, createdAt: DateTime.now(), deletedAt: null));
      await dbProvider.addQRCode(QRCode(value: "test_value4", status: 0, createdAt: DateTime.now(), deletedAt: null));

      final result = await dbProvider.getAllQRCodes();

      expect(result.length, 4);
      await db.close();
    });
    test('Insert  QR Code 2 times into Database, should save and retrieve only 1 entity', () async {
      final DBProvider dbProvider = Mock_DBProvider(sqliteDbLayer: SQLiteDBLayer(), qrCodeDbLayer: QRCodeDBLayer());
      final db = await dbProvider.database;
      await dbProvider.addQRCode(QRCode(value: "test_value1", status: 0, createdAt: DateTime.now(), deletedAt: null));
      await dbProvider.addQRCode(QRCode(value: "test_value1", status: 0, createdAt: DateTime.now(), deletedAt: null));

      final result = await dbProvider.getAllQRCodes();

      expect(result.length, 1);
      await db.close();
    });
  });

  group('Database method: deleteAtonedQRCodes', () {
    test('Insert 4 QR Codes, then delete two and retrieve should return the other two', () async {
      final DBProvider dbProvider = Mock_DBProvider(sqliteDbLayer: SQLiteDBLayer(), qrCodeDbLayer: QRCodeDBLayer());
      final db = await dbProvider.database;
      await dbProvider.addQRCode(QRCode(value: "test_value1", status: 0, createdAt: DateTime.now(), deletedAt: null));
      await dbProvider.addQRCode(QRCode(value: "test_value2", status: 0, createdAt: DateTime.now(), deletedAt: null));
      await dbProvider.addQRCode(QRCode(value: "test_value3", status: 0, createdAt: DateTime.now(), deletedAt: null));
      await dbProvider.addQRCode(QRCode(value: "test_value4", status: 0, createdAt: DateTime.now(), deletedAt: null));

      await dbProvider.deleteAtonedQRCodes([QRCode(value: "test_value1", status: 0, createdAt: DateTime.now(), deletedAt: null), QRCode(value: "test_value2", status: 0, createdAt: DateTime.now(), deletedAt: null)]);
      final result = await dbProvider.getAllQRCodes();

      expect(result.length, 2);
      expect(result[0], QRCode(value: "test_value3", status: 0, createdAt: DateTime.now(), deletedAt: null));
      expect(result[1], QRCode(value: "test_value4", status: 0, createdAt: DateTime.now(), deletedAt: null));

      await db.close();
    });
  });

  group('Database method: checkIfQRCodeExist', () {
    test('We insert QR code and check if it exists, should return true', () async {
      final DBProvider dbProvider = Mock_DBProvider(sqliteDbLayer: SQLiteDBLayer(), qrCodeDbLayer: QRCodeDBLayer());
      final db = await dbProvider.database;
      final qr = QRCode(value: "test_value1", status: 0, createdAt: DateTime.now(), deletedAt: null);
      await dbProvider.addQRCode(qr);


      expect(await dbProvider.checkIfQRCodeExist(qr), true);
      await db.close();
    });
    test('We insert QR code and check if another QR code exists, should return false', () async {
      final DBProvider dbProvider = Mock_DBProvider(sqliteDbLayer: SQLiteDBLayer(), qrCodeDbLayer: QRCodeDBLayer());
      final db = await dbProvider.database;
      final qr1 = QRCode(value: "test_value1", status: 0, createdAt: DateTime.now(), deletedAt: null);
      final qr2 = QRCode(value: "test_value2", status: 0, createdAt: DateTime.now(), deletedAt: null);
      await dbProvider.addQRCode(qr1);


      expect(await dbProvider.checkIfQRCodeExist(qr2), false);
      await db.close();
    });
    test('We don\'t insert QR code and check if it exists, should return false', () async {
      final DBProvider dbProvider = Mock_DBProvider(sqliteDbLayer: SQLiteDBLayer(), qrCodeDbLayer: QRCodeDBLayer());
      final db = await dbProvider.database;
      final qr1 = QRCode(value: "test_value1", status: 0, createdAt: DateTime.now(), deletedAt: null);

      expect(await dbProvider.checkIfQRCodeExist(qr1), false);
      await db.close();
    });
  });


}

