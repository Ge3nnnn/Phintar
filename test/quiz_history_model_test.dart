import 'package:flutter_test/flutter_test.dart';
import 'package:phintar/models/quiz_model.dart';
import 'package:phintar/models/quiz_history_model.dart';

void main() {
  group('QuizModel & QuizHistoryModel Tests', () {
    test('QuizQuestionModel parses from Map with List of options', () {
      final map = {
        'id': 1,
        'quiz_id': 10,
        'question': 'Berapa frekuensi gelombang?',
        'options': ['10 Hz', '20 Hz', '30 Hz', '40 Hz'],
        'correct_index': 1,
        'explanation': 'Frekuensi dihitung dengan f = 1/T',
      };

      final q = QuizQuestionModel.fromMap(map);
      expect(q.id, 1);
      expect(q.quizId, 10);
      expect(q.question, 'Berapa frekuensi gelombang?');
      expect(q.options.length, 4);
      expect(q.correctIndex, 1);
      expect(q.explanation, 'Frekuensi dihitung dengan f = 1/T');
    });

    test(
      'QuizQuestionModel parses from Map with JSON-encoded options string',
      () {
        final map = {
          'id': 2,
          'quiz_id': 10,
          'question': 'Satuan periode adalah?',
          'options': '["Detik", "Meter", "Joule"]',
          'correct_index': 0,
        };

        final q = QuizQuestionModel.fromMap(map);
        expect(q.id, 2);
        expect(q.options.length, 3);
        expect(q.options.first, 'Detik');
        expect(q.correctIndex, 0);
      },
    );

    test(
      'QuizModel parses from Map with inline questions and produces toFirestore',
      () {
        final map = {
          'id': 5,
          'title': 'Kuis Gelombang Dasar',
          'category': 'Gelombang',
          'time_limit_minutes': 15,
          'questions': [
            {
              'id': 1,
              'question': 'Apa itu gelombang?',
              'options': ['Getaran yang merambat', 'Zat cair'],
              'correct_index': 0,
            },
          ],
        };

        final quiz = QuizModel.fromMap(map);
        expect(quiz.id, 5);
        expect(quiz.title, 'Kuis Gelombang Dasar');
        expect(quiz.questions.length, 1);
        expect(quiz.questions.first.quizId, 5);

        final firestoreMap = quiz.toFirestore();
        expect(firestoreMap['id'], 5);
        expect(firestoreMap['time_limit_minutes'], 15);
        expect(firestoreMap['questions'], isNotEmpty);
      },
    );

    test('QuizHistoryModel serializes and parses properly', () {
      final history = QuizHistoryModel(
        id: 'quiz_doc_001',
        userEmail: 'student@example.com',
        quizId: 1,
        score: 85.0,
        createdAt: '2026-09-09T09:30:00.000Z',
      );

      final map = history.toFirestore();
      expect(map['user_email'], 'student@example.com');
      expect(map['quiz_id'], 1);
      expect(map['score'], 85.0);

      final reconstructed = QuizHistoryModel.fromMap(
        map,
        docId: 'quiz_doc_001',
      );
      expect(reconstructed.id, 'quiz_doc_001');
      expect(reconstructed.userEmail, 'student@example.com');
      expect(reconstructed.quizId, 1);
      expect(reconstructed.score, 85.0);
      expect(reconstructed.createdAt, '2026-09-09T09:30:00.000Z');
    });

    test('QuizHistoryModel handles DateTime input gracefully in fromMap', () {
      final now = DateTime(2026, 9, 9, 11, 0);
      final map = {
        'user_email': 'test@example.com',
        'quiz_id': 2,
        'score': 100.0,
        'created_at': now,
      };

      final model = QuizHistoryModel.fromMap(map, docId: 'quiz_doc_002');
      expect(model.id, 'quiz_doc_002');
      expect(model.createdAt, now.toIso8601String());
      expect(model.score, 100.0);
    });
  });
}
