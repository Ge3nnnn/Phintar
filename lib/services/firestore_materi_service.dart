import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:phintar/models/materi_history_model.dart';

/// Layanan untuk mengelola riwayat durasi belajar materi pada Cloud Firestore (koleksi `materi_histories`).
class FirestoreMateriService {
  static final FirestoreMateriService _instance =
      FirestoreMateriService._init();
  factory FirestoreMateriService() => _instance;
  static FirestoreMateriService get instance => _instance;

  FirestoreMateriService._init();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('materi_histories');

  String _resolveEmail(String? userEmail) {
    if (userEmail != null && userEmail.isNotEmpty) {
      return userEmail;
    }
    final authEmail = FirebaseAuth.instance.currentUser?.email;
    if (authEmail != null && authEmail.isNotEmpty) {
      return authEmail;
    }
    return '';
  }

  /// Menyimpan riwayat belajar materi pengguna (akumulasi durasi waktu belajar).
  Future<int> insertHistory({
    String? userEmail,
    required int materiId,
    required String materiName,
    required int durationSeconds,
  }) async {
    final email = _resolveEmail(userEmail);
    final now = DateTime.now().toIso8601String();

    final query = await _collection
        .where('user_email', isEqualTo: email)
        .where('materi_id', isEqualTo: materiId)
        .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      final existingSeconds =
          (doc.data()['duration_seconds'] as num?)?.toInt() ?? 0;
      await doc.reference.update({
        'materi_name': materiName,
        'duration_seconds': existingSeconds + durationSeconds,
        'created_at': now,
      });
    } else {
      await _collection.add({
        'user_email': email,
        'materi_id': materiId,
        'materi_name': materiName,
        'duration_seconds': durationSeconds,
        'created_at': now,
      });
    }
    return 1;
  }

  /// Menyimpan riwayat belajar materi menggunakan [MateriHistoryModel].
  Future<int> insertHistoryModel(MateriHistoryModel history) async {
    return await insertHistory(
      userEmail: history.userEmail,
      materiId: history.materiId,
      materiName: history.materiName,
      durationSeconds: history.durationSeconds,
    );
  }

  /// Mengambil semua riwayat materi untuk user tertentu (diurutkan dari yang terbaru).
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

  /// Mengambil semua histori materi user dalam bentuk Model [MateriHistoryModel].
  Future<List<MateriHistoryModel>> getAllHistoryModels({
    String? userEmail,
  }) async {
    final list = await getAllHistories(userEmail: userEmail);
    return list
        .map(
          (map) =>
              MateriHistoryModel.fromMap(map, docId: map['id']?.toString()),
        )
        .toList();
  }

  /// Mengambil histori materi tertentu dari user tertentu.
  Future<List<Map<String, dynamic>>> getHistoriesByMateri(
    int materiId, {
    String? userEmail,
  }) async {
    final email = _resolveEmail(userEmail);
    final query = await _collection
        .where('user_email', isEqualTo: email)
        .where('materi_id', isEqualTo: materiId)
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

  /// Memperbarui riwayat materi.
  Future<int> updateHistory(Map<String, dynamic> row) async {
    final id = row['id']?.toString();
    if (id != null && id.isNotEmpty) {
      await _collection.doc(id).update(row);
      return 1;
    }
    return 0;
  }

  /// Memperbarui riwayat menggunakan Model.
  Future<int> updateHistoryModel(MateriHistoryModel history) async {
    if (history.id == null || history.id!.isEmpty) return 0;
    return await updateHistory(history.toMap());
  }

  /// Menghapus histori tertentu berdasarkan Document ID Firestore.
  Future<int> deleteHistory(dynamic id) async {
    final docId = id?.toString() ?? '';
    if (docId.isEmpty) return 0;
    await _collection.doc(docId).delete();
    return 1;
  }

  Future<void> close() async {}
}
