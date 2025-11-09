import 'package:intl/intl.dart';

/// Utility class untuk format tanggal
class DateFormatter {
  /// Format tanggal dari ISO 8601 ke format yang lebih readable
  static String formatDate(String isoDate) {
    try {
      final dateTime = DateTime.parse(isoDate);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      // Jika kurang dari 1 jam
      if (difference.inHours < 1) {
        return '${difference.inMinutes} menit yang lalu';
      }
      // Jika kurang dari 24 jam
      else if (difference.inHours < 24) {
        return '${difference.inHours} jam yang lalu';
      }
      // Jika kurang dari 7 hari
      else if (difference.inDays < 7) {
        return '${difference.inDays} hari yang lalu';
      }
      // Format tanggal lengkap
      else {
        return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dateTime);
      }
    } catch (e) {
      return isoDate;
    }
  }
  
  /// Format tanggal lengkap
  static String formatFullDate(String isoDate) {
    try {
      final dateTime = DateTime.parse(isoDate);
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(dateTime);
    } catch (e) {
      return isoDate;
    }
  }
}
