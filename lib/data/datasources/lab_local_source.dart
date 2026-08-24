import 'package:blabla/data/models/lab_model.dart';
import 'package:blabla/database/db_helper.dart';

/// Local datasource for lab simulation content.
class LabLocalSource {
  final DBHelper _dbHelper = DBHelper();

  /// Returns all labs sorted by [sort_order].
  Future<List<LabModel>> getAllLabs() async {
    final db = await _dbHelper.database;
    final rows = await db.query('labs', orderBy: 'sort_order ASC');
    return rows.map((r) => LabModel.fromMap(r)).toList();
  }

  /// Returns a single lab by its ID, or null if not found.
  Future<LabModel?> getLabById(int id) async {
    final db = await _dbHelper.database;
    final rows = await db.query('labs', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return LabModel.fromMap(rows.first);
  }

  /// Returns labs filtered by [simType].
  Future<List<LabModel>> getLabsBySimType(String simType) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'labs',
      where: 'sim_type = ?',
      whereArgs: [simType],
      orderBy: 'sort_order ASC',
    );
    return rows.map((r) => LabModel.fromMap(r)).toList();
  }
}
