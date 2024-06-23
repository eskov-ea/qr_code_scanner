import 'package:qrs_scaner/models/app_config.dart';
import 'package:qrs_scaner/models/log.dart';
import 'package:qrs_scaner/models/qr_code.dart';
import 'package:qrs_scaner/services/database/database_laers/config_db_layer.dart';
import 'package:qrs_scaner/services/database/database_laers/logs_db_layer.dart';
import 'package:qrs_scaner/services/database/database_laers/qr_code_db_layer.dart';
import 'package:qrs_scaner/services/database/database_laers/sqlite_db_layer.dart';
import 'package:sqflite/sqflite.dart';


class DBProvider {

  DBProvider({
    required this.sqliteDbLayer,
    required this.configDBLayer,
    required this.logsDBLayer,
    required this.qrCodeDbLayer
  });
  final SQLiteDBLayer sqliteDbLayer;
  final QRCodeDBLayer qrCodeDbLayer;
  final ConfigDBLayer configDBLayer;
  final LogsDBLayer logsDBLayer;
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await initDB();
      return _database!;
    }
  }



  /// SQLITE DATABASE LAYER
  Future<Database> initDB() => sqliteDbLayer.initDB();
  Future<void> createTables() => sqliteDbLayer.createTables(_database!);
  Future closeDatabase() => sqliteDbLayer.closeDatabase(_database!);
  bool checkIfTableExists(List<Map<String, Object?>> existingTables, String searchingTableName) => sqliteDbLayer.checkIfTableExists(existingTables, searchingTableName);


  /// QR CODE LAYER
  Future<List<QRCode>> getActiveQRCodes() async => await qrCodeDbLayer.getActiveQRCodes(_database!);
  Future<List<QRCode>> getAtonedQRCodes() async => await qrCodeDbLayer.getAtonedQRCodes(_database!);
  Future<void> setStatusToSent(List<QRCode> qrs) => qrCodeDbLayer.setStatusToSent(_database!, qrs);
  Future<int> addQRCode(QRCode qr) => qrCodeDbLayer.addQRCode(_database!, qr);
  Future<bool> checkIfQRCodeExist(QRCode qr) async => qrCodeDbLayer.checkIfQRCodeExist(_database!, qr);
  Future<QRCode> getQRCodeByValue(String value) => qrCodeDbLayer.getQRCodeByValue(_database!, value);

  /// CONFIG DATABASE LAYER
  Future<AppConfig> getConfig() => configDBLayer.getConfig(_database!);
  Future<int> setFactoryName(String name) => configDBLayer.setFactoryName(_database!, name);
  Future<int> setAuthToken(String token) => configDBLayer.setAuthToken(_database!, token);
  Future<int> deleteAuthToken() => configDBLayer.deleteAuthToken(_database!);

  /// LOGS DATABASE LAYER
  Future<void> saveLogs(List<Log> logs) => logsDBLayer.saveLogs(_database!, logs);
  Future<List<Log>> readLogs() => logsDBLayer.readLogs(_database!);
  Future<int> deleteLogs() => logsDBLayer.deleteLogs(_database!);
}

String dateFormatter(DateTime date) {
  return "${date.day}.${date.month}.${date.year}";
}


