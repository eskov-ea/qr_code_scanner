import 'package:intl/intl.dart';

class DateTimeExtension {
  static String getRussianMonth(DateTime date) {
    switch(date.month){
      case 1:
        return "января";
      case 2:
        return "февраля";
      case 3:
        return "марта";
      case 4:
        return "апреля";
      case 5:
        return "мая";
      case 6:
        return "июня";
      case 7:
        return "июля";
      case 8:
        return "августа";
      case 9:
        return "сентября";
      case 10:
        return "октября";
      case 11:
        return "ноября";
      case 12:
        return "декабря";
      default: return date.month < 10 ? "0${date.month}" : "${date.month}";
    }
  }

  static String getDate(DateTime date) {
    final arr = DateFormat.yMd().format(date.add(DateTime.now().timeZoneOffset)).split('/');
    return "${arr[1]}.${int.parse(arr[0]) > 9 ? arr[0] : '0${arr[0]}'}.${arr[2]}";
  }

  static String getRussianDate(DateTime date) {
    final arr = DateFormat.yMd().format(date.add(DateTime.now().timeZoneOffset)).split('/');
    return [arr[1], getRussianMonth(date), arr[2]].join(" ");
  }

  static String getTime(DateTime date) {
    return DateFormat.Hm().format(date.add(DateTime.now().timeZoneOffset)).toString();
  }

  static bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  static bool isSameDateWithTimeZone(DateTime date1, DateTime date2) {
    date1 = date1.add(DateTime.now().timeZoneOffset);
    date2 = date2.add(DateTime.now().timeZoneOffset);
    print("DATE TIME::: $date1 <--> $date2");
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  static formatDate(DateTime datetime) {
    final time = DateFormat.Hm().format(datetime);
    final dateArray = DateFormat.yMd().format(datetime).split('/');
    final month = int.parse(dateArray[0]) < 10 ? "0${dateArray[0]}" : dateArray[0];
    String date = "${dateArray[1]}.$month.${dateArray[2]}";

    return "$date $time";
  }
}