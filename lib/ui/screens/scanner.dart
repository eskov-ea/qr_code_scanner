import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qrs_scaner/exceptions/exceptions.dart';
import 'package:qrs_scaner/extentions/date_extension.dart';
import 'package:qrs_scaner/models/log.dart';
import 'package:qrs_scaner/models/qr_code.dart';
import 'package:qrs_scaner/services/database/database_provider.dart';
import 'package:qrs_scaner/services/error_handlers/error_handler_manager.dart';
import 'package:qrs_scaner/services/log_manager/log_manager.dart';
import 'package:qrs_scaner/services/qr_sending_manager/qr_sending_manager.dart';
import 'package:qrs_scaner/theme.dart';
import 'package:qrs_scaner/ui/widgets/console_widget.dart';
import 'package:qrs_scaner/ui/widgets/popup_manager.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({
    required this.selectedTab,
    super.key
  });

  final ValueNotifier<int> selectedTab;

  @override
  State<ScannerScreen> createState() => ScannerScreenState();
}

@visibleForTesting
class ScannerScreenState extends State<ScannerScreen> {

  final GlobalKey qrKey = GlobalKey(debugLabel: "QRScanner");
  final _audioManager = const MethodChannel("com.application.scanner/audio_manager");
  final _logManager = GetIt.instance.get<LogManager>();
  final _errorManager = GetIt.instance.get<ErrorHandlerManager>();
  Barcode? result;
  QRViewController? controller;
  final allowedFormat = [BarcodeFormat.dataMatrix];
  final db = GetIt.instance.get<DBProvider>();
  final _qrCodeSendingManager = GetIt.instance.get<QRCodeSendingManager>();
  bool cameraActive = true;
  DateTime? lastPermissionCheck;
  bool? cameraPermission;
  static const cameraNotPermittedMessage = "Для работы сканера необходимо разрешить доступ к камере. Вы можете сделать это в настройках приложения в списке приложений на устройстве.";

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      print("onRecognizeQR: $scanData");
      cameraActive = false;
      controller.pauseCamera();
      if (scanData.code != null) {
        try {
          final qrCode = QRCode(value: scanData.code!, status: 0, createdAt: DateTime.now().toUtc(), deletedAt: null);
          _saveQR(qrCode);
        } catch (err) {
          _audioManager.invokeMethod("PLAY_ERROR_SOUND");
          //TODO: inform UI
        }
      } else {
        _audioManager.invokeMethod("PLAY_ERROR_SOUND");
        cameraActive = true;
        controller.resumeCamera();
      }
    });
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      cameraActive = false;
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      cameraActive = true;
      controller!.resumeCamera();
    }
  }

  Future<void> _saveQR(QRCode qr) async {
    try {
      PopupManager.showLoadingPopup(context: context, message: 'Сохранение QR-кода в базу');
      final res = await db.addQRCode(qr);
      if (res > 0) {
        _qrCodeSendingManager.addQRCodeToDB(qr);
        _audioManager.invokeMethod("PLAY_SCANNER_SOUND");
        Navigator.of(context).pop();
        cameraActive = true;
        controller!.resumeCamera();
        _logManager.addLogEntity(Log.fromEvent("QR код успешно сохранен."));
      } else {
        cameraActive = false;
        controller!.pauseCamera();
        _audioManager.invokeMethod("PLAY_ERROR_SOUND");
        final QRCode code = await db.getQRCodeByValue(qr.value);
        Navigator.of(context).pop();
        PopupManager.showQRCodeExist(context, () {
          cameraActive = true;
          controller!.resumeCamera();
        }, "${DateTimeExtension.formatDate(code.createdAt)}");
        _logManager.addLogEntity(Log.fromEvent("Ошибка! QR код [ ${code.value} ] уже сохранен!"));
      }
    }  catch(err, stackTrace) {
      Navigator.of(context).pop();
      _logManager.addLogEntity(Log.fromEvent("Ошибка записи кода в базу данных!"));
      _errorManager.sinkEvent(AppException(type: AppExceptionType.db));
      print("Saving QR error: $err");
    }
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    print('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      if (lastPermissionCheck == null || lastPermissionCheck!.add(const Duration(seconds: 90)).compareTo(DateTime.now().toUtc()) < 0) {
        lastPermissionCheck = DateTime.now().toUtc();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Необходимо разрешить доступ к камере')),
        );
      }
    }
    if (cameraPermission == null || cameraPermission != p) {
      setState(() {
        cameraPermission = p;
      });
    }
  }


  Widget QRViewWrappedWidget(double scanArea) {
    return Stack(
      children: [
        QRView(
          key: qrKey,
          overlay: QrScannerOverlayShape(
              borderColor: Colors.red,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: scanArea
          ),
          formatsAllowed: allowedFormat,
          onQRViewCreated: _onQRViewCreated,
          onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
        ),
        if (cameraPermission == null) const Center(
          child: SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              color: Colors.white,
              backgroundColor: Colors.white38,
              strokeCap: StrokeCap.round,
            ),
          ),
        ),
        if (cameraPermission != null && !cameraPermission!) Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Center(
            child: GestureDetector(
              onTap: () {

              },
              child: Container(
                child: Text(cameraNotPermittedMessage,
                  style: TextStyle(color: Colors.white, fontSize: 12, height: 1),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        if (cameraPermission != null && !cameraPermission!) Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.only(right: 10, bottom: 10),
            child: SizedBox(
              width: 30,
              height: 30,
              child: Image.asset("assets/images/warning.png"),
            ),
          ),
        ),
        if (cameraPermission == true && cameraActive) Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.only(right: 10, bottom: 10),
            child: SizedBox(
              width: 30,
              height: 30,
              child: Icon(Icons.circle, color: Colors.red, size: 20),
            ),
          ),
        ),
        if (cameraPermission == true && !cameraActive) Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.only(right: 10, bottom: 10),
            child: SizedBox(
              width: 30,
              height: 30,
              child: Icon(Icons.pause, color: Colors.white, size: 20),
            ),
          ),
        )
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    widget.selectedTab.addListener(() {
      if (widget.selectedTab.value == 0) {
        cameraActive = true;
        controller?.resumeCamera();
      } else {
        cameraActive = false;
        controller?.pauseCamera();
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 220.0;

    return Material(
      color: AppColors.backgroundMain3,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color: Colors.white,
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            ClipRRect(
              key: const Key("ss_scanner_view"),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                    maxHeight: 300,
                    minHeight: 200
                ),
                child: Container(
                  color: Colors.black,
                  child: QRViewWrappedWidget(scanArea),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Expanded(
              key: Key("ss_code_events_console_screen"),
              child: Console()
            ),
            const SizedBox(height: 20),
            SizedBox(
              key: const Key("ss_scanner_controls_panel"),
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: Ink(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                          color: Color(0x4DFFFFFF),
                        ),
                        child: FutureBuilder(
                          future: controller?.getFlashStatus(),
                          builder: (context, snapshot) {
                            return InkWell(
                                onTap: () async {
                                  await controller?.toggleFlash();
                                  setState(() {});
                                },
                                customBorder: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(6))
                                ),
                                splashColor: Colors.blue.shade400,
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(6)),
                                      color: Color(0x80FFFFFF)
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(13),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(width: 3, color: Colors.blue.shade700),
                                        color: Color(0x8CFFFFFF)
                                    ),
                                    child: snapshot.data == null
                                        ? Image.asset("assets/icons/no-flash.png")
                                        : Image.asset(
                                        snapshot.data! ? "assets/icons/flash.png" : "assets/icons/no-flash.png"
                                    ),
                                  ),
                                )
                            );
                          },
                        )
                    ),
                  ),
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: Ink(
                        key: const Key("ss_scanner_control_resume_button"),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                          color: AppColors.cardColor5,
                        ),
                        child: InkWell(
                          onTap: () async {
                            if (cameraActive) {
                              cameraActive = false;
                              await controller?.pauseCamera();
                            } else {
                              cameraActive = true;
                              await controller?.resumeCamera();
                            }
                            setState(() {});
                          },
                          customBorder: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(6))
                          ),
                          splashColor: Colors.blue.shade400,
                          child: Center(
                            child: Text(cameraActive ? "Остановить сканер" : "Сканировать",
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, height: 1),
                            )
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
