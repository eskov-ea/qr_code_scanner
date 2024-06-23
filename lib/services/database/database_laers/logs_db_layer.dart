import 'package:qrs_scaner/models/log.dart';
import 'package:sqflite/sqflite.dart';

class LogsDBLayer {
  Future<void> saveLogs(Database db, List<Log> logs) async {
    try {
      final Batch batch = db.batch();
      for (var log in logs) {
        batch.execute(
            'INSERT OR IGNORE INTO logs(name, description, created_at) VALUES(?, ?, ?) ',
            [log.name, log.description, log.createdAt.toUtc().toString()]
        );
      }
      print("Logs saved $logs");
      await batch.commit(noResult: true);
    } catch (err, stackTrace) {
      print("Saving QR result: Failed to add QR code to DB: $err\r\n$stackTrace");
      rethrow;
    }
  }

  Future<List<Log>> readLogs(Database db) async {
    try {
      return await db.transaction((txn) async {
        List<Object> res = await txn.rawQuery('''
            SELECT * FROM logs
            ORDER BY created_at DESC;
        ''');

        return res.map((el) => Log.fromJson(el)).toList();
      });
    } catch (err, stackTrace) {
      print("Getting QR codes: Failed to read QR codes from DB: $err\r\n$stackTrace");
      rethrow;
    }
  }

  Future<int> deleteLogs(Database db) async {
    try {
      return await db.transaction((txn) async {
        return await txn.rawDelete('''
            DELETE FROM logs;
        ''');
      });
    } catch (err, stackTrace) {
      print("Getting QR codes: Failed to read QR codes from DB: $err\r\n$stackTrace");
      rethrow;
    }
  }

}