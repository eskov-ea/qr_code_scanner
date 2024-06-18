import 'package:qrs_scaner/exceptions/exceptions.dart';
import 'package:qrs_scaner/extentions/list.dart';
import 'package:qrs_scaner/models/app_config.dart';
import 'package:qrs_scaner/models/qr_code.dart';
import 'package:qrs_scaner/services/database/database_laers/config_db_layer.dart';
import 'package:qrs_scaner/services/database/database_laers/qr_code_db_layer.dart';
import 'package:qrs_scaner/services/database/database_laers/sqlite_db_layer.dart';
import 'package:qrs_scaner/services/database/database_provider.dart';
import 'package:qrs_scaner/services/database/tables.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common/sqlite_api.dart';


/// We use this class for Database unit tests.
/// We simply use real Database methods but inject in them
/// test in-memory database instance.
/// So far [Mock_DBProvider] implements [DBProvider] and injects
/// test db instance we can be sure about this tests.
class Mock_DBProvider implements DBProvider {

  Mock_DBProvider({required this.sqliteDbLayer, required this.qrCodeDbLayer});

  final SQLiteDBLayer sqliteDbLayer;
  final QRCodeDBLayer qrCodeDbLayer;
  Database? _database;

  @override
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await initDB();
      return _database!;
    }
  }

  @override
  Future<Database> initDB() async  {
    return await openDatabase(inMemoryDatabasePath, version: 1,
        onCreate: (db, version) async {
          tables.forEach((key, sql) async {
            await db.execute(sql);
          });
        });
  }
  @override
  Future<void> createTables() => sqliteDbLayer.createTables(_database!);
  @override
  Future<int> addQRCode(QRCode qr) => qrCodeDbLayer.addQRCode(_database!, qr);
  @override
  Future<List<QRCode>> getActiveQRCodes() => qrCodeDbLayer.getActiveQRCodes(_database!);
  @override
  Future<void> setStatusToSent(List<QRCode> qrs) => qrCodeDbLayer.setStatusToSent(_database!, qrs);
  @override
  Future<List<QRCode>> getAtonedQRCodes() async => await qrCodeDbLayer.getAtonedQRCodes(_database!);
  @override
  Future<bool> checkIfQRCodeExist(QRCode qr) => qrCodeDbLayer.checkIfQRCodeExist(_database!, qr);
  @override
  Future closeDatabase() => sqliteDbLayer.closeDatabase(_database!);

  @override
  bool checkIfTableExists(List<Map<String, Object?>> existingTables, String searchingTableName) => sqliteDbLayer.checkIfTableExists(existingTables, searchingTableName);

  @override
  Future<QRCode> getQRCodeByValue(String value) {
    // TODO: implement getQRCodeByValue
    throw UnimplementedError();
  }

  @override
  // TODO: implement configDBLayer
  ConfigDBLayer get configDBLayer => throw UnimplementedError();

  @override
  Future<AppConfig> getConfig() {
    // TODO: implement getConfig
    throw UnimplementedError();
  }

  @override
  Future<int> setFactoryName(String name) {
    // TODO: implement setFactoryName
    throw UnimplementedError();
  }

  @override
  Future<int> setAuthToken(String name) {
    // TODO: implement setAuthToken
    throw UnimplementedError();
  }

}
