import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:phintar/models/firebase_model/firestore_helper.dart';

part 'todo_models.g.dart';

/// Model data yang mewakili item tugas (Todo) di Cloud Firestore.
/// Menggunakan `json_annotation` untuk serialisasi otomatis JSON/Map.
@JsonSerializable()
class TodoModel {
  /// ID dokumen unik di Firestore (tidak disertakan saat serialisasi ke JSON).
  @JsonKey(defaultValue: '', includeToJson: false)
  final String id;

  /// Judul tugas.
  @JsonKey(defaultValue: '')
  final String title;

  /// Deskripsi singkat tugas.
  @JsonKey(defaultValue: '')
  final String description;

  /// Status penyelesaian tugas (true jika selesai).
  @JsonKey(defaultValue: false)
  final bool isCompleted;

  /// User ID pemilik tugas di Firebase Authentication.
  @JsonKey(defaultValue: '')
  final String userId;

  /// Waktu pembuatan tugas yang dikonversi dari/ke Timestamp Firestore.
  @JsonKey(fromJson: dateTimeFromJson, toJson: dateTimeToJson)
  final DateTime createdAt;

  TodoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.userId,
    required this.createdAt,
  });

  /// Mengonversi struktur JSON (Map) menjadi objek [TodoModel].
  factory TodoModel.fromJson(Map<String, dynamic> json) =>
      _$TodoModelFromJson(json);

  /// Membuat instans [TodoModel] langsung dari [DocumentSnapshot] Firestore.
  /// Menggabungkan data dokumen dengan ID dokumennya.
  factory TodoModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TodoModel.fromJson({...data, 'id': doc.id});
  }

  /// Mengonversi objek [TodoModel] menjadi struktur Map/JSON.
  Map<String, dynamic> toJson() => _$TodoModelToJson(this);

  /// Alias method [toJson] untuk keperluan penyimpanan ke Firestore Map.
  Map<String, dynamic> toMap() => toJson();
}
