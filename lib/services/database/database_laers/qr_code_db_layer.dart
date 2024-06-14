import 'package:qrs_scaner/models/qr_code.dart';
import 'package:sqflite/sqflite.dart';

class QRCodeDBLayer {
  Future<int> addQRCode(Database db, QRCode qr) async {
    try {
      return await db.transaction((txn) async {
        int id = await txn.rawInsert(
            'INSERT OR IGNORE INTO qr_codes(value, status, created_at) VALUES(?, ?, ?)',
            [qr.value, qr.status, qr.createdAt.toString()]);
        return id;
      });
    } catch (err, stackTrace) {
      print("Saving QR result: Failed to add QR code to DB: $err\r\n$stackTrace");
      rethrow;
    }
  }

  Future<List<QRCode>> getAllGRCodes(Database db) async {
    try {
      return await db.transaction((txn) async {
        List<Object> res = await txn.rawQuery('''
            SELECT * FROM qr_codes 
            ORDER BY created_at DESC;
        ''');

        return res.map((el) => QRCode.fromJson(el)).toList();
      });
    } catch (err, stackTrace) {
      print("Getting QR codes: Failed to read QR codes from DB: $err\r\n$stackTrace");
      rethrow;
    }
  }

  Future<QRCode> getQRCodeByValue(Database db, String value) async {
    try {
      return await db.transaction((txn) async {
        List<Object> res = await txn.rawQuery('''
            SELECT * FROM qr_codes 
            WHERE value = "$value";
        ''');

        return QRCode.fromJson(res.first);
      });
    } catch (err, stackTrace) {
      print("Getting QR codes: Failed to read QR codes from DB: $err\r\n$stackTrace");
      rethrow;
    }
  }

  Future<bool> checkIfQRCodeExist(Database db, QRCode qr) async {
    return await db.transaction((txn) async {
      List<Object> res = await txn.rawQuery(
          'SELECT * FROM qr_codes WHERE value = "${qr.value}";'
      );

      return res.isNotEmpty;
    });
  }

  Future<int> updateQRCodeStatus(Database db, QRCode qr, int status) async {
    return await db.transaction((txn) async {
      int res = await txn.rawUpdate(
          'UPDATE qr_codes SET status = $status, deleted_at = ${DateTime.now()}'
      );

      return res;
    });
  }

  Future<int> deleteAtonedQRCodes(Database db, List<QRCode> qrs) async {
    try {
      return await db.transaction((txn) async {
        final whereQrValue = <String>[];
        qrs.forEach((qr) { whereQrValue.add(qr.value);});
        int res = await txn.rawDelete(
            'DELETE FROM qr_codes WHERE value IN (${List.filled(qrs.length, '?').join(',')}); ',
            [...whereQrValue]
        );

print("Deletion: $res, where: ${whereQrValue.join(', ')}");
        return res;
      });
    } catch(err, stackTrace) {
      rethrow;
    }
  }
}