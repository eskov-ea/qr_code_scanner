import 'package:flutter/material.dart';
import 'package:qrs_scaner/ui/widgets/qr_code/linear_app_progress_indicator.dart';

class SendingQrCodesProgressDialog {
  static Future showProgressDialog(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context)
        {
          return Dialog(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  bottomLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                  bottomRight: Radius.circular(6)
              ),
              child: Container(
                height: 350,
                padding: const EdgeInsets.only(left: 5, right: 10),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFFFF),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(height: 20),
                    const Text("Пожалуйста, подождите",
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 200,
                      padding: const EdgeInsets.only(left: 10),
                      child: Image.asset(
                        "assets/icons/qr-scan.gif",
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const Expanded(child: AppLinearProgressIndicator()),
                    const SizedBox(height: 20)
                  ],
                ),
              ),
            ),
          );
        });
  }
}