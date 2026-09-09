import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class MateriHistoryModel {
  final String? id;
  final String userEmail;
  final int materiId;
  final String materiName;
  final int durationSeconds;
  final String createdAt;

  MateriHistoryModel({
    this.id,
    this.userEmail = '',
    required this.materiId,
    required this.materiName,
    required this.durationSeconds,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'user_email': userEmail,
      'materi_id': materiId,
      'materi_name': materiName,
      'duration_seconds': durationSeconds,
      'created_at': createdAt,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  /// Converts model into a Map suitable for Firebase Cloud Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'user_email': userEmail,
      'materi_id': materiId,
      'materi_name': materiName,
      'duration_seconds': durationSeconds,
      'created_at': createdAt,
    };
  }

  factory MateriHistoryModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    String resolvedDate;
    final rawDate = map['created_at'];
    if (rawDate is Timestamp) {
      resolvedDate = rawDate.toDate().toIso8601String();
    } else if (rawDate is DateTime) {
      resolvedDate = rawDate.toIso8601String();
    } else if (rawDate is String && rawDate.isNotEmpty) {
      resolvedDate = rawDate;
    } else {
      resolvedDate = DateTime.now().toIso8601String();
    }

    return MateriHistoryModel(
      id: docId ?? map['id']?.toString(),
      userEmail: (map['user_email'] as String?) ?? '',
      materiId: (map['materi_id'] as num?)?.toInt() ?? 0,
      materiName: (map['materi_name'] as String?) ?? '',
      durationSeconds: (map['duration_seconds'] as num?)?.toInt() ?? 0,
      createdAt: resolvedDate,
    );
  }

  /// Factory constructor to create a [MateriHistoryModel] from a Firestore [DocumentSnapshot]
  factory MateriHistoryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return MateriHistoryModel.fromMap(doc.data() ?? {}, docId: doc.id);
  }

  String toJson() => json.encode(toMap());

  factory MateriHistoryModel.fromJson(String source) =>
      MateriHistoryModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

