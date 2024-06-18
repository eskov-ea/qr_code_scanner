import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:qrs_scaner/services/api/api_provider.dart';
import 'package:qrs_scaner/services/api/api_repository.dart';
import 'package:qrs_scaner/services/cache_manager/cache_manager.dart';
import 'package:qrs_scaner/services/database/database_laers/config_db_layer.dart';
import 'package:qrs_scaner/services/database/database_laers/qr_code_db_layer.dart';
import 'package:qrs_scaner/services/database/database_laers/sqlite_db_layer.dart';
import 'package:qrs_scaner/services/database/database_provider.dart';
import 'package:qrs_scaner/services/qr_sending_manager/qr_sending_manager.dart';
import 'package:qrs_scaner/ui/screens/initial_screen.dart';

void main() {
  runApp(const MyApp());
}

void configureApp() {
  if (!GetIt.I.isRegistered<DBProvider>()) {
    GetIt.I.registerSingleton<DBProvider>(DBProvider(
        sqliteDbLayer: SQLiteDBLayer(), qrCodeDbLayer: QRCodeDBLayer(), configDBLayer: ConfigDBLayer())
    );
  }
  if (!GetIt.I.isRegistered<CacheManager>()) {
    GetIt.I.registerSingleton<CacheManager>(CacheManager());
  }
  if (!GetIt.I.isRegistered<QRCodeApiRepository>()) {
    GetIt.I.registerSingleton<QRCodeApiRepository>(QRCodeApiRepository(provider: QRCodeApiProvider()));
  }
  if (!GetIt.I.isRegistered<QRCodeSendingManager>()) {
    GetIt.I.registerSingleton<QRCodeSendingManager>(QRCodeSendingManager(repository: QRCodeApiRepository(provider: QRCodeApiProvider())));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    /// Initialize App's instances
    configureApp();

    return MaterialApp(
      title: 'QR_Code_Scanner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const InitialScreen()
    );
  }

}

