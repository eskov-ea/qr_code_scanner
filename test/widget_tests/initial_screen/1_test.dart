import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qrs_scaner/mocks/db/mock_db_service.dart';
import 'package:qrs_scaner/services/cache_manager/cache_manager.dart';
import 'package:qrs_scaner/services/database/database_laers/qr_code_db_layer.dart';
import 'package:qrs_scaner/services/database/database_laers/sqlite_db_layer.dart';
import 'package:qrs_scaner/services/database/database_provider.dart';
import 'package:qrs_scaner/ui/screens/auth_screen.dart';
import 'package:qrs_scaner/ui/screens/initial_screen.dart';
import 'package:qrs_scaner/ui/widgets/circle_progress_widget.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void sqfliteTestInit() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}
class FakeRoute extends Fake implements Route {}

void main() {
  sqfliteTestInit();
  registerFallbackValue(FakeRoute());
  setUpAll(() {
    GetIt.I.registerSingleton<DBProvider>(
        Mock_DatabaseService(sqliteDbLayer: SQLiteDBLayer(), qrCodeDbLayer: QRCodeDBLayer())
    );
    GetIt.I.registerSingleton<CacheManager>(CacheManager());
  });

  final mockObserver = MockNavigatorObserver();

  group('Initial Screen test', () {
    testWidgets('Test that initial screen works as expected', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
            MaterialApp(
              navigatorObservers: [mockObserver],
              // onGenerateRoute: (settings) {
              //   print("Navigation --> settings: ${settings.name}");
              //   return null;
              // },
              home:  InitialScreen()
            )
        );
        final InitialScreenState state = tester.state(find.byType(InitialScreen));
        expect(find.byType(CircleProgressWidget), findsOneWidget);
        await Future.delayed(const Duration(seconds: 2));
        // expect(find.byType(AuthScreen), findsOneWidget);
        // verify(() => mockObserver.didPop(any(), any()));
        verify(() => mockObserver.didReplace(newRoute: any(), oldRoute: any()));
      });
    });
  });

}