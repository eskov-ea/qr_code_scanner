import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:qrs_scaner/mocks/db/mock_db_service.dart';
import 'package:qrs_scaner/mocks/services/api/mock_api_provider.dart';
import 'package:qrs_scaner/mocks/services/api/mock_qr_sending_manager.dart';
import 'package:qrs_scaner/models/qr_code.dart';
import 'package:qrs_scaner/services/api/api_provider.dart';
import 'package:qrs_scaner/services/api/api_repository.dart';
import 'package:qrs_scaner/services/cache_manager/cache_manager.dart';
import 'package:qrs_scaner/services/database/database_laers/logs_db_layer.dart';
import 'package:qrs_scaner/services/database/database_laers/qr_code_db_layer.dart';
import 'package:qrs_scaner/services/database/database_laers/sqlite_db_layer.dart';
import 'package:qrs_scaner/services/database/database_provider.dart';
import 'package:qrs_scaner/services/qr_sending_manager/qr_sending_manager.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';




Future main() async {

  setUpAll(() {
    GetIt.I.registerSingleton<DBProvider>(
        Mock_DatabaseService(sqliteDbLayer: SQLiteDBLayer(), qrCodeDbLayer: QRCodeDBLayer(), logsDBLayer: LogsDBLayer())
    );
    GetIt.I.registerSingleton<CacheManager>(CacheManager());
    GetIt.I.registerSingleton<QRCodeSendingManager>(QRCodeSendingManager(repository: QRCodeApiRepository(provider: Mock_QRCodeApiProvider())));
  });

  test('We can add [ QR Code ] to stream and listen to the result', () async {
    final manager = GetIt.instance.get<QRCodeSendingManager>();
    final stream = manager.codes;
    final qr = QRCode(value: "test", status: 0, createdAt: DateTime.now(), deletedAt: null);

    stream.listen(
        expectAsync1((state) {
          expect(state, qr);
        })
    );

    manager.addQRCodeToDB(qr);
  });


  test('sendQRCodesToServer method', () async {
    /// We get list of codes to send to the server as argument.
    /// We emit state: [ SENDING ].
    /// We run in a loop while all the codes are processed.
    /// Inform UI that we prepare the portion for sending. Send this portion.
    /// We emit state: [ NONE ] to inform UI that we finish and no work are running.

    final manager = GetIt.instance.get<QRCodeSendingManager>();
    final codes = [
      QRCode(value: "test1", status: 0, createdAt: DateTime.now(), deletedAt: null),
      QRCode(value: "test2", status: 0, createdAt: DateTime.now(), deletedAt: null),
      QRCode(value: "test3", status: 0, createdAt: DateTime.now(), deletedAt: null),
      QRCode(value: "test4", status: 0, createdAt: DateTime.now(), deletedAt: null),
      QRCode(value: "test5", status: 0, createdAt: DateTime.now(), deletedAt: null),
      QRCode(value: "test6", status: 0, createdAt: DateTime.now(), deletedAt: null),
      QRCode(value: "test7", status: 0, createdAt: DateTime.now(), deletedAt: null),
      QRCode(value: "test8", status: 0, createdAt: DateTime.now(), deletedAt: null),
      QRCode(value: "test9", status: 0, createdAt: DateTime.now(), deletedAt: null),
      QRCode(value: "test10", status: 0, createdAt: DateTime.now(), deletedAt: null),
    ];
    final states = <QRStreamState>[];
    manager.state.listen((state) { states.add(state); });

    manager.sendQRCodesToServer(codes);

    await Future.delayed(const Duration(seconds: 5));

    expect(states[0], QRStreamState.sending);
    expect(states[1], QRStreamState.none);
    expect(states[2], QRStreamState.atoned);
    expect(states[3], QRStreamState.updated);

  });


}

