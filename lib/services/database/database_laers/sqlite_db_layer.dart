import 'package:qrs_scaner/services/database/database_provider.dart';
import 'package:qrs_scaner/services/database/tables.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLiteDBLayer {

  Future<void> createTables(Database db) async {
    try {
      tables.forEach((key, sql) async {
        await db.execute(sql);
      });
    } catch (err) {
      print("ERROR:DBProvider:73:: $err");
    }
  }

  Future<Database> initDB() async {
    try {
      final databasesPath = await getDatabasesPath();
      String path = join(databasesPath, 'pleyona.db');
      return await openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int version) async {
          await createTables(db);
        },
        onOpen: (db) async {
          final List<Map<String, Object?>> rawTables =
              await db.rawQuery('SELECT * FROM sqlite_master');
          tables.forEach((tableName, sql) async {
            if ( !checkIfTableExists(rawTables, tableName) ) {
              await db.execute(sql);
            }
          });
        },
      );
    } catch (err, stackTrace) {
      print("Error openning database: $err\r\n$stackTrace");
      rethrow;
    }
  }

  Future closeDatabase (Database db) async {
    db.close();
  }

  bool checkIfTableExists(List<Map<String, Object?>> existingTables, String searchingTableName) {
    return existingTables.where((el) =>
      el["name"] == searchingTableName
    ).isNotEmpty;
  }
}