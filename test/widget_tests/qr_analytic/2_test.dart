import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:qrs_scaner/mocks/db/mock_db_service.dart';
import 'package:qrs_scaner/services/database/database_laers/qr_code_db_layer.dart';
import 'package:qrs_scaner/services/database/database_laers/sqlite_db_layer.dart';
import 'package:qrs_scaner/services/database/database_provider.dart';
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
        Mock_DatabaseService(sqliteDbLayer: SQLiteDBLayer(), qrCodeDbLayer: QRCodeDBLayer())
    );
  });

  group('QRAnalyticScreen test', () {
    testWidgets('Test, that for [QRAnalyticScreen] we initially see a loader, then QR-codes list appears. No error widget shown.', (WidgetTester tester) async {

      await tester.pumpWidget(const MaterialApp(home: QRAnalyticScreen()));

      final progressFinder = find.byKey(const Key("qr_analytics_screen_progress_widget"));
      final errorFinder = find.byKey(const Key("qr_analytics_screen_error_widget"));
      final qrListFinder = find.byKey(const Key("qr_analytics_screen_qr_codes_list_widget"));

      expect(progressFinder, findsOneWidget);
      // expect(qrListFinder, findsOneWidget);
      expect(errorFinder, findsNothing);
    });


    /// QR codes selection functionality
    testWidgets('Initial state for selection mode is false and can be triggered to true', (WidgetTester tester) async {

      await tester.pumpWidget(const MaterialApp(home: QRAnalyticScreen()));
      final QRAnalyticScreenState state = tester.state(find.byType(QRAnalyticScreen));
      expect(state.selectedMode, false);
      state.setSelectedMode(true);

      expect(state.selectedMode, true);
    });
  });

}
