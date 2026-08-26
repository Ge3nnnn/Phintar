import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:blabla/data/database/db_materi.dart';
import 'package:blabla/views/6_materi/Gelombang_dan_materi/2_gelombang_dan_osilasi.dart';
import 'package:blabla/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// First page of the "Gelombang dan Osilasi" course module.
///
/// Displays introductory text about oscillation and wave concepts.
/// Records learning duration to the local database when the user
/// taps SELESAI (done) or LANJUTKAN (continue to next page).
///
/// To add a new materi page, create a similar StatefulWidget,
/// update the [materiId] and [materiName] in [_saveMateriHistory],
/// and wire navigation from the previous/next page.
class Materi1Gelombag extends StatefulWidget {
  const Materi1Gelombag({super.key});

  @override
  State<Materi1Gelombag> createState() => _Materi1State();
}

class _Materi1State extends State<Materi1Gelombag> {
  // Waktu mulai belajar dicatat saat halaman dibuka
  final DateTime _startTime = DateTime.now();

  /// Saves how long the user spent on this page to the local SQLite
  /// database. Uses [materiId] = 1 for this specific materi page.
  /// Duration is calculated from [_startTime] to now.
  Future<void> _saveMateriHistory() async {
    final durationSeconds = DateTime.now().difference(_startTime).inSeconds;
    await DatabaseHelperMateri.instance.insertHistory(
      materiId: 1,
      materiName: '1.1 Pengantar Gelombang dan Osilasi',
      durationSeconds: durationSeconds,
    );
  }

  /// Builds the page layout: top header with progress bar,
  /// scrollable body with materi text, and bottom action buttons.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Header (Tanpa Prefix Icon, Progres Setengah 50%) ─────
            _buildTopHeader(),

            // ── Scrollable Body ──────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1.1 Pengantar Gelombang dan Osilasi',
                      style: AppTextStyle.subjudul,
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      '''Kita mulai mempelajari osilasi dengan sistem sederhana pendulum dan pegas. Meskipun sistem ini mungkin terlihat sangat mendasar, konsep yang terlibat memiliki banyak aplikasi dalam kehidupan nyata.

Sebagai contoh, Gedung Comcast di Philadelphia, Pennsylvania, berdiri setinggi sekitar 305 meter (1000 kaki). Karena gedung dibangun semakin tinggi, gedung tersebut dapat bertindak sebagai pendulum fisik terbalik, dengan lantai atas berosilasi karena aktivitas seismik dan angin yang berfluktuasi.

Di Gedung Comcast, peredam massa tertala digunakan untuk mengurangi osilasi. Dipasang di puncak gedung adalah peredam massa kolom cairan tertala, yang terdiri dari reservoir air berkapasitas 300.000 galon. Tangki berbentuk U ini memungkinkan air berosilasi bebas pada frekuensi yang cocok dengan frekuensi alami gedung. Peredaman disediakan dengan menyetel tingkat turbulensi dalam air yang bergerak menggunakan sekat.''',
                      style: AppTextStyle.normalText2,
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 24),

                    // ── Tombol Selesai dan Lanjutkan ─────────────────────────
                    Row(
                      children: [
                        // ── Tombol SELESAI ───────────────────────────────────
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await _saveMateriHistory();
                              if (!context.mounted) return;
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(
                              Icons.check,
                              color: AppTheme.putih,
                              size: 16,
                            ),
                            label: Text(
                              'SELESAI',
                              style: AppTextStyle.botttonText.copyWith(
                                color: AppTheme.putih,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: AppTheme.glassBorder,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // ── Tombol LANJUTKAN ─────────────────────────────────
                        Expanded(
                          child: CustomElevatedButton(
                            onPressed: () async {
                              await _saveMateriHistory();
                              if (!context.mounted) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Materi2Gelombag(),
                                ),
                              );
                            },
                            text: 'LANJUTKAN',
                            backgroundColor: AppTheme.progressColor,
                            width: double.infinity,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the top header showing the course title and a
  /// progress bar at 50% (page 1 of 2 in this module).
  Widget _buildTopHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
          child: Text(
            'Osilasi & Gelombang',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.putih,
            ),
          ),
        ),
        // Progress bar 50% (setengah)
        Stack(
          children: [
            Container(
              height: 2.5,
              width: double.infinity,
              color: AppTheme.backgroundSecondary,
            ),
            FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                height: 2.5,
                decoration: const BoxDecoration(
                  color: AppTheme.progressColor,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.progressColor,
                      blurRadius: 4,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
