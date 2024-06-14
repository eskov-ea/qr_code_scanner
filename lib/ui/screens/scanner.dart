import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qrs_scaner/models/qr_code.dart';
import 'package:qrs_scaner/services/database/database_provider.dart';
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
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {

  final GlobalKey qrKey = GlobalKey(debugLabel: "QRScanner");
  final _audioManager = const MethodChannel("com.application.scanner/audio_manager");
  Barcode? result;
  QRViewController? controller;
  final allowedFormat = [BarcodeFormat.dataMatrix];
  final db = GetIt.instance.get<DBProvider>();
  bool cameraActive = false;

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      _audioManager.invokeMethod("PLAY_SCANNER_SOUND");
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
        Navigator.of(context).pop();
      } else {
        final QRCode code = await db.getQRCodeByValue(qr.value);
        Navigator.of(context).pop();
        PopupManager.showInfoPopup(context, dismissible: true, message: 'Данный QR код уже был зарегистрирован в системе ${code.createdAt}' );
      }
      controller!.resumeCamera();
    }  catch(err, stackTrace) {
      Navigator.of(context).pop();
      print("Saving QR error: $err");
    }
  }

  Future<void> showSavedQRDialog() async {

  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    print('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
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
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                    maxHeight: 300,
                    minHeight: 200
                ),
                child: QRView(
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
              ),
            ),
            const SizedBox(height: 10),
            const Expanded(
              child: Console()
            ),
            const SizedBox(height: 20),
            SizedBox(
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
