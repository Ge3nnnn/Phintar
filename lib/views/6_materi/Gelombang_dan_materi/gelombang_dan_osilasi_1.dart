import 'dart:async';
import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:blabla/data/database/db_materi.dart';
import 'package:blabla/models/preference_handler.dart';
import 'package:blabla/widgets/app_button.dart';
import 'package:blabla/widgets/bottom_nav/bottom_nav_bar_phintar.dart';
import 'package:blabla/widgets/extention/navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

/// Page for the "Gelombang dan Osilasi" course module.
///
/// Displays introductory text and an embedded local video player
/// for "Osilasi: Ritme Alam" (assets/Videos/Osilasi__Ritme_Alam.mp4).
/// Records learning duration to the local database when the user
/// leaves or completes the module.
class Materi1Gelombang extends StatefulWidget {
  const Materi1Gelombang({super.key});

  @override
  State<Materi1Gelombang> createState() => _Materi1GelombangState();
}

/// Backward compatibility alias
typedef Materi1Gelombag = Materi1Gelombang;

class _Materi1GelombangState extends State<Materi1Gelombang> {
  // Waktu mulai belajar dicatat saat halaman dibuka
  final DateTime _startTime = DateTime.now();

  /// Saves how long the user spent on this page to the local SQLite
  /// database. Uses [materiId] = 1 for this specific materi page.
  /// Duration is calculated from [_startTime] to now.
  Future<void> _saveMateriHistory() async {
    final durationSeconds = DateTime.now().difference(_startTime).inSeconds;
    await DatabaseHelperMateri.instance.insertHistory(
      userEmail: PreferenceHandler.userEmail,
      materiId: 1,
      materiName: 'Gelombang Osilasi',
      durationSeconds: durationSeconds,
    );
  }

  /// Builds the page layout: top header with full progress bar,
  /// scrollable body with video player & materi text, and bottom action buttons.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Header ───────────────────────────────────────────────
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
                    const SizedBox(height: 16),

                    // ── Video Label / Badge ──────────────────────────────
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.progressColor.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppTheme.progressColor.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.play_circle_filled,
                                size: 14,
                                color: AppTheme.progressColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'VIDEO MATERI',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.progressColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Osilasi: Ritme Alam',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Video Player Card (assets/Videos/Osilasi__Ritme_Alam.mp4) ─
                    const AssetVideoPlayerCard(
                      assetPath: 'assets/Videos/Osilasi__Ritme_Alam.mp4',
                    ),
                    const SizedBox(height: 20),

                    // ── Penjelasan Materi ─────────────────────────────────
                    Text(
                      '''Kita mulai mempelajari osilasi dengan sistem sederhana pendulum dan pegas. Meskipun sistem ini mungkin terlihat sangat mendasar, konsep yang terlibat memiliki banyak aplikasi dalam kehidupan nyata.

Sebagai contoh, Gedung Comcast di Philadelphia, Pennsylvania, berdiri setinggi sekitar 305 meter (1000 kaki). Karena gedung dibangun semakin tinggi, gedung tersebut dapat bertindak sebagai pendulum fisik terbalik, dengan lantai atas berosilasi karena aktivitas seismik dan angin yang berfluktuasi.

Di Gedung Comcast, peredam massa tertala digunakan untuk mengurangi osilasi. Dipasang di puncak gedung adalah peredam massa kolom cairan tertala, yang terdiri dari reservoir air berkapasitas 300.000 galon. Tangki berbentuk U ini memungkinkan air berosilasi bebas pada frekuensi yang cocok dengan frekuensi alami gedung. Peredaman disediakan dengan menyetel tingkat turbulensi dalam air yang bergerak menggunakan sekat.''',
                      style: AppTextStyle.normalText2,
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 28),

                    // ── Tombol Kembali dan Selesai ───────────────────────
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

                        // ── Tombol SELESAI ─────────────────────────────────
                        Expanded(
                          child: CustomElevatedButton(
                            onPressed: () async {
                              await _saveMateriHistory();
                              if (!context.mounted) return;
                              _showCompletionDialog(context);
                            },
                            text: 'SELESAI',
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

  /// Builds the top header showing the course title and full progress bar.
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
        // Progress bar 100%
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

  /// Shows a celebratory dialog when the module is completed.
  void _showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppTheme.backgroundSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.borderColor),
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
          'Hebat! Anda telah menyelesaikan materi "Gelombang dan Osilasi". Riwayat belajar telah disimpan.',
          style: AppTextStyle.dialogText,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
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

/// Interactive video player card widget for local asset video files.
class AssetVideoPlayerCard extends StatefulWidget {
  final String assetPath;

  const AssetVideoPlayerCard({super.key, required this.assetPath});

  @override
  State<AssetVideoPlayerCard> createState() => _AssetVideoPlayerCardState();
}

class _AssetVideoPlayerCardState extends State<AssetVideoPlayerCard> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    setState(() {
      _hasError = false;
      _isInitialized = false;
    });

    try {
      _controller = VideoPlayerController.asset(widget.assetPath);
      await _controller.initialize();
      _controller.addListener(_videoListener);
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video asset: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  void _videoListener() {
    if (mounted) {
      setState(() {});
    }
  }

  void _togglePlayPause() {
    if (!_isInitialized) return;

    if (_controller.value.isPlaying) {
      _controller.pause();
      _showControlsTemporarily(stayVisible: true);
    } else {
      if (_controller.value.position >= _controller.value.duration) {
        _controller.seekTo(Duration.zero);
      }
      _controller.play();
      _showControlsTemporarily();
    }
  }

  void _showControlsTemporarily({bool stayVisible = false}) {
    _hideTimer?.cancel();
    setState(() {
      _showControls = true;
    });

    if (!stayVisible && _controller.value.isPlaying) {
      _hideTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && _controller.value.isPlaying) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  void _toggleMute() {
    if (!_isInitialized) return;
    final isMuted = _controller.value.volume == 0;
    _controller.setVolume(isMuted ? 1.0 : 0.0);
    _showControlsTemporarily();
  }

  Future<void> _openFullScreen() async {
    if (!_isInitialized) return;

    _hideTimer?.cancel();
    setState(() {
      _showControls = false;
    });

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenVideoPage(
          controller: _controller,
          title: 'Osilasi: Ritme Alam',
        ),
      ),
    );

    if (mounted) {
      setState(() {
        _showControls = true;
      });
      _showControlsTemporarily();
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_hasError) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: AppTheme.backgroundSecondary,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppTheme.merah, size: 40),
              const SizedBox(height: 8),
              Text(
                'Gagal memuat video',
                style: GoogleFonts.outfit(
                  color: AppTheme.textLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _initializePlayer,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.bottonColor,
                  foregroundColor: AppTheme.putih,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: AppTheme.backgroundSecondary,
          child: const Center(
            child: CircularProgressIndicator(color: AppTheme.progressColor),
          ),
        ),
      );
    }

    final isPlaying = _controller.value.isPlaying;
    final isCompleted =
        _controller.value.position >= _controller.value.duration;
    final isMuted = _controller.value.volume == 0;
    final position = _controller.value.position;
    final duration = _controller.value.duration;

    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio > 0
          ? _controller.value.aspectRatio
          : 16 / 9,
      child: GestureDetector(
        onTap: () {
          if (_showControls) {
            _togglePlayPause();
          } else {
            _showControlsTemporarily();
          }
        },
        onDoubleTap: _openFullScreen,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ── Video Frame ────────────────────────────────────────
            VideoPlayer(_controller),

            // ── Dark Gradient / Overlay when controls are visible ──
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.3),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
            ),

            // ── Center Play / Pause / Replay Button ────────────────
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: IgnorePointer(
                ignoring: !_showControls,
                child: InkWell(
                  onTap: _togglePlayPause,
                  borderRadius: BorderRadius.circular(32),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      isCompleted
                          ? Icons.replay
                          : (isPlaying ? Icons.pause : Icons.play_arrow),
                      color: AppTheme.putih,
                      size: 34,
                    ),
                  ),
                ),
              ),
            ),

            // ── Bottom Controls Bar ────────────────────────────────
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: IgnorePointer(
                ignoring: !_showControls,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Scrubbing Progress Bar
                        VideoProgressIndicator(
                          _controller,
                          allowScrubbing: true,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          colors: const VideoProgressColors(
                            playedColor: AppTheme.progressColor,
                            bufferedColor: Colors.white30,
                            backgroundColor: Colors.white12,
                          ),
                        ),
                        Row(
                          children: [
                            // Time Indicator
                            Text(
                              '${_formatDuration(position)} / ${_formatDuration(duration)}',
                              style: GoogleFonts.outfit(
                                color: AppTheme.textLight,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            // Mute/Unmute Button
                            IconButton(
                              onPressed: _toggleMute,
                              icon: Icon(
                                isMuted ? Icons.volume_off : Icons.volume_up,
                                color: AppTheme.putih,
                                size: 18,
                              ),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(4),
                              tooltip: isMuted ? 'Nyalakan Suara' : 'Bisukan',
                            ),
                            const SizedBox(width: 4),
                            // Fullscreen Button
                            IconButton(
                              onPressed: _openFullScreen,
                              icon: const Icon(
                                Icons.fullscreen_rounded,
                                color: AppTheme.putih,
                                size: 22,
                              ),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(4),
                              tooltip: 'Layar Penuh',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dedicated full-screen video page with landscape orientation,
/// cinema styling, and comprehensive overlay controls.
class FullScreenVideoPage extends StatefulWidget {
  final VideoPlayerController controller;
  final String title;

  const FullScreenVideoPage({
    super.key,
    required this.controller,
    required this.title,
  });

  @override
  State<FullScreenVideoPage> createState() => _FullScreenVideoPageState();
}

class _FullScreenVideoPageState extends State<FullScreenVideoPage> {
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_videoListener);
    // Lock to landscape & immersive sticky UI
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _startHideTimer();
  }

  void _videoListener() {
    if (mounted) {
      setState(() {});
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    if (widget.controller.value.isPlaying) {
      _hideTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && widget.controller.value.isPlaying) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  void _showControlsTemporarily({bool stayVisible = false}) {
    _hideTimer?.cancel();
    setState(() {
      _showControls = true;
    });

    if (!stayVisible && widget.controller.value.isPlaying) {
      _startHideTimer();
    }
  }

  void _togglePlayPause() {
    if (widget.controller.value.isPlaying) {
      widget.controller.pause();
      _showControlsTemporarily(stayVisible: true);
    } else {
      if (widget.controller.value.position >=
          widget.controller.value.duration) {
        widget.controller.seekTo(Duration.zero);
      }
      widget.controller.play();
      _showControlsTemporarily();
    }
  }

  void _seekRelative(int seconds) {
    final currentPos = widget.controller.value.position;
    final target = currentPos + Duration(seconds: seconds);
    final maxDuration = widget.controller.value.duration;
    if (target < Duration.zero) {
      widget.controller.seekTo(Duration.zero);
    } else if (target > maxDuration) {
      widget.controller.seekTo(maxDuration);
    } else {
      widget.controller.seekTo(target);
    }
    _showControlsTemporarily();
  }

  void _toggleMute() {
    final isMuted = widget.controller.value.volume == 0;
    widget.controller.setVolume(isMuted ? 1.0 : 0.0);
    _showControlsTemporarily();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    widget.controller.removeListener(_videoListener);
    // Restore portrait orientation & default edge-to-edge UI
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = widget.controller.value.isPlaying;
    final isCompleted =
        widget.controller.value.position >= widget.controller.value.duration;
    final isMuted = widget.controller.value.volume == 0;
    final position = widget.controller.value.position;
    final duration = widget.controller.value.duration;

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: GestureDetector(
            onTap: () {
              if (_showControls) {
                _togglePlayPause();
              } else {
                _showControlsTemporarily();
              }
            },
            onDoubleTap: () {
              Navigator.of(context).pop();
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ── Centered Video Player ──────────────────────────────
                Center(
                  child: AspectRatio(
                    aspectRatio: widget.controller.value.aspectRatio > 0
                        ? widget.controller.value.aspectRatio
                        : 16 / 9,
                    child: VideoPlayer(widget.controller),
                  ),
                ),

                // ── Controls Gradient Overlay ──────────────────────────
                AnimatedOpacity(
                  opacity: _showControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Top Bar (Back button & Video Title) ────────────────
                AnimatedOpacity(
                  opacity: _showControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: IgnorePointer(
                    ignoring: !_showControls,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              tooltip: 'Keluar Layar Penuh',
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.title,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Center Controls (-10s, Play/Pause, +10s) ───────────
                AnimatedOpacity(
                  opacity: _showControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: IgnorePointer(
                    ignoring: !_showControls,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Rewind 10s
                        IconButton(
                          onPressed: () => _seekRelative(-10),
                          icon: const Icon(
                            Icons.replay_10_rounded,
                            color: Colors.white,
                            size: 38,
                          ),
                          tooltip: 'Mundur 10 detik',
                        ),
                        const SizedBox(width: 32),
                        // Play/Pause button
                        InkWell(
                          onTap: _togglePlayPause,
                          borderRadius: BorderRadius.circular(36),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.35),
                                width: 2.0,
                              ),
                            ),
                            child: Icon(
                              isCompleted
                                  ? Icons.replay_rounded
                                  : (isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded),
                              color: Colors.white,
                              size: 42,
                            ),
                          ),
                        ),
                        const SizedBox(width: 32),
                        // Forward 10s
                        IconButton(
                          onPressed: () => _seekRelative(10),
                          icon: const Icon(
                            Icons.forward_10_rounded,
                            color: Colors.white,
                            size: 38,
                          ),
                          tooltip: 'Maju 10 detik',
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Bottom Bar (Progress, Time, Mute, Exit Fullscreen) ─
                AnimatedOpacity(
                  opacity: _showControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: IgnorePointer(
                    ignoring: !_showControls,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 12.0,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Progress bar
                            VideoProgressIndicator(
                              widget.controller,
                              allowScrubbing: true,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              colors: const VideoProgressColors(
                                playedColor: AppTheme.progressColor,
                                bufferedColor: Colors.white30,
                                backgroundColor: Colors.white12,
                              ),
                            ),
                            Row(
                              children: [
                                // Time
                                Text(
                                  '${_formatDuration(position)} / ${_formatDuration(duration)}',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                // Mute button
                                IconButton(
                                  onPressed: _toggleMute,
                                  icon: Icon(
                                    isMuted
                                        ? Icons.volume_off_rounded
                                        : Icons.volume_up_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  tooltip: isMuted
                                      ? 'Nyalakan Suara'
                                      : 'Bisukan',
                                ),
                                const SizedBox(width: 8),
                                // Exit Fullscreen button
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(
                                    Icons.fullscreen_exit_rounded,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                  tooltip: 'Keluar Layar Penuh',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
