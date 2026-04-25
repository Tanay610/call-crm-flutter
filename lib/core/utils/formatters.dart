import 'package:intl/intl.dart';

class Formatters {
  static final DateFormat _dateTime = DateFormat('MMM d, yyyy • h:mm a');

  static String dateTime(DateTime value) => _dateTime.format(value);

  static String durationMillis(int millis) {
    final d = Duration(milliseconds: millis);
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = d.inHours;
    if (hours > 0) return '$hours:$minutes:$seconds';
    return '${d.inMinutes}:$seconds';
  }

  static String fileSize(int bytes) {
    const kb = 1024;
    const mb = 1024 * 1024;
    if (bytes >= mb) return '${(bytes / mb).toStringAsFixed(2)} MB';
    if (bytes >= kb) return '${(bytes / kb).toStringAsFixed(1)} KB';
    return '$bytes B';
  }
}

