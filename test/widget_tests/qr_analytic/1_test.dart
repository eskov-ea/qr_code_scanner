import 'package:flutter/material.dart';
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
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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


  testWidgets('QRAnalyticScreen test. We initialize state with mock data. We can turn on selected mode by tap "Выбрать" button. '
      'Then we tap "Выделить все" button, it should select all available codes.', (WidgetTester tester) async {
    await tester.runAsync(() async {

      await tester.pumpWidget(const MaterialApp(home: QRAnalyticScreen()));
      final QRAnalyticScreenState state = tester.state(find.byType(QRAnalyticScreen));
      await state.initializeQRCodes();
      await tester.pump(const Duration(seconds: 3));
      expect(state.qrcodes?.isNotEmpty, true);


      /// Widgets variables
      final selectionPanel = find.byKey(const Key("qr_selection_control_panel"));
      final selectAllBtn = find.byKey(const Key("qr_selection_control_panel_select_all_button"));
      final unselectAllBtn = find.byKey(const Key("qr_selection_control_panel_unselect_all_button"));
      final selectedCodesControlPanel = find.byKey(const Key("qr_analytics_selected_codes_control_panel"));
      final activateSelectionModeBtn = find.byKey(const Key("activate_selection_mode_btn"));


      /// Test that we can call selection mode and it works properly. On selection mode the selection control panel should appear.
      await tester.tap(activateSelectionModeBtn);
      expect(state.selectedMode, true);
      await tester.pumpAndSettle();

      /// Test we can tap [selectAll], [unselectAll] buttons and it works properly.
      expect(selectionPanel, findsOneWidget);
      expect(selectAllBtn, findsOneWidget);
      expect(selectedCodesControlPanel, findsOneWidget);

      await tester.tap(selectAllBtn);
      expect(state.selectedCodes.value.length, state.qrcodes?.length);
      await tester.tap(unselectAllBtn);
      expect(state.selectedCodes.value.length, 0);

      await tester.tap(selectAllBtn);

      /// Test we can trigger selected qr codes control panel to atone codes or dismiss selected mode.
      final dismissCodesControlPanelBtn  = find.byKey(const Key("qr_analytics_selected_codes_control_panel_dismiss"));
      final atoneSelectedCodesBtn = find.byKey(const Key("qr_analytics_selected_codes_control_panel_atone"));

      ////// Test dismiss selected mode.
      await tester.tap(dismissCodesControlPanelBtn);
      await tester.pumpAndSettle();
      expect(selectedCodesControlPanel, findsNothing);
      expect(selectAllBtn, findsNothing);
      expect(unselectAllBtn, findsNothing);
      expect(activateSelectionModeBtn, findsOneWidget);
      expect(state.selectedMode, false);
      expect(state.selectedCodes.value.length, 0);

      ////// Test we can successfully atone all the codes
      ////// We set the delay amount to wait all the codes would be deleted. This amount of time depends on the count length of codes in DB.
      await tester.tap(activateSelectionModeBtn);
      await tester.pumpAndSettle();
      await tester.tap(selectAllBtn);
      await tester.pumpAndSettle();

      await tester.tap(atoneSelectedCodesBtn);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 30));
      expect(state.qrcodes?.length, 0);
    });
  });

}
