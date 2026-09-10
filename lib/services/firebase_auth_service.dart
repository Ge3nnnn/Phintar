import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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

  /// Mendaftarkan pengguna baru dengan email & password, kemudian menyimpan profilnya ke Firestore.
  Future<UserCredential> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = userCredential.user;
    if (user != null) {
      await user.updateDisplayName(name);
      await user.reload();
      await _saveUserData(user: user, name: name, email: email.trim());
    }

    return userCredential;
  }

  /// Melakukan login dengan email dan password.
  Future<UserCredential> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
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
    await _auth.sendPasswordResetEmail(email: email.trim());
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
    final doc = await _usersRef.doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModelFirebase.fromMap(doc.data()!);
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

  /// Helper internal untuk menyimpan data profil pengguna baru ke Firestore.
  Future<void> _saveUserData({
    required User user,
    required String name,
    required String email,
    String photoUrl = '',
  }) async {
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
  }

  /// Mengonversi exception Firebase Auth menjadi pesan Bahasa Indonesia yang mudah dipahami.
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Akun dengan email tersebut tidak ditemukan.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'Email atau kata sandi yang Anda masukkan salah.';
        case 'email-already-in-use':
          return 'Email ini sudah terdaftar. Silakan gunakan email lain atau masuk.';
        case 'invalid-email':
          return 'Format alamat email tidak valid.';
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
          return 'Metode masuk ini (Google) belum diaktifkan di Firebase Console (Authentication > Sign-in method).';
        default:
          return error.message ??
              'Terjadi kesalahan otentikasi. Silakan coba lagi.';
      }
    }
    // pesannya ada disisni
    final errStr = error.toString();
    if (errStr.contains('network_error') ||
        errStr.contains('ApiException: 7')) {
      return 'Koneksi internet bermasalah. Periksa koneksi Anda.';
    }
    if (errStr.contains('ApiException: 12500') ||
        errStr.contains('sign_in_failed')) {
      return 'Gagal masuk dengan Google (Error 12500). Pastikan Google provider aktif di Firebase Console dan Support Email sudah dipilih.';
    }
    return error.toString();
  }
}
