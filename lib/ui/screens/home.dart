import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:qrs_scaner/exceptions/exceptions.dart';
import 'package:qrs_scaner/factories/screen_factory.dart';
import 'package:qrs_scaner/services/database/database_provider.dart';
import 'package:qrs_scaner/services/error_handlers/error_handler_manager.dart';
import 'package:qrs_scaner/services/log_manager/log_manager.dart';
import 'package:qrs_scaner/services/qr_sending_manager/qr_sending_manager.dart';
import 'package:qrs_scaner/theme.dart';
import 'package:qrs_scaner/ui/widgets/appbar/custom_appbar.dart';
import 'package:qrs_scaner/ui/widgets/popup_manager.dart';
import 'package:qrs_scaner/ui/widgets/sending_qrcodes_progress_dialog.dart';
import 'package:qrs_scaner/ui/widgets/session_expired.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {

  final _screenFactory = ScreenFactory();
  final ValueNotifier<int> _selectedTab = ValueNotifier<int>(0);
  final db = GetIt.instance.get<DBProvider>();
  final _errorManager = GetIt.instance.get<ErrorHandlerManager>();
  final _logManager = GetIt.instance.get<LogManager>();
  late final StreamSubscription<AppException> _errorEventSubscription;

  void onSelectTab(int index) {
    if (_selectedTab.value == index) return;
    setState(() {
      _selectedTab.value = index;
    });
  }

  late final StreamSubscription _qrManagerStateSubscription;
  bool showSendingDialog = false;

  void _onErrorHandler(AppException error) {
    switch (error.type) {
      case AppExceptionType.access:
        SessionExpiredModalWidget(context, db);
      case AppExceptionType.network:
        PopupManager.showBadNetworkConnectionPopup(context);
      case AppExceptionType.db:
        PopupManager.showDatabaseExceptionPopup(context);
      case AppExceptionType.server:
        PopupManager.showServerUnavailablePopup(context);
      case AppExceptionType.other:
        PopupManager.showErrorPopup(context);
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _qrManagerStateSubscription = GetIt.instance.get<QRCodeSendingManager>().state.listen(_onQRStreamEvent);
    _errorEventSubscription = _errorManager.events.listen(_onErrorHandler);
    super.initState();
  }

  @override
  void dispose() {
    _qrManagerStateSubscription.cancel();
    _errorEventSubscription.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch(state){
      case AppLifecycleState.resumed:
      case AppLifecycleState.paused:
        await _logManager.saveCodesToDb();
      default:
    }
  }

  void _onQRStreamEvent(QRStreamState state) {
    if (state == QRStreamState.none) {
      if (showSendingDialog) {
        showSendingDialog = false;
        Navigator.of(context).pop();
      }
    } else if (state == QRStreamState.sending) {
        showSendingDialog = true;
        SendingQrCodesProgressDialog.showProgressDialog(context);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: IndexedStack(
        index: _selectedTab.value,
        children: [
          _screenFactory.makeScannerScreen(_selectedTab),
          _screenFactory.makeQRAnalyticScreen(),
          _screenFactory.makeSettingsScreen(),
        ],
      ),
      bottomNavigationBar: Row(
        children: [
          if (MediaQuery.of(context).size.width > 700) const Spacer(),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width > 700 ? 700 : MediaQuery.of(context).size.width
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedTab.value,
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.backgroundNeutral,
              selectedItemColor: AppColors.backgroundMain3,
              unselectedItemColor: null,
              onTap: onSelectTab,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.camera_viewfinder),
                  label: 'Сканер',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.qrcode_viewfinder),
                  label: 'QR-коды',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.settings_solid),
                  label: 'Настройки',
                ),
              ],
            ),
          ),
          if (MediaQuery.of(context).size.width > 700) const Spacer(),
        ],
      )
    );
  }
}
