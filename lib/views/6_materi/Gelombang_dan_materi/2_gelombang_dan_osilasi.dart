import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:blabla/database/db_materi.dart';
import 'package:blabla/widgets/app_button.dart';
import 'package:blabla/widgets/bottom_nav/bottom_nav_bar_phintar.dart';
import 'package:blabla/widgets/extention/navigator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class Materi2Gelombag extends StatefulWidget {
  /// Default YouTube video (Animasi Gelombang & Osilasi Harmonik Fisika)
  /// Bisa diisi Video ID atau Full YouTube URL
  final String videoId;

  const Materi2Gelombag({super.key, this.videoId = 'qRv4oJzK240'});

  @override
  State<Materi2Gelombag> createState() => _Materi2GelombagState();
}

class _Materi2GelombagState extends State<Materi2Gelombag> {
  final DateTime _startTime = DateTime.now();
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Support either full YouTube URL or raw Video ID
    final resolvedVideoId =
        YoutubePlayerController.convertUrlToId(widget.videoId) ??
        widget.videoId;

    _controller = YoutubePlayerController.fromVideoId(
      videoId: resolvedVideoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
        loop: false,
        showVideoAnnotations: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  Future<void> _saveMateriHistory() async {
    final durationSeconds = DateTime.now().difference(_startTime).inSeconds;
    await DatabaseHelperMateri.instance.insertHistory(
      materiId: 1,
      materiName: '1.2 Visualisasi Gelombang Harmonik',
      durationSeconds: durationSeconds,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Header (Tanpa Prefix Icon, Progres Terisi Penuh 100%) ──
            _buildTopHeader(),

            // ── Scrollable Content ──────────────────────────────
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
                    // ── 1. YouTube Video Player Card ────────────
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundSecondary,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.borderColor,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.45),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: YoutubePlayer(
                        controller: _controller,
                        aspectRatio: 16 / 9,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── 2. Title & Module Description ───────────
                    Text(
                      '1.2 Visualisasi Gelombang Harmonik',
                      style: AppTextStyle.subjudul,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Dalam modul ini, kita akan mengeksplorasi bagaimana fungsi trigonometri membentuk dasar dari deskripsi fisik gelombang. Perambatan gelombang harmonik bukan sekadar gerakan naik-turun, melainkan transfer energi melalui medium tanpa perpindahan massa permanen. Perhatikan bagaimana amplitudo dan frekuensi saling berinteraksi dalam simulasi video di atas.',
                      style: AppTextStyle.normalText2,
                      textAlign: TextAlign.justify,
                    ),

                    const SizedBox(height: 24),

                    // ── 3. Bottom Action Buttons (KEMBALI & LANJUTKAN) ──────
                    Row(
                      children: [
                        // ── Tombol KEMBALI ─────────────────────────────────
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await _saveMateriHistory();
                              if (!context.mounted) return;
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(
                              Icons.arrow_back,
                              color: AppTheme.putih,
                              size: 16,
                            ),
                            label: Text(
                              'KEMBALI',
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

                        // ── Tombol LANJUTKAN ───────────────────────────────
                        Expanded(
                          child: CustomElevatedButton(
                            onPressed: () async {
                              await _saveMateriHistory();
                              if (!context.mounted) return;
                              _showCompletionDialog(context);
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

  // ── Header Widget Tanpa Prefix Icon ─────────────────────────────
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
        // Progress bar 100% (terisi penuh untuk halaman kedua)
        Stack(
          children: [
            Container(
              height: 2.5,
              width: double.infinity,
              color: AppTheme.backgroundSecondary,
            ),
            FractionallySizedBox(
              widthFactor: 1.0,
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

  void _showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppTheme.backgroundSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppTheme.borderColor),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.celebration_rounded,
              color: AppTheme.progressColor,
            ),
            const SizedBox(width: 10),
            Text('Modul Selesai!', style: AppTextStyle.dialogTitle),
          ],
        ),
        content: Text(
          'Hebat! Anda telah menyelesaikan materi "1.2 Visualisasi Gelombang Harmonik". Riwayat belajar telah disimpan.',
          style: AppTextStyle.dialogText,
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pushReplacement(
                const BottomNavBarPhintar(initialIndex: 0),
              );
            },
            child: Text(
              'Kembali ke Menu',
              style: GoogleFonts.outfit(
                color: AppTheme.bottonColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
