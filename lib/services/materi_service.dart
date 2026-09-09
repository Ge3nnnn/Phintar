import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phintar/models/materi_model.dart';

/// Layanan untuk mengelola data materi pembelajaran secara real-time
/// menggunakan Firebase Cloud Firestore (koleksi `materi`).
class MateriService {
  static final MateriService _instance = MateriService._init();
  factory MateriService() => _instance;
  static MateriService get instance => _instance;

  MateriService._init();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Referensi koleksi Firestore `materi` dengan strongly-typed converter [MateriModel].
  CollectionReference<MateriModel> get _collection => _firestore
      .collection('materi')
      .withConverter<MateriModel>(
        fromFirestore: (snapshot, _) => MateriModel.fromFirestore(snapshot),
        toFirestore: (materi, _) => materi.toFirestore(),
      );

  List<MateriModel>? _cachedMateri;

  /// Mendengarkan perubahan data materi pembelajaran secara real-time (Stream),
  /// diurutkan berdasarkan [sortOrder].
  Stream<List<MateriModel>> getMateriStream() {
    return _collection.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => doc.data()).toList();
      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      _cachedMateri = list;
      return list;
    });
  }

  /// Mendengarkan perubahan satu data materi pembelajaran berdasarkan [id] secara real-time.
  Stream<MateriModel?> getMateriByIdStream(int id) {
    return _collection.snapshots().map((snapshot) {
      for (final doc in snapshot.docs) {
        final item = doc.data();
        if (item.id == id) return item;
      }
      return null;
    });
  }

  /// Mengambil seluruh materi pembelajaran dari Firestore sekali panggil (one-time fetch).
  Future<List<MateriModel>> getAllMateri() async {
    final snapshot = await _collection.get();
    final list = snapshot.docs.map((doc) => doc.data()).toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    _cachedMateri = list;
    return list;
  }

  /// Mengambil satu data materi pembelajaran berdasarkan [id].
  Future<MateriModel?> getMateriById(int id) async {
    final snapshot = await _collection
        .where('id', isEqualTo: id)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data();
    }
    return null;
  }

  /// Mengambil materi berdasarkan [id], dengan fallback pencarian judul [title]
  /// atau fallback ke data seed lokal jika Firestore belum siap/offline.
  Future<MateriModel?> getMateriByIdOrTitle(int id, [String? title]) async {
    // 1. Cek cache in-memory
    if (_cachedMateri != null && _cachedMateri!.isNotEmpty) {
      final cachedMatch = _findInList(_cachedMateri!, id, title);
      if (cachedMatch != null) return cachedMatch;
    }

    // 2. Coba ambil dari Firestore
    try {
      final doc = await _collection.doc(id.toString()).get();
      if (doc.exists && doc.data() != null) {
        return doc.data();
      }
      final snapshot = await _collection
          .where('id', isEqualTo: id)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data();
      }
      if (title != null && title.trim().isNotEmpty) {
        final titleQuery = await _collection
            .where('title', isEqualTo: title.trim())
            .limit(1)
            .get();
        if (titleQuery.docs.isNotEmpty) {
          return titleQuery.docs.first.data();
        }
      }
    } catch (_) {
      // offline / firestore error fallback
    }

    // 3. Fallback: muat dari assets seed JSON
    try {
      final jsonString = await rootBundle.loadString(
        'assets/seed/materi_seed.json',
      );
      final List<dynamic> rawList = json.decode(jsonString);
      final list = rawList
          .map((e) => MateriModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      _cachedMateri = list;
      final match = _findInList(list, id, title);
      if (match != null) return match;
    } catch (_) {}

    return null;
  }

  MateriModel? _findInList(List<MateriModel> list, int id, String? title) {
    // Cocokkan id persis
    for (final m in list) {
      if (m.id == id) return m;
    }
    // Cocokkan judul
    if (title != null && title.trim().isNotEmpty) {
      final clean = title.trim().toLowerCase();
      for (final m in list) {
        final mTitle = m.title.trim().toLowerCase();
        if (mTitle == clean ||
            mTitle.contains(clean) ||
            clean.contains(mTitle)) {
          return m;
        }
      }
    }
    // Legacy mapping: id 1 atau 2 adalah Gelombang dan Osilasi
    if (id == 1 || id == 2) {
      for (final m in list) {
        if (m.title.toLowerCase().contains('gelombang')) return m;
      }
    }
    return list.isNotEmpty ? list.first : null;
  }

  /// Menyimpan atau memperbarui data materi ke Firestore.
  /// Dokumen disimpan dengan Document ID berbasis [materi.id].
  Future<void> addOrUpdateMateri(MateriModel materi) async {
    await _collection
        .doc(materi.id.toString())
        .set(materi, SetOptions(merge: true));
  }

  /// Mengunggah daftar materi sekaligus menggunakan Firestore Batch Write
  /// untuk efisiensi transfer data dan keandalan tinggi.
  Future<void> uploadMateriBatch(List<MateriModel> listMateri) async {
    if (listMateri.isEmpty) return;
    final batch = _firestore.batch();
    for (final materi in listMateri) {
      final docRef = _firestore.collection('materi').doc(materi.id.toString());
      batch.set(docRef, materi.toFirestore(), SetOptions(merge: true));
    }
    await batch.commit();
  }

  /// Helper untuk inisialisasi seluruh materi Fisika (Kelas 10, 11, dan 12) ke Firestore.
  /// Mengambil data kurikulum lengkap dari file seed JSON dan melakukan batch commit.
  Future<void> seedCurriculumMateri({bool force = false}) async {
    try {
      if (!force) {
        final existing = await _collection.get();
        // Cek apakah data sudah lengkap (minimal 23 modul: 7 Kelas 10 + 8 Kelas 11 + 8 Kelas 12)
        final hasAllDocs = existing.docs.length >= 23;
        final needsFormulaUpgrade = existing.docs.any((doc) {
          final blocks = doc.data().blocks;
          return blocks.any(
            (b) => b.type == 'formula' && b.content.contains(r'\'),
          );
        });

        if (hasAllDocs && !needsFormulaUpgrade) {
          return;
        }
      }

      final jsonString = await rootBundle.loadString(
        'assets/seed/materi_seed.json',
      );
      final List<dynamic> rawList = json.decode(jsonString);
      final materiList = rawList
          .map((e) => MateriModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      await uploadMateriBatch(materiList);
    } catch (_) {
      // Fallback jika offline atau file belum siap
    }
  }

  /// Alias untuk kompatibilitas mundur
  Future<void> seedKelas10Materi({bool force = false}) async {
    await seedCurriculumMateri(force: force);
  }

  /// Inisialisasi awal saat aplikasi dibuka jika Firestore masih kosong.
  Future<void> seedInitialMateriIfEmpty() async {
    await seedCurriculumMateri(force: false);
  }
}
