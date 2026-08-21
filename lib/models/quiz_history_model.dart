import 'dart:convert';

class QuizHistoryModel {
  final int? id;
  final int quizId;
  final double score;
  final String createdAt;

  QuizHistoryModel({
    this.id,
    required this.quizId,
    required this.score,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'quiz_id': quizId,
      'score': score,
      'created_at': createdAt,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory QuizHistoryModel.fromMap(Map<String, dynamic> map) {
    return QuizHistoryModel(
      id: map['id'] != null ? (map['id'] as num).toInt() : null,
      quizId: (map['quiz_id'] as num).toInt(),
      score: (map['score'] as num).toDouble(),
      createdAt: map['created_at'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory QuizHistoryModel.fromJson(String source) =>
      QuizHistoryModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
