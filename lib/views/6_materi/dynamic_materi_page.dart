import 'package:flutter/material.dart';
import 'package:phintar/constants/app_theme.dart';
import 'package:phintar/constants/app_typografy.dart';
import 'package:phintar/models/materi_model.dart';
import 'package:phintar/models/preference_handler.dart';
import 'package:phintar/services/firestore_materi_service.dart';
import 'package:phintar/widgets/app_bar.dart';
import 'package:phintar/widgets/content_block_renderer.dart';

/// Halaman materi pembelajaran fisika yang merender konten secara dinamis
/// berdasarkan [MateriModel].
///
/// Halaman ini universal untuk seluruh materi SMA (Kelas 10, 11, dan 12).
/// Otomatis mencatat durasi waktu belajar ke Firebase Cloud Firestore
/// saat pengguna membaca materi.
class DynamicMateriPage extends StatefulWidget {
  final MateriModel materi;

  const DynamicMateriPage({super.key, required this.materi});

  @override
  State<DynamicMateriPage> createState() => _DynamicMateriPageState();
}

class _DynamicMateriPageState extends State<DynamicMateriPage> {
  final DateTime _startTime = DateTime.now();
  bool _hasSavedHistory = false;

  /// Menyimpan durasi belajar ke Cloud Firestore pada koleksi `materi_histories`.
  Future<void> _saveHistory() async {
    if (_hasSavedHistory) return;
    _hasSavedHistory = true;

    final durationSeconds = DateTime.now().difference(_startTime).inSeconds;
    // Catat jika pengguna membaca minimal 3 detik
    if (durationSeconds >= 3) {
      await FirestoreMateriService.instance.insertHistory(
        userEmail: PreferenceHandler.userEmail,
        materiId: widget.materi.id,
        materiName: widget.materi.title,
        durationSeconds: durationSeconds,
      );
    }
  }

  @override
  void dispose() {
    _saveHistory();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final materi = widget.materi;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _saveHistory();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundPrimary,
        appBar: CustomAppBar2(
          title: materi.title,
          prefixIcon: Icons.arrow_back_ios_new,
          onPrefixIconTap: () {
            _saveHistory();
            Navigator.of(context).pop();
          },
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Banner / Header Kategori ──────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundSecondary,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.bottonColor.withValues(alpha: 0.3),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryTranslucent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  materi.category.isNotEmpty
                                      ? materi.category
                                      : 'Fisika SMA Kelas 10',
                                  style: AppTextStyle.smallText.copyWith(
                                    color: AppTheme.bottonColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.auto_stories_rounded,
                                color: AppTheme.textColor,
                                size: 18,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(materi.title, style: AppTextStyle.judul),
                          if (materi.description != null &&
                              materi.description!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              materi.description!,
                              style: AppTextStyle.normalText,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Render Seluruh Blok Konten (Dinamis) ─────────────
                  if (materi.blocks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 30.0,
                      ),
                      child: Center(
                        child: Text(
                          'Konten materi belum tersedia.',
                          style: AppTextStyle.normalText,
                        ),
                      ),
                    )
                  else
                    ...materi.blocks.map(
                      (block) => ContentBlockRenderer(block: block),
                    ),

                  const SizedBox(height: 24),

                  // ── Tombol Selesai Belajar ───────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await _saveHistory();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Hebat! Progres belajar "${materi.title}" telah dicatat.',
                                  style: const TextStyle(color: AppTheme.putih),
                                ),
                                backgroundColor: AppTheme.progressColor,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            Navigator.of(context).pop();
                          }
                        },
                        icon: const Icon(
                          Icons.check_circle_outline,
                          color: AppTheme.putih,
                        ),
                        label: Text(
                          'Selesai Belajar',
                          style: AppTextStyle.subsubjudul.copyWith(
                            color: AppTheme.putih,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.progressColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
