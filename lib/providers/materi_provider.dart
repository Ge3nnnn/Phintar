import 'package:flutter/material.dart';
import 'package:phintar/models/materi_model.dart';
import 'package:phintar/services/materi_service.dart';

/// Provider untuk manajemen state konten materi pembelajaran
/// yang terintegrasi langsung dengan Firebase Cloud Firestore via [MateriService].
class MateriProvider extends ChangeNotifier {
  final MateriService _service = MateriService.instance;

  List<MateriModel> _materiList = [];
  bool _isLoading = false;
  String? _error;

  List<MateriModel> get materiList => _materiList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Memuat seluruh materi dari Cloud Firestore.
  Future<void> loadMateri() async {
    _isLoading = true;
    notifyListeners();
    try {
      _materiList = await _service.getAllMateri();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Mencari materi spesifik berdasarkan ID.
  MateriModel? getMateriById(int id) {
    try {
      return _materiList.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Memfilter materi berdasarkan nama kategori.
  List<MateriModel> filterByCategory(String category) {
    return _materiList.where((m) => m.category == category).toList();
  }

  /// Mengambil daftar kategori unik dari materi yang telah dimuat.
  List<String> get categories {
    return _materiList.map((m) => m.category).toSet().toList();
  }
}
