import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/src/foundation/diagnostics.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ThrowableQRView extends QRView {
  ThrowableQRView({
      required this.key,
      required this.onPermissionSet,
      required this.formatsAllowed,
      required this.onQRViewCreated,
      required this.overlay
  }) : super(key: key, onQRViewCreated: onQRViewCreated);



  @override
  Future<void> updateDimensions() async {
    throw Exception();
  }

  @override
  bool onNotification() {
    throw Exception();
  }


  @override
  Widget build(BuildContext context) {
    return QRView(key: key, onQRViewCreated: onQRViewCreated);
  }

  @override
  CameraFacing get cameraFacing => throw UnsupportedError(
      "Trying to use the default qrview implementation for $defaultTargetPlatform but there isn't a default one");


  final Key key;
  final PermissionSetCallback? onPermissionSet;
  final List<BarcodeFormat> formatsAllowed;
  final QRViewCreatedCallback onQRViewCreated;
  final QrScannerOverlayShape? overlay;


  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}