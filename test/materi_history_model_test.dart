import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phintar/models/materi_model.dart';
import 'package:phintar/models/materi_history_model.dart';
import 'package:phintar/widgets/content_block_renderer.dart';
import 'package:phintar/widgets/history_card/riwayat_materi.dart';

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
    test('MateriModel fromFirestore & toFirestore round-trip test', () {
      final fakeDoc = FakeDocumentSnapshot('1', {
        'id': 1,
        'title': 'Bandul Matematis',
        'category': 'Gelombang dan Osilasi',
        'description': 'Simulasi osilasi pendulum',
        'banner_url': 'banner.png',
        'lottie_url': 'anim.json',
        'sort_order': 1,
        'content_blocks': [
          {'type': 'subtitle', 'content': '1.1 Bandul'},
          {'type': 'formula', 'content': 'T = 2pi sqrt(L/g)'},
        ],
      });

      final model = MateriModel.fromFirestore(fakeDoc);
      expect(model.id, 1);
      expect(model.title, 'Bandul Matematis');
      expect(model.category, 'Gelombang dan Osilasi');
      expect(model.blocks.length, 2);
      expect(model.blocks.first.type, 'subtitle');

      final firestoreMap = model.toFirestore();
      expect(firestoreMap['id'], 1);
      expect(firestoreMap['title'], 'Bandul Matematis');
      expect(firestoreMap['sort_order'], 1);
      expect(firestoreMap['content_blocks'], isA<List>());
      expect((firestoreMap['content_blocks'] as List).length, 2);
    });

    test('ContentBlockRenderer.formatFormula cleanly sanitizes LaTeX and formats math', () {
      const raw = r'v_t = v_0 + a \cdot t\ns = v_0 \cdot t + \frac{1}{2} a \cdot t^2';
      final formatted = ContentBlockRenderer.formatFormula(raw);
      expect(formatted.contains(r'\cdot'), false);
      expect(formatted.contains(r'\frac'), false);
      expect(formatted.contains('·'), true);
      expect(formatted.contains('½'), true);
      expect(formatted.contains('vₜ'), true);
      expect(formatted.contains('v₀'), true);
      expect(formatted.contains('t²'), true);
    });

    test('MateriModel parses grade field and infers grade 10, 11, and 12', () {
      final mapKelas12 = {
        'id': 301,
        'title': 'Rangkaian Arus Searah',
        'category': 'Listrik Dinamis',
        'grade': 12,
        'content_blocks': [
          {'type': 'subtitle', 'content': '1.1 Hukum Ohm'},
        ],
      };

      final model12 = MateriModel.fromMap(mapKelas12);
      expect(model12.id, 301);
      expect(model12.grade, 12);
      expect(model12.toFirestore()['grade'], 12);

      // Inferred grade when grade key is omitted
      final mapInferred12 = {
        'id': 302,
        'title': 'Listrik Statis',
        'category': 'Listrik Statis',
      };
      final modelInferred12 = MateriModel.fromMap(mapInferred12);
      expect(modelInferred12.grade, 12);

      final mapKelas11 = {
        'id': 201,
        'title': 'Dinamika Rotasi',
        'category': 'Dinamika Rotasi',
        'grade': 11,
        'content_blocks': [
          {'type': 'subtitle', 'content': '1.1 Torsi'},
        ],
      };

      final model11 = MateriModel.fromMap(mapKelas11);
      expect(model11.id, 201);
      expect(model11.grade, 11);
      expect(model11.toFirestore()['grade'], 11);

      final mapInferred11 = {
        'id': 203,
        'title': 'Fluida Statis',
        'category': 'Fluida Statis',
      };
      final modelInferred11 = MateriModel.fromMap(mapInferred11);
      expect(modelInferred11.grade, 11);

      final mapKelas10 = {
        'id': 101,
        'title': 'Pengukuran',
        'category': 'Pengukuran',
      };
      final model10 = MateriModel.fromMap(mapKelas10);
      expect(model10.grade, 10);
    });

    test('getMateriTitle returns recorded name or falls back to known title', () {
      expect(
        getMateriTitle(101, 'Besaran, Satuan, dan Pengukuran'),
        'Besaran, Satuan, dan Pengukuran',
      );
      expect(
        getMateriTitle(1, null),
        'Gelombang dan Osilasi',
      );
      expect(
        getMateriTitle(999, ''),
        'Materi Fisika #999',
      );
    });

    test('formatDuration formats seconds into proper text representation', () {
      expect(formatDuration(45), '45 detik');
      expect(formatDuration(120), '2 menit');
      expect(formatDuration(125), '2 menit 5 detik');
      expect(formatDuration(3600), '1 jam');
      expect(formatDuration(3665), '1 jam 1 menit');
    });

    test('Sorting by longest duration orders materials descending', () {
      final items = [
        {'materi_id': 1, 'duration_seconds': 120, 'created_at': '2026-09-01T10:00:00Z'},
        {'materi_id': 2, 'duration_seconds': 500, 'created_at': '2026-09-02T10:00:00Z'},
        {'materi_id': 3, 'duration_seconds': 30, 'created_at': '2026-09-03T10:00:00Z'},
        {'materi_id': 4, 'duration_seconds': 900, 'created_at': '2026-09-04T10:00:00Z'},
      ];

      items.sort((a, b) {
        final durA = (a['duration_seconds'] as num?)?.toInt() ?? 0;
        final durB = (b['duration_seconds'] as num?)?.toInt() ?? 0;
        if (durB != durA) {
          return durB.compareTo(durA);
        }
        final dateA = a['created_at']?.toString() ?? '';
        final dateB = b['created_at']?.toString() ?? '';
        return dateB.compareTo(dateA);
      });

      final top3 = items.take(3).toList();
      expect(top3.length, 3);
      expect(top3[0]['materi_id'], 4); // 900s
      expect(top3[1]['materi_id'], 2); // 500s
      expect(top3[2]['materi_id'], 1); // 120s
    });
  });
}

// ignore: subtype_of_sealed_class
class FakeDocumentSnapshot implements DocumentSnapshot<Map<String, dynamic>> {
  @override
  final String id;
  final Map<String, dynamic>? _data;

  FakeDocumentSnapshot(this.id, this._data);

  @override
  Map<String, dynamic>? data() => _data;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
