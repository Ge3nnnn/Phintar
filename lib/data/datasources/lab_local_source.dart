import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:blabla/data/models/lab_model.dart';

/// Local datasource for lab simulation content.
/// Loads simulation definitions from JSON seed asset.
class LabLocalSource {
  List<LabModel>? _cachedLabs;

  /// Returns all labs sorted by [sort_order].
  Future<List<LabModel>> getAllLabs() async {
    if (_cachedLabs != null) return _cachedLabs!;
    try {
      final jsonString =
          await rootBundle.loadString('assets/seed/lab_seed.json');
      final List<dynamic> list = json.decode(jsonString);
      _cachedLabs = list
          .map((item) => LabModel.fromJson(item as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return _cachedLabs!;
    } catch (e) {
      return [];
    }
  }

  /// Returns a single lab by its ID, or null if not found.
  Future<LabModel?> getLabById(int id) async {
    final labs = await getAllLabs();
    try {
      return labs.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Returns labs filtered by [simType].
  Future<List<LabModel>> getLabsBySimType(String simType) async {
    final labs = await getAllLabs();
    return labs.where((l) => l.simType == simType).toList();
  }
}
