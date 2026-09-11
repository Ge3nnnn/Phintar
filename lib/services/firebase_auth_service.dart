import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:phintar/models/firebase_model/user_models.dart';
import 'package:phintar/services/google_sign_in.dart';

/// Service khusus untuk mengelola otentikasi Firebase (Email/Password & Google Sign In)
/// serta sinkronisasi data profil pengguna ke Cloud Firestore.
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _webClientId =
      '130515174634-fhj1i24ovbqpvnrsh6t2pt56bn9m7h3i.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? _webClientId : null,
    serverClientId: _webClientId,
  );

  /// Referensi ke koleksi `users` di Cloud Firestore.
  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  /// Stream untuk memantau perubahan status login pengguna (LoggedIn/LoggedOut).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Pengguna Firebase Auth yang sedang login saat ini.
  User? get currentUser => _auth.currentUser;

  /// Mendapatkan User ID (UID) dari pengguna yang sedang login saat ini.
  String? get currentUserId => _auth.currentUser?.uid;

  /// Memeriksa apakah format alamat email valid berdasarkan pola standar regex.
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  /// Memeriksa apakah email sudah terdaftar di basis data pengguna Firestore `users`.
  Future<bool> isEmailRegistered(String email) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty || !isValidEmail(cleanEmail)) {
      return false;
    }

    try {
      // Periksa kecocokan email asli
      final snapshot = await _usersRef
          .where('email', isEqualTo: cleanEmail)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return true;
      }

      // Periksa dengan format huruf kecil jika sebelumnya tersimpan lowercase
      final snapshotLower = await _usersRef
          .where('email', isEqualTo: cleanEmail.toLowerCase())
          .limit(1)
          .get();
      if (snapshotLower.docs.isNotEmpty) {
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('[FirebaseAuthService] Gagal memeriksa email di Firestore: $e');
      // Jika terjadi kesalahan akses/koneksi, kembalikan true sebagai fallback agar tidak memblokir pengguna
      return true;
    }
  }

  /// Mendaftarkan pengguna baru dengan email & password yang valid,
  /// kemudian langsung mendaftarkan dan menyimpan data profilnya ke Firebase Firestore.
  Future<UserCredential> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || !isValidEmail(trimmedEmail)) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message:
            'Format alamat email tidak valid. Pastikan format email benar (contoh: nama@email.com).',
      );
    }

    if (password.isEmpty) {
      throw FirebaseAuthException(
        code: 'weak-password',
        message: 'Kata sandi tidak boleh kosong.',
      );
    }

    if (password.length < 6) {
      throw FirebaseAuthException(
        code: 'weak-password',
        message: 'Kata sandi terlalu lemah. Gunakan minimal 6 karakter.',
      );
    }

    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: trimmedEmail,
      password: password,
    );

    final user = userCredential.user;
    if (user != null) {
      try {
        await user.updateDisplayName(name.trim());
        await user.reload();
      } catch (e) {
        debugPrint('Warning updateDisplayName: $e');
      }

      // Langsung daftarkan data profil pengguna ke Cloud Firestore
      await _saveUserData(user: user, name: name.trim(), email: trimmedEmail);
    }

    return userCredential;
  }

  /// Melakukan login dengan email dan password yang valid.
  /// Setelah login berhasil, data profil pengguna dipastikan terdaftar di Firestore.
  Future<UserCredential> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || !isValidEmail(trimmedEmail)) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message:
            'Format alamat email tidak valid. Pastikan format email benar (contoh: nama@email.com).',
      );
    }

    if (password.isEmpty) {
      throw FirebaseAuthException(
        code: 'wrong-password',
        message: 'Kata sandi tidak boleh kosong.',
      );
    }

    final userCredential = await _auth.signInWithEmailAndPassword(
      email: trimmedEmail,
      password: password,
    );

    final user = userCredential.user;
    if (user != null) {
      // Pastikan data pengguna juga terdaftar di database Firestore jika belum ada
      await _ensureUserDataExists(user: user, fallbackEmail: trimmedEmail);
    }

    return userCredential;
  }

  /// Melakukan login menggunakan akun Google. Jika pengguna baru, data profil akan disimpan ke Firestore.
  Future<UserCredential?> signInWithGoogle() async {
    // Bersihkan sesi lokal Google Sign-In sebelumnya agar dialog pemilihan akun selalu muncul
    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // Pengguna membatalkan proses sign in

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final String? idToken = googleAuth.idToken;
    if (idToken == null && googleAuth.accessToken == null) {
      throw FirebaseAuthException(
        code: 'invalid-credential',
        message:
            'Gagal mendapatkan token autentikasi Google. Pastikan SHA-1 sudah terdaftar di Firebase Console.',
      );
    }

    return await firebaseAuthWithGoogle(
      idToken: idToken ?? '',
      accessToken: googleAuth.accessToken,
    );
  }

  /// Melakukan registrasi menggunakan akun Google.
  /// Berfungsi identik dengan [signInWithGoogle] karena Firebase menangani
  /// registrasi dan login Google melalui credential yang sama.
  Future<UserCredential?> registerWithGoogle() => signInWithGoogle();

  /// Mengirimkan tautan reset kata sandi ke email pengguna.
  Future<void> sendPasswordResetEmail(String email) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || !isValidEmail(trimmedEmail)) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message:
            'Format alamat email tidak valid. Pastikan format email benar (contoh: nama@email.com).',
      );
    }
    await _auth.sendPasswordResetEmail(email: trimmedEmail);
  }

  /// Mengekstrak kode verifikasi aksi (oobCode) jika pengguna menempelkan tautan lengkap Firebase,
  /// atau mengembalikan kode bersih jika pengguna memasukkan kodenya secara langsung.
  static String extractActionCode(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return '';

    // Jika pengguna menempelkan URL lengkap Firebase (contoh: https://...?oobCode=XXXXX&apiKey=...)
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      try {
        final uri = Uri.parse(trimmed);
        final code = uri.queryParameters['oobCode'];
        if (code != null && code.isNotEmpty) {
          return code.trim();
        }
      } catch (_) {}
    }

    // Jika mengandung substring oobCode=
    if (trimmed.contains('oobCode=')) {
      final match = RegExp(r'oobCode=([a-zA-Z0-9_-]+)').firstMatch(trimmed);
      if (match != null && match.group(1) != null) {
        return match.group(1)!.trim();
      }
    }

    return trimmed;
  }

  /// Memverifikasi kode reset kata sandi ke Firebase Authentication.
  /// Mengembalikan email pengguna yang berhak jika kode valid dan belum kedaluwarsa.
  Future<String> verifyPasswordResetCode(String codeOrUrl) async {
    final code = extractActionCode(codeOrUrl);
    if (code.isEmpty) {
      throw FirebaseAuthException(
        code: 'invalid-action-code',
        message: 'Kode atau tautan verifikasi tidak boleh kosong.',
      );
    }
    return await _auth.verifyPasswordResetCode(code);
  }

  /// Mengonfirmasi pembaruan kata sandi baru ke Firebase Authentication menggunakan kode reset.
  Future<void> confirmPasswordReset({
    required String codeOrUrl,
    required String newPassword,
  }) async {
    final code = extractActionCode(codeOrUrl);
    if (code.isEmpty) {
      throw FirebaseAuthException(
        code: 'invalid-action-code',
        message: 'Kode atau tautan verifikasi tidak boleh kosong.',
      );
    }

    final pass = newPassword.trim();
    if (pass.length < 6) {
      throw FirebaseAuthException(
        code: 'weak-password',
        message: 'Kata sandi baru minimal harus terdiri dari 6 karakter.',
      );
    }

    await _auth.confirmPasswordReset(
      code: code,
      newPassword: pass,
    );
  }

  /// Memperbarui nama tampilan (displayName) pengguna di Firebase Auth.
  Future<void> updateDisplayName(String newName) async {
    await _auth.currentUser?.updateDisplayName(newName);
    await _auth.currentUser?.reload();
  }

  /// Memperbarui kata sandi pengguna yang sedang aktif di Firebase Auth.
  Future<void> updatePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    } else {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Tidak ada pengguna yang sedang login.',
      );
    }
  }

  /// Mengambil data rincian profil pengguna dari dokumen Firestore berdasarkan UID.
  Future<UserModelFirebase?> getUserDetails(String uid) async {
    try {
      final doc = await _usersRef.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModelFirebase.fromMap(doc.data()!);
      }
    } catch (e) {
      debugPrint('Warning getUserDetails: $e');
    }
    return null;
  }

  /// Melakukan proses keluar (sign out) dari akun Google dan Firebase Auth.
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  /// Memastikan data profil pengguna sudah terdaftar di Firestore koleksi `users`.
  /// Jika belum ada dokumennya, maka akan otomatis dibuatkan.
  Future<void> _ensureUserDataExists({
    required User user,
    required String fallbackEmail,
  }) async {
    try {
      final doc = await _usersRef.doc(user.uid).get();
      if (!doc.exists || doc.data() == null) {
        final email = (user.email != null && user.email!.isNotEmpty)
            ? user.email!
            : fallbackEmail;
        final name = (user.displayName != null && user.displayName!.isNotEmpty)
            ? user.displayName!
            : (email.contains('@')
                  ? email.split('@').first
                  : 'Pengguna Phintar');

        await _saveUserData(
          user: user,
          name: name,
          email: email,
          photoUrl: user.photoURL ?? '',
        );
      }
    } catch (e) {
      debugPrint('Warning _ensureUserDataExists: $e');
    }
  }

  /// Helper internal untuk menyimpan atau memperbarui data profil pengguna ke Firestore.
  Future<void> _saveUserData({
    required User user,
    required String name,
    required String email,
    String photoUrl = '',
  }) async {
    try {
      final userModelFirebase = UserModelFirebase(
        uid: user.uid,
        name: name,
        email: email,
        photoUrl: photoUrl.isNotEmpty ? photoUrl : (user.photoURL ?? ''),
        createdAt: DateTime.now(),
      );

      await _usersRef
          .doc(user.uid)
          .set(userModelFirebase.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Warning _saveUserData to Firestore: $e');
    }
  }

  /// Mengonversi exception Firebase Auth menjadi pesan Bahasa Indonesia yang mudah dipahami.
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Akun dengan email tersebut tidak ditemukan. Silakan periksa kembali email atau daftar akun baru.';
        case 'wrong-password':
          return 'Kata sandi yang Anda masukkan salah. Silakan coba lagi.';
        case 'invalid-credential':
          return 'Email atau kata sandi yang Anda masukkan salah. Pastikan email sudah terdaftar dan kata sandi benar.';
        case 'email-already-in-use':
          return 'Email ini sudah terdaftar. Silakan gunakan email lain atau langsung masuk.';
        case 'invalid-email':
          return 'Format alamat email tidak valid. Pastikan format email sudah benar (contoh: nama@email.com).';
        case 'weak-password':
          return 'Kata sandi terlalu lemah. Gunakan minimal 6 karakter.';
        case 'user-disabled':
          return 'Akun ini telah dinonaktifkan oleh administrator.';
        case 'too-many-requests':
          return 'Terlalu banyak percobaan gagal. Silakan coba lagi beberapa saat lagi.';
        case 'network-request-failed':
          return 'Koneksi internet bermasalah. Periksa koneksi Anda.';
        case 'requires-recent-login':
          return 'Demi keamanan, silakan keluar dan masuk kembali sebelum mengubah kata sandi.';
        case 'account-exists-with-different-credential':
          return 'Akun sudah terdaftar dengan metode masuk lain. Silakan masuk menggunakan metode yang sesuai.';
        case 'operation-not-allowed':
          return 'Metode masuk ini belum diaktifkan di Firebase Console.';
        case 'channel-error':
          return 'Harap masukkan data dengan lengkap dan benar.';
        case 'invalid-action-code':
          return 'Kode atau tautan verifikasi salah, tidak lengkap, atau sudah pernah digunakan. Silakan periksa kembali email Anda.';
        case 'expired-action-code':
          return 'Kode atau tautan verifikasi telah kedaluwarsa. Silakan kirim ulang email verifikasi.';
        default:
          return error.message ??
              'Terjadi kesalahan otentikasi. Silakan coba lagi.';
      }
    }

    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Izin akses database ditolak. Periksa aturan keamanan di Firebase Console.';
        case 'unavailable':
          return 'Layanan Firebase sedang tidak dapat diakses. Silakan coba lagi nanti.';
        default:
          return error.message ?? 'Terjadi kesalahan pada layanan Firebase.';
      }
    }

    final errStr = error.toString();
    if (errStr.contains('network_error') ||
        errStr.contains('ApiException: 7')) {
      return 'Koneksi internet bermasalah. Periksa koneksi Anda.';
    }
    if (errStr.contains('ApiException: 12500') ||
        errStr.contains('sign_in_failed')) {
      return 'Gagal masuk dengan Google (Error 12500). Pastikan Google provider aktif di Firebase Console dan Support Email sudah dipilih.';
    }
    if (errStr.contains('invalid-email') ||
        errStr.contains('badly formatted')) {
      return 'Format alamat email tidak valid. Pastikan format email sudah benar (contoh: nama@email.com).';
    }
    if (errStr.contains('email-already-in-use')) {
      return 'Email ini sudah terdaftar. Silakan gunakan email lain atau langsung masuk.';
    }
    if (errStr.contains('user-not-found')) {
      return 'Akun dengan email tersebut tidak ditemukan.';
    }
    if (errStr.contains('wrong-password') ||
        errStr.contains('invalid-credential')) {
      return 'Email atau kata sandi yang Anda masukkan salah.';
    }

    return error.toString();
  }
}
