import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:phintar/models/preference_handler.dart';
import 'package:phintar/models/quiz_history_model.dart';

/// Layanan untuk mengelola riwayat pengerjaan kuis pada Cloud Firestore (koleksi `quiz_histories`).
class FirestoreQuizService {
  static final FirestoreQuizService _instance = FirestoreQuizService._init();
  factory FirestoreQuizService() => _instance;
  static FirestoreQuizService get instance => _instance;

  FirestoreQuizService._init();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('quiz_histories');

  String _resolveEmail(String? userEmail) {
    if (userEmail != null && userEmail.isNotEmpty) {
      return userEmail;
    }
    final authEmail = FirebaseAuth.instance.currentUser?.email;
    if (authEmail != null && authEmail.isNotEmpty) {
      return authEmail;
    }
    return PreferenceHandler.userEmail;
  }

  /// Menyimpan atau memperbarui hasil kuis pengguna (upsert per kuis & per email).
  Future<void> insertHistoryModel(QuizHistoryModel history) async {
    final email = _resolveEmail(history.userEmail);
    final quizId = history.quizId;
    final score = history.score;
    final now = history.createdAt.isNotEmpty
        ? history.createdAt
        : DateTime.now().toIso8601String();

    final query = await _collection
        .where('user_email', isEqualTo: email)
        .where('quiz_id', isEqualTo: quizId)
        .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update({
        'score': score,
        'created_at': now,
      });
    } else {
      await _collection.add({
        'user_email': email,
        'quiz_id': quizId,
        'score': score,
        'created_at': now,
      });
    }
  }

  /// Menyimpan atau memperbarui hasil kuis menggunakan Map row.
  Future<int> insertHistory(Map<String, dynamic> row) async {
    final model = QuizHistoryModel.fromMap(row);
    await insertHistoryModel(model);
    return 1;
  }

  /// Mengambil semua histori untuk user tertentu (diurutkan dari yang terbaru).
  /// Menggunakan in-memory sorting agar tidak memerlukan konfigurasi composite index di Firestore.
  Future<List<Map<String, dynamic>>> getAllHistories({
    String? userEmail,
  }) async {
    final email = _resolveEmail(userEmail);
    final query = await _collection.where('user_email', isEqualTo: email).get();

    final list = query.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] = doc.id;
      return data;
    }).toList();

    list.sort((a, b) {
      final dateA = a['created_at']?.toString() ?? '';
      final dateB = b['created_at']?.toString() ?? '';
      return dateB.compareTo(dateA);
    });

    return list;
  }

  /// Mengambil semua histori user dalam bentuk Model [QuizHistoryModel].
  Future<List<QuizHistoryModel>> getAllHistoryModels({
    String? userEmail,
  }) async {
    final list = await getAllHistories(userEmail: userEmail);
    return list
        .map(
          (map) => QuizHistoryModel.fromMap(map, docId: map['id']?.toString()),
        )
        .toList();
  }

  /// Mengambil histori untuk kuis tertentu dari user tertentu.
  Future<List<Map<String, dynamic>>> getHistoriesByQuiz(
    int quizId, {
    String? userEmail,
  }) async {
    final email = _resolveEmail(userEmail);
    final query = await _collection
        .where('user_email', isEqualTo: email)
        .where('quiz_id', isEqualTo: quizId)
        .get();

    final list = query.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] = doc.id;
      return data;
    }).toList();

    list.sort((a, b) {
      final dateA = a['created_at']?.toString() ?? '';
      final dateB = b['created_at']?.toString() ?? '';
      return dateB.compareTo(dateA);
    });

    return list;
  }

  /// Memperbarui skor jika kuis diulang.
  Future<int> updateHistory(Map<String, dynamic> row) async {
    final id = row['id']?.toString();
    if (id != null && id.isNotEmpty) {
      await _collection.doc(id).update(row);
      return 1;
    }
    return 0;
  }

  /// Memperbarui histori menggunakan Model.
  Future<int> updateHistoryModel(QuizHistoryModel history) async {
    if (history.id == null || history.id!.isEmpty) return 0;
    return await updateHistory(history.toMap());
  }

  /// Menghapus dokumen histori berdasarkan Document ID Firestore.
  Future<int> deleteHistory(dynamic id) async {
    final docId = id?.toString() ?? '';
    if (docId.isEmpty) return 0;
    await _collection.doc(docId).delete();
    return 1;
  }

  Future<void> close() async {}
}
