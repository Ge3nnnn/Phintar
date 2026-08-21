import 'dart:async';
import 'package:blabla/models/materi_history_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelperMateri {
  // Singleton pattern
  static final DatabaseHelperMateri instance = DatabaseHelperMateri._init();
  static Database? _database;

  DatabaseHelperMateri._init();

  static const String tableMateriHistories = 'materi_histories';
  static const String dbName = 'phintar_materi.db';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // CREATE TABLE
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableMateriHistories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        materi_id INTEGER NOT NULL,
        materi_name TEXT NOT NULL,
        duration_seconds INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // OPERASI CRUD

  // 1. CREATE or UPDATE: Menyimpan riwayat belajar materi (kapan & berapa lama)
  Future<int> insertHistory({
    required int materiId,
    required String materiName,
    required int durationSeconds,
  }) async {
    final db = await instance.database;
    // update data
    final existing = await getHistoriesByMateri(materiId);
    if (existing.isNotEmpty) {
      final existingSeconds =
          (existing.first['duration_seconds'] as num?)?.toInt() ?? 0;
      final historyModel = MateriHistoryModel(
        id: (existing.first['id'] as num?)?.toInt(),
        materiId: materiId,
        materiName: materiName,
        durationSeconds: durationSeconds + existingSeconds,
        createdAt: DateTime.now().toIso8601String(),
      );
      return await updateHistory(historyModel.toMap());
    }

    final historyModel = MateriHistoryModel(
      materiId: materiId,
      materiName: materiName,
      durationSeconds: durationSeconds,
      createdAt: DateTime.now().toIso8601String(),
    );

    return await db.insert(tableMateriHistories, historyModel.toMap());
  }

  // CREATE or UPDATE menggunakan Model langsung
  Future<int> insertHistoryModel(MateriHistoryModel history) async {
    return await insertHistory(
      materiId: history.materiId,
      materiName: history.materiName,
      durationSeconds: history.durationSeconds,
    );
  }

  // 2. READ: Mengambil semua histori (diurutkan dari yang terbaru)
  Future<List<Map<String, dynamic>>> getAllHistories() async {
    final db = await instance.database;
    return await db.query(tableMateriHistories, orderBy: 'created_at DESC');
  }

  // READ: Mengambil semua histori dalam bentuk Model
  Future<List<MateriHistoryModel>> getAllHistoryModels() async {
    final list = await getAllHistories();
    return list.map((map) => MateriHistoryModel.fromMap(map)).toList();
  }

  // READ: Mengambil histori untuk materi tertentu saja
  Future<List<Map<String, dynamic>>> getHistoriesByMateri(int materiId) async {
    final db = await instance.database;
    return await db.query(
      tableMateriHistories,
      where: 'materi_id = ?',
      whereArgs: [materiId],
      orderBy: 'created_at DESC',
    );
  }

  // 3. UPDATE: Memperbarui riwayat materi (berdasarkan ID histori)
  Future<int> updateHistory(Map<String, dynamic> row) async {
    final db = await instance.database;
    int id = row['id'];
    return await db.update(
      tableMateriHistories,
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // UPDATE menggunakan Model
  Future<int> updateHistoryModel(MateriHistoryModel history) async {
    if (history.id == null) return 0;
    return await updateHistory(history.toMap());
  }

  // 4. DELETE: Menghapus histori tertentu
  Future<int> deleteHistory(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableMateriHistories,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Ringkasan statistik (jumlah materi dipelajari & total waktu belajar)
  // Future<Map<String, dynamic>> getSummaryStats() async {
  //   final db = await instance.database;
  //   final result = await db.rawQuery('''
  //     SELECT
  //       COUNT(*) as total,
  //       SUM(duration_seconds) as total_duration,
  //       AVG(duration_seconds) as avg_duration
  //     FROM $tableMateriHistories
  //   ''');
  //   if (result.isNotEmpty) {
  //     final total = (result.first['total'] as num?)?.toInt() ?? 0;
  //     final totalDuration =
  //         (result.first['total_duration'] as num?)?.toInt() ?? 0;
  //     final avgDuration =
  //         (result.first['avg_duration'] as num?)?.toDouble() ?? 0.0;
  //     return {
  //       'total': total,
  //       'totalDuration': totalDuration,
  //       'avgDuration': avgDuration,
  //     };
  //   }
  //   return {'total': 0, 'totalDuration': 0, 'avgDuration': 0.0};
  // }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
