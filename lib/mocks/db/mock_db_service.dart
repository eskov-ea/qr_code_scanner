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

final mockQRCodes = [
  QRCode(value: "54dsafdsgdf6g", status: 0, createdAt: DateTime.parse("2019-07-19 08:45:00.000000"), deletedAt: null),
  QRCode(value: "fddfg465b4f5y", status: 0, createdAt: DateTime.parse("2019-07-19 08:55:00.000000"), deletedAt: null),
  QRCode(value: "bfgb54fgb6fg4", status: 0, createdAt: DateTime.parse("2019-07-19 09:10:00.000000"), deletedAt: null),
  QRCode(value: "xc45dfb65d455", status: 0, createdAt: DateTime.parse("2019-07-19 09:20:00.000000"), deletedAt: null),
  QRCode(value: "fngfhg867f7f2", status: 0, createdAt: DateTime.parse("2019-07-19 09:40:00.000000"), deletedAt: null),
  QRCode(value: "dfhdfhf78hj88", status: 0, createdAt: DateTime.parse("2019-07-19 08:30:00.000000"), deletedAt: null),
  QRCode(value: "xcvxc5vx4c552", status: 0, createdAt: DateTime.parse("2019-08-11 10:40:00.000000"), deletedAt: null),
  QRCode(value: "cvb5rs7t8errt", status: 0, createdAt: DateTime.parse("2019-08-11 10:40:00.000000"), deletedAt: null),
  QRCode(value: "sf85sd74fg8er", status: 0, createdAt: DateTime.parse("2019-08-11 10:50:00.000000"), deletedAt: null),
  QRCode(value: "5gfh4jn5fgrt8", status: 0, createdAt: DateTime.parse("2019-08-11 11:00:00.000000"), deletedAt: null),
  QRCode(value: "ytuity41jghj4", status: 0, createdAt: DateTime.parse("2019-08-11 11:10:00.000000"), deletedAt: null),
  QRCode(value: "cfhbfdh54fg45", status: 0, createdAt: DateTime.parse("2019-08-11 11:20:00.000000"), deletedAt: null),
  QRCode(value: "uioui8e5rte18", status: 0, createdAt: DateTime.parse("2019-08-11 11:30:00.000000"), deletedAt: null),
  QRCode(value: "kl,hji5l4hj5k", status: 0, createdAt: DateTime.parse("2019-08-11 11:40:00.000000"), deletedAt: null),
  QRCode(value: "opbcvb5sdfg64", status: 0, createdAt: DateTime.parse("2019-09-24 13:10:00.000000"), deletedAt: null),
  QRCode(value: "zxcz5thtfghj5", status: 0, createdAt: DateTime.parse("2019-09-24 13:20:00.000000"), deletedAt: null),
  QRCode(value: "tuysdf487awd8", status: 0, createdAt: DateTime.parse("2019-09-24 13:30:00.000000"), deletedAt: null),
  QRCode(value: "fjmlksd4g5hjn", status: 0, createdAt: DateTime.parse("2019-09-24 13:40:00.000000"), deletedAt: null),
  QRCode(value: "465d4rgr4r555", status: 0, createdAt: DateTime.parse("2019-09-24 13:50:00.000000"), deletedAt: null),
  QRCode(value: "rt6y5x4cxse87", status: 0, createdAt: DateTime.parse("2019-09-24 14:00:00.000000"), deletedAt: null),
  QRCode(value: "45646dfgfd89y", status: 0, createdAt: DateTime.parse("2019-09-24 14:05:00.000000"), deletedAt: null),
];

/// We use this class for Database widget tests.
/// We don\'t care about testing Database methods in widget tests -
/// we just need to get predictable values for the app.
class Mock_DatabaseService implements DBProvider{

  Mock_DatabaseService({
    required this.sqliteDbLayer,
    required this.qrCodeDbLayer
  });
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
  var codes = [...mockQRCodes];


  @override
  Future<List<QRCode>> getActiveQRCodes() async {
    await Future.delayed(const Duration(seconds: 2));
    print("GET ALL QR CODES: ${codes.length}");
    return codes.reversed.toList();
  }

  @override
  Future<int> setStatusToSent(List<QRCode> qrs) async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      for (var i = 0; i < qrs.length; ++i) {
        codes.removeWhere((code) => code.value == qrs[i].value);
      }
      print("DELETE ATONED CODES: ${codes.length}");
      return qrs.length;
    } catch(err, stackTrace) {
      print("DELETE ATONED CODES ERROR: $err");
      rethrow;
    }
  }

  Future<int> addQRCode(QRCode qr) async {
    await Future.delayed(const Duration(seconds: 2));
    mockQRCodes.add(qr);
    return Future(() => 1);
  }

  /// Not implemented
  @override
  Future<bool> checkIfQRCodeExist(QRCode qr) {
    // TODO: implement checkIfQRCodeExist
    throw UnimplementedError();
  }

  @override
  Future closeDatabase() {
    // TODO: implement closeDatabase
    throw UnimplementedError();
  }

  @override
  Future<void> createTables() {
    // TODO: implement createTables
    throw UnimplementedError();
  }

  @override
  bool checkIfTableExists(List<Map<String, Object?>> existingTables, String searchingTableName) {
    throw UnimplementedError();
  }

  @override
  Future<QRCode> getQRCodeByValue(String value) {
    // TODO: implement getQRCodeByValue
    throw UnimplementedError();
  }

  @override
  Future<List<QRCode>> getAtonedQRCodes() {
    // TODO: implement getAtonedQRCodes
    throw UnimplementedError();
  }

  @override
  // TODO: implement configDBLayer
  ConfigDBLayer get configDBLayer => throw UnimplementedError();

  @override
  Future<AppConfig> getConfig() {
    return Future(() => AppConfig.empty);
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