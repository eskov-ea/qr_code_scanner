import 'package:flutter/material.dart';
import 'package:qrs_scaner/theme.dart';
import 'package:qrs_scaner/ui/widgets/circle_progress_widget.dart';

class PopupManager {
  static Future<void> showLoadingPopup({
    required BuildContext context, String? message
  }) async {
    return showDialog(
        barrierDismissible: false,
        barrierColor: const Color(0x80FFFFFF),
        context: context,
        builder: (context) =>
          WillPopScope(
            onWillPop: () async => false,
            child: Dialog(
              shadowColor: const Color(0x00000000),
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: message == null ? const CircleProgressWidget() : CircleProgressWidget(message: message),
            ),
          )
    );
  }

  static Future<void> showInfoPopup(BuildContext context, {
    required bool dismissible,
    required String message,
    Widget? title
  }) {
    return showDialog(
        barrierDismissible: dismissible,
        barrierColor: const Color(0x73000000),
        context: context,
        builder: (context) =>
            Dialog(
              shadowColor: const Color(0x00000000),
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    bottomLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                    bottomRight: Radius.circular(6)
                ),
                child: Container(
                  height: 150,
                  padding: const EdgeInsets.only(left: 5, right: 10),
                  decoration: BoxDecoration(
                      color: const Color(0xFFEAEAEA),
                      border: Border(top: BorderSide(
                          color: AppColors.cardColor5, width: 10))
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: 60,
                        padding: const EdgeInsets.only(left: 10),
                        child: Image.asset(
                            "assets/icons/popup-warning-icon.png"),
                      ),
                      Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 20),
                                child: Text(message)
                            ),
                          )
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFFFFFF)
                          ),
                          child: const Icon(Icons.close),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
    );
  }

  static Future<void> showQRCodeExist(BuildContext context, Function callback, String qrTime) {
    return showDialog(
        barrierDismissible: false,
        barrierColor: const Color(0x73000000),
        context: context,
        builder: (context) =>
            Dialog(
              shadowColor: const Color(0x00000000),
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    bottomLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                    bottomRight: Radius.circular(6)
                ),
                child: Container(
                  height: 150,
                  padding: const EdgeInsets.only(left: 5, right: 10),
                  decoration: BoxDecoration(
                      color: const Color(0xFFEAEAEA),
                      border: Border(top: BorderSide(
                          color: AppColors.cardColor5, width: 10))
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: 60,
                        padding: const EdgeInsets.only(left: 10),
                        child: Image.asset(
                            "assets/icons/popup-warning-icon.png"),
                      ),
                      Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 20),
                                child: Text("Данный QR код уже был зарегистрирован в системе $qrTime")
                            ),
                          )
                      ),
                      GestureDetector(
                        onTap: () {
                          callback();
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFFFFFF)
                          ),
                          child: const Icon(Icons.close),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
    );
  }

  static Future<void> showErrorPopup(BuildContext context,
      {Function? callback, String message = "Произошла ошибка. Попробуйте еще раз, в случае если ошибка не устраняется - перезапустите приложение.", String image = "assets/images/error-message.png", bool dismissible = true}) {
    return showDialog(
        barrierDismissible: dismissible,
        barrierColor: const Color(0x73000000),
        context: context,
        builder: (context) =>
            Dialog(
              shadowColor: const Color(0x00000000),
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    bottomLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                    bottomRight: Radius.circular(6)
                ),
                child: Container(
                  height: 150,
                  padding: const EdgeInsets.only(left: 5, right: 10),
                  decoration: BoxDecoration(
                      color: const Color(0xFFEAEAEA),
                      border: Border(top: BorderSide(
                          color: AppColors.cardColor5, width: 10))
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: 60,
                        padding: const EdgeInsets.only(left: 10),
                        child: Image.asset(image),
                      ),
                      Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 20),
                                child: Text(message)
                            ),
                          )
                      ),
                      GestureDetector(
                        onTap: () {
                          if (callback != null) {
                            callback();
                          }
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFFFFFF)
                          ),
                          child: const Icon(Icons.close),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
    );
  }


  /// Predefined Error Widgets
  static Future<void> showBadNetworkConnectionPopup(BuildContext context) {
    return showErrorPopup(context, message: "Ошибка передачи данных. Убедитесь, что вы подключены к интернету, соединение стабильно.", image: "assets/images/network-error.png");
  }
  static Future<void> showDatabaseExceptionPopup(BuildContext context) {
    return showErrorPopup(context, message: "Ошибка записи/чтения данных. Попробуйте еще раз или перезагрузите приложения.", image: "assets/images/db-error.png");
  }
  static Future<void> showServerUnavailablePopup(BuildContext context) {
    return showErrorPopup(context, message: "Сервер недоступен. Подождите или обратитесь к системному администратору.", image: "assets/images/server-error.png");
  }
}