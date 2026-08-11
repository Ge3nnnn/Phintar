import 'package:blabla/models/user_model_login.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Class DBHelper menggunakan pola desain Singleton untuk mengelola koneksi dan operasi database SQLite (sqflite).
class DBHelper {
  // Menggunakan konstruktor privat (_internal) dan static instance untuk memastikan hanya ada 1 objek DBHelper di seluruh aplikasi.
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  // Getter async untuk mendapatkan instance database.
  // Jika database belum terbuka/dibuat, maka akan memanggil _initDB() terlebih dahulu.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Fungsi untuk menginisialisasi database SQLite di penyimpanan lokal perangkat.
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(
      dbPath,
      'datapengguna.db ',
    ); // Nama file database lokal: ppkd.db

    return await openDatabase(
      path,
      version: 3, // Versi skema database
      // Callback yang dijalankan jika versi database dinaikkan (misalnya dari v1 ke v2 atau v3).
      onUpgrade: (db, oldVersion, newVersion) async {
        if (newVersion > 1) {
          await db.execute('''
          CREATE TABLE siswa(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT,
            kelas TEXT
          )
        ''');
        }
        if (newVersion > 2) {
          // Menambahkan kolom baru 'nomor_hp' ke tabel 'users' saat migrasi versi 3.
          await db.execute('ALTER TABLE users ADD COLUMN nomor_hp TEXT');
        }
      },
      // Callback yang dijalankan saat database pertama kali dibuat.
      onCreate: (db, version) async {
        // Membuat tabel 'users' untuk menyimpan data login pengguna.
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE,
            password TEXT,
            nama TEXT
          )
        ''');
        // // Membuat tabel 'siswa'.
        // await db.execute('''
        //   CREATE TABLE siswa(
        //     id INTEGER PRIMARY KEY AUTOINCREMENT,
        //     nama TEXT,
        //     kelas TEXT
        //   )
        // ''');
      },
    );
  }

  // === OPERASI CRUD (CREATE, READ, UPDATE, DELETE) ===

  // 1. CREATE: Mendaftarkan pengguna baru ke tabel 'users'.
  Future<bool> registerUser(UserModelSQL pengguna) async {
    final db = await database;

    try {
      await db.insert('users', pengguna.toMap());
      return true; // Berhasil disimpan
    } catch (e) {
      return false; // Gagal (misalnya karena email sudah terdaftar / constraint UNIQUE)
    }
  }

  // 2. READ (AUTHENTICATION): Memeriksa login berdasarkan pencocokan email & password.
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
    return null; // Pengguna tidak ditemukan / password salah
  }

  // 3. READ ALL: Mengambil seluruh daftar pengguna dari tabel 'users'.
  Future<List<UserModelSQL>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query('users');
    return results.map((map) => UserModelSQL.fromMap(map)).toList();
  }

  // 4. DELETE: Menghapus data pengguna dari tabel 'users' berdasarkan id.
  Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // 5. UPDATE: Memperbarui data pengguna di tabel 'users' berdasarkan id.
  Future<bool> updateUser(UserModelSQL pengguna) async {
    final db = await database;

    try {
      int count = await db.update(
        'users',
        pengguna.toMap(),
        where: 'id = ?',
        whereArgs: [pengguna.nama],
      );
      return count >
          0; // Mengembalikan true jika ada minimal 1 baris yang berhasil di-update
    } catch (e) {
      return false;
    }
  }
}
