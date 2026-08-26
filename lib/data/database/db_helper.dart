import 'package:blabla/models/user_model_login.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    // 1. PERBAIKAN: Menghapus spasi di akhir nama file .db
    final path = join(dbPath, 'datapengguna.db');

    return await openDatabase(
      path,
      version: 3,
      // 2. PERBAIKAN: Logika onUpgrade menggunakan oldVersion
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE siswa(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nama TEXT,
              kelas TEXT
            )
          ''');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE users ADD COLUMN nomor_hp TEXT');
        }
      },
      // 3. PERBAIKAN: onCreate harus mencerminkan struktur TERBARU (Versi 3)
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE,
            password TEXT,
            nama TEXT,
            nomor_hp TEXT 
          )
        ''');

        // Tabel siswa langsung dibuat saat instalasi baru
        await db.execute('''
          CREATE TABLE siswa(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT,
            kelas TEXT
          )
        ''');
      },
    );
  }

  // === OPERASI CRUD ===

  Future<bool> registerUser(UserModelSQL pengguna) async {
    final db = await database;
    try {
      await db.insert('users', pengguna.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<UserModelSQL?> loginUser(String email, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (results.isNotEmpty) {
      return UserModelSQL.fromMap(results.first);
    }
    return null;
  }

  Future<List<UserModelSQL>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query('users');
    return results.map((map) => UserModelSQL.fromMap(map)).toList();
  }

  Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> updateUser(UserModelSQL pengguna) async {
    final db = await database;
    try {
      int count = await db.update(
        'users',
        pengguna.toMap(),
        where: 'id = ?',
        // 4. PERBAIKAN: Gunakan ID, bukan Nama.
        // Pastikan di UserModelSQL kamu sudah menambahkan variabel 'id' (int?).
        whereArgs: [pengguna.id],
      );
      return count > 0;
    } catch (e) {
      return false;
    }
  } // Tambahkan fungsi ini di db_helper.dart untuk mengecek keberadaan email

  Future<bool> checkEmailExists(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty; // Mengembalikan true jika email ditemukan
  }

  // Fungsi untuk memperbarui password berdasarkan email
  Future<bool> updatePassword(String email, String newPassword) async {
    final db = await database;
    try {
      int count = await db.update(
        'users',
        {'password': newPassword},
        where: 'email = ?',
        whereArgs: [email],
      );
      return count > 0;
    } catch (e) {
      return false;
    }
  }
}
