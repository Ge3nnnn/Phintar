import 'package:json_annotation/json_annotation.dart';
import 'firestore_helper.dart';

part 'user_models.g.dart';

/// Model data untuk menyimpan informasi profil pengguna di koleksi `users` Firestore.
@JsonSerializable()
class UserModelFirebase {
  /// Unique Identifier (UID) dari Firebase Authentication.
  @JsonKey(defaultValue: '')
  final String uid;

  /// Nama lengkap pengguna.
  @JsonKey(defaultValue: '')
  final String name;

  /// Alamat email pengguna.
  @JsonKey(defaultValue: '')
  final String email;

  /// Tanggal registrasi pengguna yang disimpan sebagai Timestamp di Firestore.
  @JsonKey(fromJson: dateTimeFromJson, toJson: dateTimeToJson)
  final DateTime createdAt;

  UserModelFirebase({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  /// Mengonversi Map JSON menjadi objek [UserModelFirebase].
  factory UserModelFirebase.fromJson(Map<String, dynamic> json) =>
      _$UserModelFirebaseFromJson(json);

  /// Helper factory untuk mengubah Map data Firestore menjadi [UserModelFirebase].
  factory UserModelFirebase.fromMap(Map<String, dynamic> map) =>
      UserModelFirebase.fromJson(map);

  /// Mengonversi instans [UserModelFirebase] menjadi Map JSON.
  Map<String, dynamic> toJson() => _$UserModelFirebaseToJson(this);

  /// Alias method [toJson] untuk menyimpan data ke dokumen Firestore.
  Map<String, dynamic> toMap() => toJson();
}
