import 'dart:async';
import 'package:blabla/data/models/quiz_history_model.dart';
import 'package:blabla/models/preference_handler.dart';
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

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  // CREATE TABLE - Versi Sederhana
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableQuizHistories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_email TEXT NOT NULL,
        quiz_id INTEGER NOT NULL,
        score REAL NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE $tableQuizHistories ADD COLUMN user_email TEXT NOT NULL DEFAULT ''",
      );
    }
  }

  String _resolveEmail(String? userEmail) {
    if (userEmail != null && userEmail.isNotEmpty) {
      return userEmail;
    }
    return PreferenceHandler.userEmail;
  }

  // OPERASI CRUD
  // 1. CREATE or UPDATE: Menyimpan skor dan waktu kuis per user
  Future<int> insertHistory(Map<String, dynamic> row) async {
    final db = await instance.database;
    final email = _resolveEmail(row['user_email'] as String?);

    int quizId = (row['quiz_id'] as num).toInt();
    final existing = await getHistoriesByQuiz(quizId, userEmail: email);

    if (existing.isNotEmpty) {
      final updatedModel = QuizHistoryModel(
        id: (existing.first['id'] as num?)?.toInt(),
        userEmail: email,
        quizId: quizId,
        score: (row['score'] as num).toDouble(),
        createdAt: DateTime.now().toIso8601String(),
      );
      return await updateHistory(updatedModel.toMap());
    }

    final newModel = QuizHistoryModel(
      userEmail: email,
      quizId: quizId,
      score: (row['score'] as num).toDouble(),
      createdAt: DateTime.now().toIso8601String(),
    );

    return await db.insert(tableQuizHistories, newModel.toMap());
  }

  // CREATE or UPDATE menggunakan Model langsung
  Future<int> insertHistoryModel(QuizHistoryModel history) async {
    final email = _resolveEmail(history.userEmail);
    final historyWithEmail = QuizHistoryModel(
      id: history.id,
      userEmail: email,
      quizId: history.quizId,
      score: history.score,
      createdAt: history.createdAt,
    );
    return await insertHistory(historyWithEmail.toMap());
  }

  // 2. READ: Mengambil semua histori untuk user tertentu (diurutkan dari yang terbaru)
  Future<List<Map<String, dynamic>>> getAllHistories({String? userEmail}) async {
    final email = _resolveEmail(userEmail);
    final db = await instance.database;
    return await db.query(
      tableQuizHistories,
      where: 'user_email = ?',
      whereArgs: [email],
      orderBy: 'created_at DESC',
    );
  }

  // READ: Mengambil semua histori user dalam bentuk Model
  Future<List<QuizHistoryModel>> getAllHistoryModels({
    String? userEmail,
  }) async {
    final list = await getAllHistories(userEmail: userEmail);
    return list.map((map) => QuizHistoryModel.fromMap(map)).toList();
  }

  // READ: Mengambil histori untuk kuis tertentu dari user tertentu
  Future<List<Map<String, dynamic>>> getHistoriesByQuiz(
    int quizId, {
    String? userEmail,
  }) async {
    final email = _resolveEmail(userEmail);
    final db = await instance.database;
    return await db.query(
      tableQuizHistories,
      where: 'quiz_id = ? AND user_email = ?',
      whereArgs: [quizId, email],
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

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
