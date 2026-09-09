import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizHistoryModel {
  final String? id;
  final String userEmail;
  final int quizId;
  final double score;
  final String createdAt;

  QuizHistoryModel({
    this.id,
    this.userEmail = '',
    required this.quizId,
    required this.score,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'user_email': userEmail,
      'quiz_id': quizId,
      'score': score,
      'created_at': createdAt,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  /// Converts the model into a Firestore-friendly Map.
  Map<String, dynamic> toFirestore() {
    return {
      'user_email': userEmail,
      'quiz_id': quizId,
      'score': score,
      'created_at': createdAt,
    };
  }

  factory QuizHistoryModel.fromMap(Map<String, dynamic> map, {String? docId}) {
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

    return QuizHistoryModel(
      id: docId ?? map['id']?.toString(),
      userEmail: (map['user_email'] as String?) ?? '',
      quizId: (map['quiz_id'] as num?)?.toInt() ?? 0,
      score: (map['score'] as num?)?.toDouble() ?? 0.0,
      createdAt: resolvedDate,
    );
  }

  /// Factory constructor to create a [QuizHistoryModel] from a Firestore [DocumentSnapshot].
  factory QuizHistoryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return QuizHistoryModel.fromMap(doc.data() ?? {}, docId: doc.id);
  }

  String toJson() => json.encode(toMap());

  factory QuizHistoryModel.fromJson(String source) =>
      QuizHistoryModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
