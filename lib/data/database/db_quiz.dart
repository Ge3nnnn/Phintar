import 'dart:async';
import 'package:blabla/data/models/quiz_history_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelperQuiz {
  static final DatabaseHelperQuiz instance = DatabaseHelperQuiz._init();
  static Database? _database;

  DatabaseHelperQuiz._init();

  static const String tableQuizHistories = 'quiz_histories';
  static const String dbName = 'phintar_quiz_simple.db';

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

  // CREATE TABLE - Versi Sederhana
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableQuizHistories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quiz_id INTEGER NOT NULL,
        score REAL NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // OPERASI CRUD
  // 1. CREATE or UPDATE: Menyimpan skor dan waktu kuis
  Future<int> insertHistory(Map<String, dynamic> row) async {
    final db = await instance.database;

    int quizId = (row['quiz_id'] as num).toInt();
    final existing = await getHistoriesByQuiz(quizId);

    if (existing.isNotEmpty) {
      final updatedModel = QuizHistoryModel(
        id: (existing.first['id'] as num?)?.toInt(),
        quizId: quizId,
        score: (row['score'] as num).toDouble(),
        createdAt: DateTime.now().toIso8601String(),
      );
      return await updateHistory(updatedModel.toMap());
    }

    final newModel = QuizHistoryModel(
      quizId: quizId,
      score: (row['score'] as num).toDouble(),
      createdAt: DateTime.now().toIso8601String(),
    );

    return await db.insert(tableQuizHistories, newModel.toMap());
  }

  // CREATE or UPDATE menggunakan Model langsung
  Future<int> insertHistoryModel(QuizHistoryModel history) async {
    return await insertHistory(history.toMap());
  }

  // 2. READ: Mengambil semua histori (diurutkan dari yang terbaru)
  Future<List<Map<String, dynamic>>> getAllHistories() async {
    final db = await instance.database;
    return await db.query(tableQuizHistories, orderBy: 'created_at DESC');
  }

  // READ: Mengambil semua histori dalam bentuk Model
  Future<List<QuizHistoryModel>> getAllHistoryModels() async {
    final list = await getAllHistories();
    return list.map((map) => QuizHistoryModel.fromMap(map)).toList();
  }

  // READ: Mengambil histori untuk kuis tertentu saja
  Future<List<Map<String, dynamic>>> getHistoriesByQuiz(int quizId) async {
    final db = await instance.database;
    return await db.query(
      tableQuizHistories,
      where: 'quiz_id = ?',
      whereArgs: [quizId],
      orderBy: 'created_at DESC',
    );
  }

  // 3. UPDATE: Memperbarui skor jika kuis diulang (berdasarkan ID histori)
  Future<int> updateHistory(Map<String, dynamic> row) async {
    final db = await instance.database;
    int id = row['id'];
    return await db.update(
      tableQuizHistories,
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // UPDATE menggunakan Model
  Future<int> updateHistoryModel(QuizHistoryModel history) async {
    if (history.id == null) return 0;
    return await updateHistory(history.toMap());
  }

  // 4. DELETE: Menghapus histori
  Future<int> deleteHistory(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableQuizHistories,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Ringkasan statistik (jumlah kuis & rata-rata nilai)
  // Future<Map<String, dynamic>> getSummaryStats() async {
  //   final db = await instance.database;
  //   final result = await db.rawQuery('''
  //     SELECT
  //       COUNT(*) as total,
  //       AVG(score) as average_score,
  //       MAX(score) as max_score
  //     FROM $tableQuizHistories
  //   ''');
  //   if (result.isNotEmpty) {
  //     final total = (result.first['total'] as num?)?.toInt() ?? 0;
  //     final avg = (result.first['average_score'] as num?)?.toDouble() ?? 0.0;
  //     final max = (result.first['max_score'] as num?)?.toDouble() ?? 0.0;
  //     return {
  //       'total': total,
  //       'averageScore': avg,
  //       'maxScore': max,
  //     };
  //   }
  //   return {'total': 0, 'averageScore': 0.0, 'maxScore': 0.0};
  // }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
