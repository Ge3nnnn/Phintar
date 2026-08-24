import 'package:flutter/material.dart';
import '../data/repositories/quiz_repository.dart';
import '../data/models/quiz_model.dart';

/// Provider for quiz content state management.
///
/// Loads all quizzes (with questions) from SQLite.
class QuizProvider extends ChangeNotifier {
  final QuizRepository _repository = QuizRepository();

  List<QuizModel> _quizList = [];
  bool _isLoading = false;
  String? _error;

  List<QuizModel> get quizList => _quizList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Loads all quizzes with their questions. Called once on app startup.
  Future<void> loadQuizzes() async {
    _isLoading = true;
    notifyListeners();
    try {
      _quizList = await _repository.getAllQuizzesWithQuestions();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Finds a specific quiz by ID.
  QuizModel? getQuizById(int id) {
    try {
      return _quizList.firstWhere((q) => q.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Filters quizzes by category.
  List<QuizModel> filterByCategory(String category) {
    return _quizList.where((q) => q.category == category).toList();
  }
}
