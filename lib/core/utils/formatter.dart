import 'package:intl/intl.dart';

class Formatter {
  static String formatDate(DateTime dateTime) {
    try {
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    } catch (_) {
      return dateTime.toString();
    }
  }
}
