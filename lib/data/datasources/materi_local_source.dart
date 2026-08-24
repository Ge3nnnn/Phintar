import 'package:blabla/data/models/materi_model.dart';
import 'package:blabla/database/db_helper.dart';

/// Local datasource for materi content.
/// Reads from the unified SQLite database instead of JSON assets.
class MateriLocalSource {
  final DBHelper _dbHelper = DBHelper();

  /// Returns all materi sorted by [sort_order].
  Future<List<MateriModel>> getAllMateri() async {
    final db = await _dbHelper.database;
    final rows = await db.query('materi', orderBy: 'sort_order ASC');
    return rows.map((r) => MateriModel.fromMap(r)).toList();
  }

  /// Returns a single materi by its ID, or null if not found.
  Future<MateriModel?> getMateriById(int id) async {
    final db = await _dbHelper.database;
    final rows = await db.query('materi', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return MateriModel.fromMap(rows.first);
  }

  /// Returns materi filtered by [category].
  Future<List<MateriModel>> getMateriByCategory(String category) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'materi',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'sort_order ASC',
    );
    return rows.map((r) => MateriModel.fromMap(r)).toList();
  }
}
