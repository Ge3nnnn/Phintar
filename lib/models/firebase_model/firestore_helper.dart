import 'package:cloud_firestore/cloud_firestore.dart';

/// Mengonversi nilai dari Firestore (Timestamp, String, atau int) menjadi [DateTime].
DateTime dateTimeFromJson(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  } else if (value is DateTime) {
    return value;
  } else if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.now();
  } else if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  return DateTime.now();
}

/// Mengonversi [DateTime] menjadi Firestore [Timestamp].
dynamic dateTimeToJson(DateTime dateTime) => Timestamp.fromDate(dateTime);
