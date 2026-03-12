import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Formatters {
  String formatTimeInMessages(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('HH:mm').format(date); // 13:42
  }

  String formatDateSeparator(Timestamp timestamp) {
    final date = timestamp.toDate();
    // Keep it simple and stable (no "Today"/"Yesterday" special-casing)
    return DateFormat('d MMM yyyy').format(date); // e.g. 5 Feb 2026
  }
}