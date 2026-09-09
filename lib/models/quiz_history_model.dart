import 'dart:convert';

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

  factory QuizHistoryModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return QuizHistoryModel(
      id: docId ?? map['id']?.toString(),
      userEmail: (map['user_email'] as String?) ?? '',
      quizId: (map['quiz_id'] as num?)?.toInt() ?? 0,
      score: (map['score'] as num?)?.toDouble() ?? 0.0,
      createdAt: (map['created_at'] as String?) ?? DateTime.now().toIso8601String(),
    );
  }

  String toJson() => json.encode(toMap());

  factory QuizHistoryModel.fromJson(String source) =>
      QuizHistoryModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
