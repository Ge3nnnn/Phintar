import '../models/materi_model.dart';
import '../datasources/materi_local_source.dart';

/// Repository for materi content.
/// Thin wrapper over [MateriLocalSource] for architecture consistency
/// and to allow easy swapping to API source in the future.
class MateriRepository {
  final MateriLocalSource _localSource = MateriLocalSource();

  Future<List<MateriModel>> getAllMateri() async {
    return await _localSource.getAllMateri();
  }

  Future<MateriModel?> getMateriById(int id) async {
    return await _localSource.getMateriById(id);
  }

  Future<List<MateriModel>> getMateriByCategory(String category) async {
    return await _localSource.getMateriByCategory(category);
  }
}
