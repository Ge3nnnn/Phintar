import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserModelSQL {
  final int? id;
  final String email;
  final String password;
  final String nama;
  UserModelSQL({
    this.id,
    required this.email,
    required this.password,
    required this.nama,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'email': email,
      'password': password,
      'nama': nama,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory UserModelSQL.fromMap(Map<String, dynamic> map) {
    return UserModelSQL(
      id: map['id'] != null ? map['id'] as int : null,
      email: map['email'] as String,
      password: map['password'] as String,
      nama: map['nama'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModelSQL.fromJson(String source) =>
      UserModelSQL.fromMap(json.decode(source) as Map<String, dynamic>);
}
