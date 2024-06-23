import 'package:qrs_scaner/exceptions/exceptions.dart';
import 'package:qrs_scaner/models/app_config.dart';
import 'package:sqflite/sqflite.dart';

class ConfigDBLayer {

  Future<AppConfig> getConfig(Database db) async {
    try {
      return await db.transaction((txn) async {
        List<Object> res = await txn.rawQuery('''
            SELECT * FROM config;
        ''');
        print("Config:  $res");

        return res.isNotEmpty ? AppConfig.fromJson(res[0]) : AppConfig.empty;
      });
    } catch (err, stackTrace) {
      print("Getting AppConfig error: $err\r\n$stackTrace");
      throw AppException(type: AppExceptionType.db, message: "Ошибка чтения настроек из базы данных.");
    }
  }

  Future<int> setFactoryName(Database db, String name) async {
    try {
      return await db.transaction((txn) async {
        return await txn.rawUpdate('''
            UPDATE config SET factory_name = "$name";
        ''');
      });
    } catch (err, stackTrace) {
      print("Getting AppConfig error: $err\r\n$stackTrace");
      rethrow;
    }
  }

  Future<int> setAuthToken(Database db, String token) async {
    try {
      return await db.transaction((txn) async {
        final res = await txn.rawUpdate('''
            UPDATE config SET auth_token = "$token";
        ''');
        print('Set token: $res');
        return res;
      });
    } catch (err, stackTrace) {
      print("Setting auth token error: $err\r\n$stackTrace");
      rethrow;
    }
  }

  Future<int> deleteAuthToken(Database db) async {
    try {
      return await db.transaction((txn) async {
        final res = await txn.rawUpdate('''
            UPDATE config SET auth_token = NULL;
        ''');
        print('Delete token: $res');
        return res;
      });
    } catch (err, stackTrace) {
      print("Setting auth token error: $err\r\n$stackTrace");
      rethrow;
    }
  }

}