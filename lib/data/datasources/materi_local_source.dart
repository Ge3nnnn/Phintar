import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:blabla/data/models/materi_model.dart';

/// Local datasource for materi content.
/// Reads from JSON seed asset.
class MateriLocalSource {
  List<MateriModel>? _cachedMateri;

  /// Returns all materi sorted by [sort_order].
  Future<List<MateriModel>> getAllMateri() async {
    if (_cachedMateri != null) return _cachedMateri!;
    try {
      final jsonString =
          await rootBundle.loadString('assets/seed/materi_seed.json');
      final List<dynamic> list = json.decode(jsonString);
      _cachedMateri = list
          .map((item) => MateriModel.fromJson(item as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return _cachedMateri!;
    } catch (e) {
      return [];
    }
  }

  /// Returns a single materi by its ID, or null if not found.
  Future<MateriModel?> getMateriById(int id) async {
    final list = await getAllMateri();
    try {
      return list.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Returns materi filtered by [category].
  Future<List<MateriModel>> getMateriByCategory(String category) async {
    final list = await getAllMateri();
    return list.where((m) => m.category == category).toList();
  }
}
