import 'dart:async';
import 'package:blabla/data/models/materi_history_model.dart';
import 'package:blabla/models/preference_handler.dart';
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

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  // CREATE TABLE
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableMateriHistories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_email TEXT NOT NULL,
        materi_id INTEGER NOT NULL,
        materi_name TEXT NOT NULL,
        duration_seconds INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE $tableMateriHistories ADD COLUMN user_email TEXT NOT NULL DEFAULT ''",
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

  // 1. CREATE or UPDATE: Menyimpan riwayat belajar materi per user (kapan & berapa lama)
  Future<int> insertHistory({
    String? userEmail,
    required int materiId,
    required String materiName,
    required int durationSeconds,
  }) async {
    final email = _resolveEmail(userEmail);
    final db = await instance.database;

    // Cek histori materi untuk user tertentu
    final existing = await getHistoriesByMateri(materiId, userEmail: email);
    if (existing.isNotEmpty) {
      final existingSeconds =
          (existing.first['duration_seconds'] as num?)?.toInt() ?? 0;
      final historyModel = MateriHistoryModel(
        id: (existing.first['id'] as num?)?.toInt(),
        userEmail: email,
        materiId: materiId,
        materiName: materiName,
        durationSeconds: durationSeconds + existingSeconds,
        createdAt: DateTime.now().toIso8601String(),
      );
      return await updateHistory(historyModel.toMap());
    }

    final historyModel = MateriHistoryModel(
      userEmail: email,
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
      userEmail: history.userEmail,
      materiId: history.materiId,
      materiName: history.materiName,
      durationSeconds: history.durationSeconds,
    );
  }

  // 2. READ: Mengambil semua histori untuk user tertentu (diurutkan dari yang terbaru)
  Future<List<Map<String, dynamic>>> getAllHistories({
    String? userEmail,
  }) async {
    final email = _resolveEmail(userEmail);
    final db = await instance.database;

    // Konsolidasi: Gabungkan histori lama materi_id = 2 ke materi_id = 1 (Gelombang Osilasi)
    final p2List = await db.query(
      tableMateriHistories,
      where: 'user_email = ? AND materi_id = 2',
      whereArgs: [email],
    );
    if (p2List.isNotEmpty) {
      for (final p2 in p2List) {
        final p2Seconds = (p2['duration_seconds'] as num?)?.toInt() ?? 0;
        final p1List = await db.query(
          tableMateriHistories,
          where: 'user_email = ? AND materi_id = 1',
          whereArgs: [email],
        );
        if (p1List.isNotEmpty) {
          final p1Seconds =
              (p1List.first['duration_seconds'] as num?)?.toInt() ?? 0;
          await db.update(
            tableMateriHistories,
            {
              'materi_name': 'Gelombang Osilasi',
              'duration_seconds': p1Seconds + p2Seconds,
              'created_at': p2['created_at'],
            },
            where: 'id = ?',
            whereArgs: [p1List.first['id']],
          );
          await db.delete(
            tableMateriHistories,
            where: 'id = ?',
            whereArgs: [p2['id']],
          );
        } else {
          await db.update(
            tableMateriHistories,
            {'materi_id': 1, 'materi_name': 'Gelombang Osilasi'},
            where: 'id = ?',
            whereArgs: [p2['id']],
          );
        }
      }
    }

    return await db.query(
      tableMateriHistories,
      where: 'user_email = ?',
      whereArgs: [email],
      orderBy: 'created_at DESC',
    );
  }

  // READ: Mengambil semua histori user dalam bentuk Model
  Future<List<MateriHistoryModel>> getAllHistoryModels({
    String? userEmail,
  }) async {
    final list = await getAllHistories(userEmail: userEmail);
    return list.map((map) => MateriHistoryModel.fromMap(map)).toList();
  }

  // READ: Mengambil histori untuk materi tertentu dari user tertentu
  Future<List<Map<String, dynamic>>> getHistoriesByMateri(
    int materiId, {
    String? userEmail,
  }) async {
    final email = _resolveEmail(userEmail);
    final db = await instance.database;
    return await db.query(
      tableMateriHistories,
      where: 'materi_id = ? AND user_email = ?',
      whereArgs: [materiId, email],
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

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
