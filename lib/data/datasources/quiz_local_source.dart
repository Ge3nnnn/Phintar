import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:blabla/data/models/quiz_model.dart';

/// Local datasource for quiz content.
/// Loads quiz data from JSON seed asset.
class QuizLocalSource {
  List<QuizModel>? _cachedQuizzes;

  /// Returns all quizzes sorted by [sort_order].
  Future<List<QuizModel>> getAllQuizzes() async {
    return await getAllQuizzesWithQuestions();
  }

  /// Returns a quiz with its questions loaded.
  Future<QuizModel?> getQuizWithQuestions(int quizId) async {
    final quizzes = await getAllQuizzesWithQuestions();
    try {
      return quizzes.firstWhere((q) => q.id == quizId);
    } catch (_) {
      return null;
    }
  }

  /// Returns all quizzes with their questions loaded.
  Future<List<QuizModel>> getAllQuizzesWithQuestions() async {
    if (_cachedQuizzes != null) return _cachedQuizzes!;
    try {
      final jsonString =
          await rootBundle.loadString('assets/seed/quiz_seed.json');
      final List<dynamic> list = json.decode(jsonString);
      _cachedQuizzes = list
          .map((item) => QuizModel.fromJson(item as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return _cachedQuizzes!;
    } catch (e) {
      return [];
    }
  }
}
