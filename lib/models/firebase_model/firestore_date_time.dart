import 'package:cloud_firestore/cloud_firestore.dart';

/// Konverter kustom untuk mengonversi data dari JSON/Firestore ke tipe data [DateTime].
/// Mendukung tipe [Timestamp] dari Firestore, [DateTime], maupun String ISO-8601.
DateTime dateTimeFromJson(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}

/// Konverter kustom untuk mengonversi tipe data [DateTime] Flutter menjadi [Timestamp] Firestore.
Timestamp dateTimeToJson(DateTime value) => Timestamp.fromDate(value);
