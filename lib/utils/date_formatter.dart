import 'package:intl/intl.dart';

class DateFormatter {
  // Format tanggal dan waktu: 01/01/2025, 14:30
  static String formatDateTime(DateTime datetime) {
    return DateFormat('dd/MM/yyyy, HH:mm').format(datetime);
  }

  // Format hanya tanggal: 01 Januari 2025
  static String formatDateOnly(DateTime datetime) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(datetime);
  }

  // Format hanya jam: 14:30
  static String formatTimeOnly(DateTime datetime) {
    return DateFormat('HH:mm').format(datetime);
  }

  // Format untuk nama hari: Senin
  static String formatDayName(DateTime datetime) {
    return DateFormat('EEEE', 'id_ID').format(datetime);
  }

  // Check if two dates are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Get relative time (hari ini, kemarin, etc)
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCompare = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateToCompare == today) {
      return 'Hari ini';
    } else if (dateToCompare == yesterday) {
      return 'Kemarin';
    } else {
      return formatDateOnly(dateTime);
    }
  }
}
