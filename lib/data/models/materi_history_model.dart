import 'dart:convert';

class MateriHistoryModel {
  final int? id;
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

  factory MateriHistoryModel.fromMap(Map<String, dynamic> map) {
    return MateriHistoryModel(
      id: map['id'] != null ? (map['id'] as num).toInt() : null,
      userEmail: (map['user_email'] as String?) ?? '',
      materiId: (map['materi_id'] as num).toInt(),
      materiName: map['materi_name'] as String,
      durationSeconds: (map['duration_seconds'] as num).toInt(),
      createdAt: map['created_at'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory MateriHistoryModel.fromJson(String source) =>
      MateriHistoryModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
