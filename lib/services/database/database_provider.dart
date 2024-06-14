import 'package:qrs_scaner/models/qr_code.dart';
import 'package:qrs_scaner/services/database/database_laers/qr_code_db_layer.dart';
import 'package:qrs_scaner/services/database/database_laers/sqlite_db_layer.dart';
import 'package:sqflite/sqflite.dart';


class DBProvider {

  DBProvider({
    required this.sqliteDbLayer,
    required this.qrCodeDbLayer
  });
  final SQLiteDBLayer sqliteDbLayer;
  final QRCodeDBLayer qrCodeDbLayer;
  static Database? _database;

  Future<Database> get database async {
    print("We inited Database");
    if (_database != null) {
      return _database!;
    } else {
      print("We inited Database");
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
  Future<List<QRCode>> getAllQRCodes() async => await qrCodeDbLayer.getAllGRCodes(_database!);
  Future<void> deleteAtonedQRCodes(List<QRCode> qrs) => qrCodeDbLayer.deleteAtonedQRCodes(_database!, qrs);
  Future<int> addQRCode(QRCode qr) => qrCodeDbLayer.addQRCode(_database!, qr);
  Future<bool> checkIfQRCodeExist(QRCode qr) async => qrCodeDbLayer.checkIfQRCodeExist(_database!, qr);
  Future<QRCode> getQRCodeByValue(String value) => qrCodeDbLayer.getQRCodeByValue(_database!, value);


}

String dateFormatter(DateTime date) {
  return "${date.day}.${date.month}.${date.year}";
}


