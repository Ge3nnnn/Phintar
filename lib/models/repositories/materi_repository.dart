import '../materi_model.dart';
import '../materi_history_model.dart';
import '../datasources/materi_local_source.dart';
import 'package:phintar/services/firestore_materi_service.dart';

/// Repository for materi content and learning history.
///
/// Combines [MateriLocalSource] for materi curriculum modules and
/// [FirestoreMateriService] for persisting and querying user learning history
/// in Firebase Cloud Firestore.
class MateriRepository {
  final MateriLocalSource _localSource = MateriLocalSource();
  final FirestoreMateriService _firestoreService =
      FirestoreMateriService.instance;

  // ─── Materi Modules (Local / Cache) ───

  Future<List<MateriModel>> getAllMateri() async {
    return await _localSource.getAllMateri();
  }

  Future<MateriModel?> getMateriById(int id) async {
    return await _localSource.getMateriById(id);
  }

  Future<List<MateriModel>> getMateriByCategory(String category) async {
    return await _localSource.getMateriByCategory(category);
  }

  // ─── Materi Learning History (Firebase Cloud Firestore) ───

  /// Fetches all learning history records for the user as strongly typed [MateriHistoryModel]s.
  Future<List<MateriHistoryModel>> getAllHistories({String? userEmail}) async {
    return await _firestoreService.getAllHistoryModels(userEmail: userEmail);
  }

  /// Fetches all learning history records as raw maps (for backwards compatibility).
  Future<List<Map<String, dynamic>>> getAllHistoryMaps({
    String? userEmail,
  }) async {
    return await _firestoreService.getAllHistories(userEmail: userEmail);
  }

  /// Saves or accumulates learning duration for a given materi in Firestore.
  Future<int> saveHistory({
    String? userEmail,
    required int materiId,
    required String materiName,
    required int durationSeconds,
  }) async {
    return await _firestoreService.insertHistory(
      userEmail: userEmail,
      materiId: materiId,
      materiName: materiName,
      durationSeconds: durationSeconds,
    );
  }

  /// Saves or accumulates learning history using a [MateriHistoryModel].
  Future<int> saveHistoryModel(MateriHistoryModel history) async {
    return await _firestoreService.insertHistoryModel(history);
  }

  /// Deletes a specific learning history document by Firestore Document ID.
  Future<int> deleteHistory(String id) async {
    return await _firestoreService.deleteHistory(id);
  }
}
