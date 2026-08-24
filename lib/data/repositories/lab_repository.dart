import '../models/lab_model.dart';
import '../datasources/lab_local_source.dart';

/// Repository for lab simulation content.
class LabRepository {
  final LabLocalSource _localSource = LabLocalSource();

  Future<List<LabModel>> getAllLabs() async {
    return await _localSource.getAllLabs();
  }

  Future<LabModel?> getLabById(int id) async {
    return await _localSource.getLabById(id);
  }

  Future<List<LabModel>> getLabsBySimType(String simType) async {
    return await _localSource.getLabsBySimType(simType);
  }
}
