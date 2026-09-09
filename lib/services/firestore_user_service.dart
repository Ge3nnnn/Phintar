import 'package:Phintar/models/firebase_model/user_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service untuk mengelola dokumen profil pengguna di Cloud Firestore koleksi `users`.
class FirestoreUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  /// Mendapatkan data profil pengguna berdasarkan UID.
  Future<UserModelFirebase?> getUser(String uid) async {
    try {
      final doc = await _usersRef.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModelFirebase.fromMap(doc.data()!);
      }
    } catch (_) {}
    return null;
  }

  /// Stream real-time data profil pengguna berdasarkan UID.
  Stream<UserModelFirebase?> streamUser(String uid) {
    return _usersRef.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserModelFirebase.fromMap(snapshot.data()!);
      }
      return null;
    });
  }

  /// Memperbarui nama pengguna di dokumen Firestore.
  Future<void> updateUserName(String uid, String name) async {
    await _usersRef.doc(uid).update({'name': name});
  }

  /// Menyimpan atau menimpa data pengguna di dokumen Firestore.
  Future<void> saveUser(UserModelFirebase user) async {
    await _usersRef.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }
}
