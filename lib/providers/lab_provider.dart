import 'package:flutter/material.dart';
import '../data/repositories/lab_repository.dart';
import '../data/models/lab_model.dart';

/// Provider for lab simulation content state management.
///
/// Loads all labs from SQLite and provides lookup methods.
class LabProvider extends ChangeNotifier {
  final LabRepository _repository = LabRepository();

  List<LabModel> _labList = [];
  bool _isLoading = false;
  String? _error;

  List<LabModel> get labList => _labList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Loads all labs from database. Called once on app startup.
  Future<void> loadLabs() async {
    _isLoading = true;
    notifyListeners();
    try {
      _labList = await _repository.getAllLabs();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Finds a specific lab by ID.
  LabModel? getLabById(int id) {
    try {
      return _labList.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Filters labs by simulation type.
  List<LabModel> filterBySimType(String simType) {
    return _labList.where((l) => l.simType == simType).toList();
  }
}
