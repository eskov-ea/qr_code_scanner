import 'package:qrs_scaner/models/qr_code.dart';

class ListExtension {
  static String toStringValues(List<QRCode> list) {
    String result = "";
    for (var i = 0; i < list.length; ++i) {
      if (i == 0) {
        result += list[i].value;
      } else {
        result += ", ${list[i].value}";
      }
    }
    return result;
  }
}