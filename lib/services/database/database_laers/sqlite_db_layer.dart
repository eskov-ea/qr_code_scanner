import 'package:qrs_scaner/exceptions/exceptions.dart';
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
      print("Create table error: $err");
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
          await db.execute('''
            INSERT INTO config(factory_name, auth_token) VALUES(NULL, NULL);
          ''');
          await db.execute('''
            INSERT INTO logs(name) VALUES("Добро пожаловать!\r\nДля использования MCFEF-сканера разрешите доступ к камере, поместите QR-код в область сканирования. Обратите внимание, QR-коды, которые не относятся к типу нашего производства - отсканированы не будут.\r\nДля отправки кодов в систему ЕРП выберите коды во владке 'QR-коды' и нажмите погасить.\r\n");
          ''');
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
      throw AppException(type: AppExceptionType.db, message: "Ошибка инициализации базы данных. Свяжитесь с разработчиком.");
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