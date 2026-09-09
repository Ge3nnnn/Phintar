import '../quiz_model.dart';
import '../quiz_history_model.dart';
import '../datasources/quiz_local_source.dart';
import 'package:phintar/services/firestore_quiz_service.dart';

/// Repository for quiz content and quiz attempt history.
///
/// Combines [QuizLocalSource] for quiz questions/metadata and
/// [FirestoreQuizService] for persisting and querying user quiz results
/// in Firebase Cloud Firestore.
class QuizRepository {
  final QuizLocalSource _localSource = QuizLocalSource();
  final FirestoreQuizService _firestoreService = FirestoreQuizService.instance;

  // ─── Quiz Content (Local / Cache) ───

  Future<List<QuizModel>> getAllQuizzes() async {
    return await _localSource.getAllQuizzes();
  }

  Future<QuizModel?> getQuizWithQuestions(int quizId) async {
    return await _localSource.getQuizWithQuestions(quizId);
  }

  Future<List<QuizModel>> getAllQuizzesWithQuestions() async {
    return await _localSource.getAllQuizzesWithQuestions();
  }

  // ─── Quiz History (Firebase Cloud Firestore) ───

  /// Fetches all quiz histories for the user as strongly typed [QuizHistoryModel]s.
  Future<List<QuizHistoryModel>> getAllHistories({String? userEmail}) async {
    return await _firestoreService.getAllHistoryModels(userEmail: userEmail);
  }

  /// Fetches all quiz histories as raw maps (for backwards compatibility).
  Future<List<Map<String, dynamic>>> getAllHistoryMaps({
    String? userEmail,
  }) async {
    return await _firestoreService.getAllHistories(userEmail: userEmail);
  }

  /// Saves or updates quiz score in Firestore using [QuizHistoryModel].
  Future<void> saveHistoryModel(QuizHistoryModel history) async {
    await _firestoreService.insertHistoryModel(history);
  }

  /// Saves quiz result via parameters.
  Future<void> saveHistory({
    String? userEmail,
    required int quizId,
    required double score,
  }) async {
    await _firestoreService.insertHistoryModel(
      QuizHistoryModel(
        userEmail: userEmail ?? '',
        quizId: quizId,
        score: score,
        createdAt: DateTime.now().toIso8601String(),
      ),
    );
  }

  /// Deletes a quiz history entry by Firestore Document ID.
  Future<int> deleteHistory(String id) async {
    return await _firestoreService.deleteHistory(id);
  }
}
