import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:qrs_scaner/mocks/db/mock_db_provider.dart';
import 'package:qrs_scaner/mocks/db/mock_db_service.dart';
import 'package:qrs_scaner/mocks/services/api/mock_api_provider.dart';
import 'package:qrs_scaner/services/api/api_repository.dart';
import 'package:qrs_scaner/services/cache_manager/cache_manager.dart';
import 'package:qrs_scaner/services/database/database_laers/logs_db_layer.dart';
import 'package:qrs_scaner/services/database/database_laers/qr_code_db_layer.dart';
import 'package:qrs_scaner/services/database/database_laers/sqlite_db_layer.dart';
import 'package:qrs_scaner/services/database/database_provider.dart';
import 'package:qrs_scaner/services/qr_sending_manager/qr_sending_manager.dart';
import 'package:qrs_scaner/ui/screens/qr_analytic.dart';
import 'package:qrs_scaner/ui/screens/scanner.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'scanner_plugin_helper.dart';

void sqfliteTestInit() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

void main() {
  sqfliteTestInit();
  setUpAll(() {
    GetIt.I.registerSingleton<DBProvider>(
        Mock_DatabaseService(sqliteDbLayer: SQLiteDBLayer(), qrCodeDbLayer: QRCodeDBLayer(), logsDBLayer: LogsDBLayer())
    );
    GetIt.I.registerSingleton<CacheManager>(CacheManager());
    GetIt.I.registerSingleton<QRCodeSendingManager>(QRCodeSendingManager(repository: QRCodeApiRepository(provider: Mock_QRCodeApiProvider())));

  });


  testWidgets('Scanner screen. Insure all the widgets are present on the screen', (WidgetTester tester) async {

    mockMethodChannels(tester);

    await tester.runAsync(() async {

      await tester.pumpWidget( MaterialApp(home: ScannerScreen(selectedTab: ValueNotifier(0))));
      final ScannerScreenState state = tester.state(find.byType(ScannerScreen));



      /// Widgets variables
      final Finder scanner = find.byKey(const Key("ss_scanner_view"));
      final Finder consoleView = find.byKey(const Key("ss_code_events_console_screen"));
      final Finder controlPanel = find.byKey(const Key("ss_scanner_controls_panel"));
      final Finder resumeButton = find.byKey(const Key("ss_scanner_control_resume_button"));

      expect(find.byType(ScannerScreen), findsOneWidget);
      expect(scanner, findsOneWidget);
      expect(consoleView, findsOneWidget);
      expect(controlPanel, findsOneWidget);
      expect(resumeButton, findsOneWidget);

    });
  });

}
