import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:phintar/models/firebase_model/user_models.dart';

/// Web OAuth Client ID dari Firebase Console (phintar-edu-6cd66)
const String _webClientId =
    '130515174634-fhj1i24ovbqpvnrsh6t2pt56bn9m7h3i.apps.googleusercontent.com';

/// Instance FirebaseAuth & GoogleSignIn yang dikonfigurasi
final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: kIsWeb ? _webClientId : null,
  serverClientId: _webClientId,
);

/// Helper function untuk autentikasi ke Firebase menggunakan Google [idToken].
///
/// Mengikuti pola Android / Kotlin:
/// ```kotlin
/// private fun firebaseAuthWithGoogle(idToken: String) {
///     val credential = GoogleAuthProvider.getCredential(idToken, null)
///     auth.signInWithCredential(credential)
///         .addOnCompleteListener(this) { task ->
///             if (task.isSuccessful) {
///                 val user = auth.currentUser
///                 // Successful sign-in
///             } else {
///                 // Handle authentication failure
///             }
///         }
/// }
/// ```
Future<UserCredential> firebaseAuthWithGoogle({
  required String idToken,
  String? accessToken,
  void Function(User user)? onSuccessfulSignIn,
  void Function(Object error)? onAuthenticationFailure,
}) async {
  try {
    // 1. Buat credential Firebase Auth dari idToken & accessToken
    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: idToken,
      accessToken: accessToken,
    );

    // 2. Sign-in ke Firebase dengan credential
    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

    // 3. State jika login berhasil (task.isSuccessful -> val user = auth.currentUser)
    final User? user = _auth.currentUser ?? userCredential.user;
    if (user != null) {
      // Sinkronisasi data profil pengguna baru / foto ke Cloud Firestore
      await _syncUserProfileToFirestore(user);

      // Callback sukses opsional
      onSuccessfulSignIn?.call(user);

      return userCredential;
    } else {
      final failure = FirebaseAuthException(
        code: 'user-not-found',
        message: 'Pengguna tidak ditemukan setelah proses autentikasi.',
      );
      onAuthenticationFailure?.call(failure);
      throw failure;
    }
  } catch (error) {
    // 4. State jika autentikasi gagal (Handle authentication failure)
    debugPrint('Authentication failure in firebaseAuthWithGoogle: $error');
    onAuthenticationFailure?.call(error);
    rethrow;
  }
}

/// Helper function utama untuk mengelola alur Google Sign-In secara menyeluruh.
///
/// Mengembalikan [User?] jika berhasil login atau `null` jika pengguna membatalkan dialog.
Future<User?> signInWithGoogle({
  void Function(User user)? onSuccessfulSignIn,
  void Function(Object error)? onAuthenticationFailure,
  void Function()? onCanceled,
}) async {
  try {
    // 1. Reset sesi lama agar prompt pemilihan akun Google selalu muncul
    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    // 2. Trigger the Google Sign-In flow (Buka dialog akun Google)
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      // Pengguna membatalkan proses sign in
      onCanceled?.call();
      return null;
    }

    // 3. Dapatkan detail autentikasi (idToken & accessToken) dari respon Google
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final String? idToken = googleAuth.idToken;
    if (idToken == null && googleAuth.accessToken == null) {
      final tokenError = FirebaseAuthException(
        code: 'missing-id-token',
        message:
            'Gagal mendapatkan ID Token dari Google. Pastikan SHA-1 sudah terdaftar di Firebase Console.',
      );
      onAuthenticationFailure?.call(tokenError);
      throw tokenError;
    }

    // 4. Teruskan token ke helper firebaseAuthWithGoogle
    final userCredential = await firebaseAuthWithGoogle(
      idToken: idToken ?? '',
      accessToken: googleAuth.accessToken,
      onSuccessfulSignIn: onSuccessfulSignIn,
      onAuthenticationFailure: onAuthenticationFailure,
    );

    return userCredential.user;
  } catch (error) {
    debugPrint('Error during Google Sign-In flow: $error');
    onAuthenticationFailure?.call(error);
    rethrow;
  }
}

/// Helper untuk keluar (sign out) dari akun Google dan Firebase Auth
Future<void> signOutGoogle() async {
  try {
    await _googleSignIn.signOut();
  } catch (_) {}
  await _auth.signOut();
}

/// Helper internal untuk menyimpan data profil pengguna baru ke Firestore
Future<void> _syncUserProfileToFirestore(User user) async {
  try {
    final usersRef = FirebaseFirestore.instance.collection('users');
    final doc = await usersRef.doc(user.uid).get();

    if (!doc.exists) {
      final newUser = UserModelFirebase(
        uid: user.uid,
        name: user.displayName ?? 'Google User',
        email: user.email ?? '',
        photoUrl: user.photoURL ?? '',
        createdAt: DateTime.now(),
      );
      await usersRef.doc(user.uid).set(newUser.toMap());
    } else {
      // Jika belum ada photoUrl di Firestore tetapi ada di akun Google, perbarui
      final data = doc.data();
      if (data != null &&
          (data['photoUrl'] == null ||
              (data['photoUrl'] as String).isEmpty) &&
          user.photoURL != null &&
          user.photoURL!.isNotEmpty) {
        await usersRef.doc(user.uid).set({
          'photoUrl': user.photoURL,
        }, SetOptions(merge: true));
      }
    }
  } catch (e) {
    debugPrint('Firestore sync error in _syncUserProfileToFirestore: $e');
  }
}
