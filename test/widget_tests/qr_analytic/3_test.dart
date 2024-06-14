import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:qrs_scaner/mocks/db/mock_db_provider.dart';
import 'package:qrs_scaner/mocks/db/mock_db_service.dart';
import 'package:qrs_scaner/mocks/services/api/mock_api_provider.dart';
import 'package:qrs_scaner/mocks/services/api/mock_qr_sending_manager.dart';
import 'package:qrs_scaner/models/qr_code.dart';
import 'package:qrs_scaner/services/api/api_repository.dart';
import 'package:qrs_scaner/services/database/database_laers/qr_code_db_layer.dart';
import 'package:qrs_scaner/services/database/database_laers/sqlite_db_layer.dart';
import 'package:qrs_scaner/services/database/database_provider.dart';
import 'package:qrs_scaner/services/qr_sending_manager/qr_sending_manager.dart';
import 'package:qrs_scaner/ui/screens/qr_analytic.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void sqfliteTestInit() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

void main() {
  sqfliteTestInit();
  setUpAll(() {
    GetIt.I.registerSingleton<DBProvider>(
        Mock_DBProvider(sqliteDbLayer: SQLiteDBLayer(), qrCodeDbLayer: QRCodeDBLayer())
    );
    GetIt.I.registerSingleton<QRCodeSendingManager>(QRCodeSendingManager(repository: QRCodeApiRepository(provider: Mock_QRCodeApiProvider())));
  });

  final qr1 = QRCode(value: "qr1", status: 0, createdAt: DateTime.now(), deletedAt: null);

  testWidgets('QRAnalyticScreen test. Widget listens to [QRCodeSendingManager] events', (WidgetTester tester) async {
    final service = GetIt.instance.get<QRCodeSendingManager>();
    await tester.pumpWidget(const MaterialApp(home: QRAnalyticScreen()));
    final QRAnalyticScreenState state = tester.state(find.byType(QRAnalyticScreen));

    await tester.runAsync(() async {
      await state.initializeQRCodes();
      await Future.delayed(const Duration(seconds: 3));
      expect(state.qrcodes?.length, 0);

      // service.state.listen(expectAsync1((event) {
      //   expect(event, QRStreamState.updated);
      // }));

      service.addQRCodeToDB(qr1);
      await Future.delayed(const Duration(seconds: 3));
    });
    expect(state.qrcodes?.length, 1);
  });

}
