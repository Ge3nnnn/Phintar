import 'package:flutter/material.dart';
import '../data/repositories/materi_repository.dart';
import '../data/models/materi_model.dart';

/// Provider for materi content state management.
///
/// Loads all materi from SQLite and provides filtering/lookup methods.
/// UI listens via `context.watch<MateriProvider>()`.
class MateriProvider extends ChangeNotifier {
  final MateriRepository _repository = MateriRepository();

  List<MateriModel> _materiList = [];
  bool _isLoading = false;
  String? _error;

  List<MateriModel> get materiList => _materiList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Loads all materi from database. Called once on app startup.
  Future<void> loadMateri() async {
    _isLoading = true;
    notifyListeners();
    try {
      _materiList = await _repository.getAllMateri();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Finds a specific materi by ID.
  MateriModel? getMateriById(int id) {
    try {
      return _materiList.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Filters materi by category name.
  List<MateriModel> filterByCategory(String category) {
    return _materiList.where((m) => m.category == category).toList();
  }

  /// Gets distinct categories from loaded materi.
  List<String> get categories {
    return _materiList.map((m) => m.category).toSet().toList();
  }
}
