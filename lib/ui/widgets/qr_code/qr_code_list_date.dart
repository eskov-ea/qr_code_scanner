import 'package:flutter/material.dart';
import 'package:qrs_scaner/extentions/date_extension.dart';
import 'package:qrs_scaner/theme.dart';

class QRCodeListDate extends StatelessWidget {
  const QRCodeListDate(this.date, {super.key});

  final DateTime date;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15, bottom: 5),
      height: 30,
      width: 150,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(6)),
        color: AppColors.backgroundNeutral
      ),
      child: Align(
        alignment: Alignment.center,
        child: Text(DateTimeExtension.getRussianDate(date),
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w300),
          textAlign: TextAlign.center,
        )
      ),
    );
  }
}
