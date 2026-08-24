import 'package:blabla/data/models/quiz_model.dart';
import 'package:blabla/database/db_helper.dart';

/// Local datasource for quiz content.
class QuizLocalSource {
  final DBHelper _dbHelper = DBHelper();

  /// Returns all quizzes (without questions) sorted by [sort_order].
  Future<List<QuizModel>> getAllQuizzes() async {
    final db = await _dbHelper.database;
    final rows = await db.query('quizzes', orderBy: 'sort_order ASC');
    return rows.map((r) => QuizModel.fromMap(r)).toList();
  }

  /// Returns a quiz with its questions loaded.
  Future<QuizModel?> getQuizWithQuestions(int quizId) async {
    final db = await _dbHelper.database;

    // Load quiz
    final quizRows = await db.query(
      'quizzes',
      where: 'id = ?',
      whereArgs: [quizId],
    );
    if (quizRows.isEmpty) return null;
    final quiz = QuizModel.fromMap(quizRows.first);

    // Load questions
    final questionRows = await db.query(
      'quiz_questions',
      where: 'quiz_id = ?',
      whereArgs: [quizId],
      orderBy: 'sort_order ASC',
    );
    final questions = questionRows
        .map((r) => QuizQuestionModel.fromMap(r))
        .toList();

    return quiz.copyWithQuestions(questions);
  }

  /// Returns all quizzes with their questions loaded.
  Future<List<QuizModel>> getAllQuizzesWithQuestions() async {
    final db = await _dbHelper.database;

    // Load all quizzes
    final quizRows = await db.query('quizzes', orderBy: 'sort_order ASC');
    final quizzes = <QuizModel>[];

    for (final row in quizRows) {
      final quiz = QuizModel.fromMap(row);
      // Load questions for this quiz
      final questionRows = await db.query(
        'quiz_questions',
        where: 'quiz_id = ?',
        whereArgs: [quiz.id],
        orderBy: 'sort_order ASC',
      );
      final questions = questionRows
          .map((r) => QuizQuestionModel.fromMap(r))
          .toList();
      quizzes.add(quiz.copyWithQuestions(questions));
    }

    return quizzes;
  }
}
