import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:qrs_scaner/mocks/db/mock_db_service.dart';
import 'package:qrs_scaner/mocks/services/api/mock_api_provider.dart';
import 'package:qrs_scaner/mocks/services/api/mock_qr_sending_manager.dart';
import 'package:qrs_scaner/models/qr_code.dart';
import 'package:qrs_scaner/services/api/api_provider.dart';
import 'package:qrs_scaner/services/api/api_repository.dart';
import 'package:qrs_scaner/services/database/database_laers/qr_code_db_layer.dart';
import 'package:qrs_scaner/services/database/database_laers/sqlite_db_layer.dart';
import 'package:qrs_scaner/services/database/database_provider.dart';
import 'package:qrs_scaner/services/qr_sending_manager/qr_sending_manager.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';




Future main() async {

  setUpAll(() {
    GetIt.I.registerSingleton<DBProvider>(
        Mock_DatabaseService(sqliteDbLayer: SQLiteDBLayer(), qrCodeDbLayer: QRCodeDBLayer())
    );
    GetIt.I.registerSingleton<QRCodeSendingManager>(Mock_QRCodeSendingManager(repository: QRCodeApiRepository(provider: QRCodeApiProvider())));
  });

  test('State changes after event successfully completes', () async {
    final manager = GetIt.instance.get<QRCodeSendingManager>();
    final qr = QRCode(value: "test", status: 0, createdAt: DateTime.now(), deletedAt: null);

    manager.addQRCodeToDB(qr);
    await Future.delayed(const Duration(seconds: 3));
    expect(manager.currentState, QRStreamState.updated);
  });

  test('State emits correctly and can be listened to', () async {
    final manager = GetIt.instance.get<QRCodeSendingManager>();
    final stream = manager.state;
    final qr = QRCode(value: "test", status: 0, createdAt: DateTime.now(), deletedAt: null);

    stream.listen(
      expectAsync1((state) {
        expect(state, QRStreamState.updated);
      })
    );
    manager.addQRCodeToDB(qr);
  });


}

