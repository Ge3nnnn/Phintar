import 'package:phintar/data/datasources/quiz_local_source.dart';
import 'package:phintar/models/quiz_model.dart';

/// Repository for quiz content.
class QuizRepository {
  final QuizLocalSource _localSource = QuizLocalSource();

  Future<List<QuizModel>> getAllQuizzes() async {
    return await _localSource.getAllQuizzes();
  }

  Future<QuizModel?> getQuizWithQuestions(int quizId) async {
    return await _localSource.getQuizWithQuestions(quizId);
  }

  Future<List<QuizModel>> getAllQuizzesWithQuestions() async {
    return await _localSource.getAllQuizzesWithQuestions();
  }
}
