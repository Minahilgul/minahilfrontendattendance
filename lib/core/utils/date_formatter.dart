import 'package:intl/intl.dart';

class DateFormatter {
  static String format(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty || rawDate == '-') return '-';
    
    try {
      final dateTime = DateTime.parse(rawDate).toLocal();
      return DateFormat('dd-MM-yyyy hh:mm a').format(dateTime);
    } catch (e) {
      return rawDate;
    }
  }

  static String formatShort(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty || rawDate == '-') return '-';
    
    try {
      final dateTime = DateTime.parse(rawDate).toLocal();
      return DateFormat('dd-MM-yyyy').format(dateTime);
    } catch (e) {
      return rawDate;
    }
  }
}
