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
}