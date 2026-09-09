import 'package:flutter_test/flutter_test.dart';
import 'package:phintar/models/materi_model.dart';
import 'package:phintar/models/materi_history_model.dart';

void main() {
  group('MateriModel & MateriHistoryModel Tests', () {
    test('MateriModel parses from Map with List of blocks', () {
      final map = {
        'id': 1,
        'title': 'Gelombang dan Osilasi',
        'category': 'Gelombang',
        'content_blocks': [
          {'type': 'subtitle', 'content': '1.1 Pengantar'},
          {'type': 'text', 'content': 'Penjelasan osilasi'},
        ],
      };

      final model = MateriModel.fromMap(map);
      expect(model.id, 1);
      expect(model.title, 'Gelombang dan Osilasi');
      expect(model.blocks.length, 2);
      expect(model.blocks.first.type, 'subtitle');
      expect(model.blocks.first.content, '1.1 Pengantar');
    });

    test('MateriModel parses from Map with JSON-encoded string blocks', () {
      final map = {
        'id': 2,
        'title': 'Visualisasi Gelombang Harmonik',
        'category': 'Gelombang',
        'content_blocks': '[{"type":"youtube","content":"abc123xyz"}]',
      };

      final model = MateriModel.fromMap(map);
      expect(model.id, 2);
      expect(model.blocks.length, 1);
      expect(model.blocks.first.type, 'youtube');
      expect(model.blocks.first.content, 'abc123xyz');
    });

    test('MateriHistoryModel serializes and parses properly', () {
      final history = MateriHistoryModel(
        id: 'doc_12345',
        userEmail: 'student@example.com',
        materiId: 1,
        materiName: 'Gelombang Osilasi',
        durationSeconds: 450,
        createdAt: '2026-09-09T09:00:00.000Z',
      );

      final map = history.toFirestore();
      expect(map['user_email'], 'student@example.com');
      expect(map['materi_id'], 1);
      expect(map['duration_seconds'], 450);

      final reconstructed = MateriHistoryModel.fromMap(map, docId: 'doc_12345');
      expect(reconstructed.id, 'doc_12345');
      expect(reconstructed.userEmail, 'student@example.com');
      expect(reconstructed.materiId, 1);
      expect(reconstructed.materiName, 'Gelombang Osilasi');
      expect(reconstructed.durationSeconds, 450);
      expect(reconstructed.createdAt, '2026-09-09T09:00:00.000Z');
    });

    test('MateriHistoryModel handles DateTime input gracefully in fromMap', () {
      final now = DateTime(2026, 9, 9, 10, 30);
      final map = {
        'user_email': 'test@example.com',
        'materi_id': 1,
        'materi_name': 'Gelombang Osilasi',
        'duration_seconds': 120,
        'created_at': now,
      };

      final model = MateriHistoryModel.fromMap(map, docId: 'doc_test');
      expect(model.id, 'doc_test');
      expect(model.createdAt, now.toIso8601String());
    });
  });
}
