import 'dart:async';
import 'dart:math';
import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:blabla/widgets/app_bar.dart';
import 'package:flutter/material.dart';

class LaboOsilasi extends StatefulWidget {
  const LaboOsilasi({super.key});

  @override
  State<LaboOsilasi> createState() => _LaboOsilasiState();
}

// ── Data Tempat Percobaan (Gravitasi per Lokasi) ──────────────────────────────
class _TempatPercobaan {
  final String nama;
  final String emoji;
  final double gravitasi; // m/s²
  final double b; // koefisien hambatan udara (kg/s); 0 = tanpa atmosfer
  final String atmosfer; // deskripsi singkat atmosfer
  const _TempatPercobaan(
    this.nama,
    this.emoji,
    this.gravitasi,
    this.b,
    this.atmosfer,
  );
}

// Referensi b (kg/s) = koefisien gesekan linear bandul di atmosfer setempat
// Bumi: 0.5 (atmosfer standar) • Venus: ~2.5 (90× lebih padat dari Bumi)
// Mars: ~0.04 (1% atmosfer Bumi) • Jupiter/Saturnus: sangat tebal
const List<_TempatPercobaan> _daftarTempat = [
  _TempatPercobaan('Bumi', '🌍', 9.81, 0.50, 'Atmosfer standar (N₂/O₂)'),
  _TempatPercobaan('Bulan', '🌑', 1.62, 0.00, 'Tanpa atmosfer'),
  _TempatPercobaan(
    'Matahari',
    '☀️',
    274.0,
    0.00,
    'Plasma (bukan atmosfer biasa)',
  ),
  _TempatPercobaan('Merkurius', '🩺', 3.70, 0.001, 'Eksosfer sangat tipis'),
  _TempatPercobaan('Venus', '🟡', 8.87, 2.50, 'Atmosfer sangat padat (CO₂)'),
  _TempatPercobaan('Mars', '🔴', 3.72, 0.04, 'Atmosfer tipis (CO₂ 1%)'),
  _TempatPercobaan('Jupiter', '🟠', 24.79, 3.20, 'Atmosfer tebal (H₂/He)'),
  _TempatPercobaan('Saturnus', '🪐', 10.44, 1.80, 'Atmosfer tebal (H₂/He)'),
  _TempatPercobaan('Uranus', '⚪', 8.69, 0.90, 'Atmosfer es & gas'),
  _TempatPercobaan('Neptunus', '🔵', 11.15, 1.10, 'Atmosfer tebal & berangin'),
  _TempatPercobaan('Pluto', '😒', 0.62, 0.001, 'Eksosfer N₂ sangat tipis'),
];

class _LaboOsilasiState extends State<LaboOsilasi>
    with TickerProviderStateMixin {
  // ── Parameter kontrol ──────────────────────────────────────────────────────
  double _sudut = 30; // derajat
  double _panjangTali = 1.0; // meter
  double _massaBandul = 1.0; // kg

  // ── Hambatan Udara ──────────────────────────────────────────────────────
  bool _hambatanUdara = false;
  // b diambil dari planet aktif; 0 jika tidak ada atmosfer atau switch OFF
  // γ = b/(2m) — koefisien redaman spesifik
  double get _gamma =>
      _hambatanUdara ? (_tempatPercobaan.b / (2 * _massaBandul)) : 0.0;
  // Apakah lokasi ini punya atmosfer yang berarti?
  bool get _adaAtmosfer => _tempatPercobaan.b > 0.0; // kg

  // ── Tempat Percobaan & Gravitasi ──────────────────────────────────────────
  _TempatPercobaan _tempatPercobaan = _daftarTempat[0]; // default: Bumi
  double get _gravitasi => _tempatPercobaan.gravitasi;

  // ── State simulasi ─────────────────────────────────────────────────────────
  bool _isRunning = false;
  late AnimationController _animController;
  late Animation<double> _pendulumAnim;

  // Sudut terakhir saat pause (agar bandul tidak kembali ke posisi awal)
  double _pausedAngle = 0.0;


  // ── Stopwatch ──────────────────────────────────────────────────────────────
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _stopwatchTimer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (_periode * 1000).round()),
    );
    _updateAnimationConfig();
  }

  /// Hitung periode berdasarkan panjang tali (T = 2π√(L/g))
  double get _periode => 2 * pi * sqrt(_panjangTali / _gravitasi);

  void _updateAnimationConfig() {
    _animController.duration = Duration(
      milliseconds: (_periode * 1000).round(),
    );
    _pendulumAnim =
        Tween<double>(
          begin: -_sudut * pi / 180,
          end: _sudut * pi / 180,
        ).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
        );
    if (_isRunning) {
      _animController.repeat(reverse: true);
    }
  }

  void _toggleSimulasi() {
    if (_isRunning) {
      // ── PAUSE ──
      _pausedAngle = _pendulumAnim.value;
      _animController.stop();
      _stopwatch.stop();
      _stopwatchTimer?.cancel();
    } else {
      // ── MULAI / RESUME ──
      _animController.repeat(reverse: true);
      _stopwatch.start();
      _stopwatchTimer = Timer.periodic(
        const Duration(milliseconds: 100),
        (_) => setState(() => _elapsed = _stopwatch.elapsed),
      );
    }
    setState(() => _isRunning = !_isRunning);
  }

  void _reset() {
    _animController.stop();
    _animController.reset();
    _stopwatchTimer?.cancel();
    _stopwatch.reset();

    setState(() {
      _isRunning = false;
      _pausedAngle = 0.0;
      _elapsed = Duration.zero;
      _tempatPercobaan = _daftarTempat[0];
      _sudut = 30;
      _panjangTali = 1.0;
      _massaBandul = 1.0;
      _updateAnimationConfig();
    });
  }

  /// Format Duration → mm:ss.d
  String _formatElapsed(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final ds = (d.inMilliseconds.remainder(1000) ~/ 100).toString();
    return '$mm:$ss.$ds';
  }

  @override
  void dispose() {
    _stopwatchTimer?.cancel();
    _stopwatch.stop();
    _animController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: CustomAppBar2(
        title: "Laboratorium: Bandul Matematis",
        prefixIcon: Icons.arrow_back,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPanduanCard(),
            const SizedBox(height: 14),
            _buildVisualisasiCard(),
            const SizedBox(height: 14),
            _kondisiEksperimenCard(),
            const SizedBox(height: 14),
            _buildKontrolCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Kartu Visualisasi ─────────────────────────────────────────────────────
  Widget _buildVisualisasiCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.monitor, color: AppTheme.bottonColor, size: 18),
              const SizedBox(width: 8),
              Text(
                'Visualisasi Osilasi Terintegrasi',
                style: AppTextStyle.normalText.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.putih,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Visualisasi bandul
          _buildPendulumCanvas(),
          const SizedBox(height: 16),

          // Tombol Reset | Stopwatch | Mulai
          Row(
            children: [
              // ── Tombol Reset ───────────────────────────────────────────────
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(
                    Icons.refresh,
                    color: AppTheme.putih,
                    size: 16,
                  ),
                  label: Text(
                    'RESET',
                    style: AppTextStyle.botttonText,
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.textColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // ── Stopwatch Display ──────────────────────────────────────────
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundPrimary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isRunning
                          ? AppTheme.progressColor.withValues(alpha: 0.5)
                          : AppTheme.textColor,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: _isRunning
                            ? AppTheme.progressColor
                            : AppTheme.textColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatElapsed(_elapsed),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _isRunning
                              ? AppTheme.progressColor
                              : AppTheme.textColor,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // ── Tombol Mulai / Pause ───────────────────────────────────────
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _toggleSimulasi,
                  icon: Icon(
                    _isRunning ? Icons.pause : Icons.play_arrow,
                    size: 18,
                  ),
                  label: Text(
                    _isRunning ? 'PAUSE' : 'MULAI',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.bottonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Kanvas Bandul ─────────────────────────────────────────────────────────
  // Tinggi kanvas: 100px (L=0.1m) → 220px (L=3.0m), linear
  double get _canvasHeight {
    const minH = 100.0;
    const maxH = 220.0;
    const minL = 0.1;
    const maxL = 3.0;
    return minH + (_panjangTali - minL) / (maxL - minL) * (maxH - minH);
  }

  Widget _buildPendulumCanvas() {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        // Saat running: ikuti animasi
        // Saat pause setelah pernah jalan: tetap di posisi terakhir (_pausedAngle)
        // Saat belum pernah jalan: posisi awal berdasarkan sudut slider
        final angle = _isRunning
            ? _pendulumAnim.value
            : (_animController.value > 0 ? _pausedAngle : -_sudut * pi / 180);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          height: _canvasHeight,
          decoration: BoxDecoration(
            color: AppTheme.backgroundPrimary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomPaint(
            painter: _PendulumPainter(
              angle: angle,
              ropeLengthM: _panjangTali,
              massaKg: _massaBandul,
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }

  // ── Kartu Monitoring (Kondisi Eksperimen) ─────────────────────────────────
  Widget _kondisiEksperimenCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.science_outlined,
                color: AppTheme.bottonColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'KONDISI EKSPERIMEN',
                style: AppTextStyle.normalText.copyWith(
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.putih,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: AppTheme.textColor, height: 1),
          const SizedBox(height: 10),

          // ── Dropdown Tempat Percobaan ──────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tempat Percobaan', style: AppTextStyle.normalText),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundPrimary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.progressColor.withValues(alpha: 0.4),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<_TempatPercobaan>(
                    value: _tempatPercobaan,
                    dropdownColor: AppTheme.backgroundPrimary,
                    isDense: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppTheme.progressColor,
                      size: 18,
                    ),
                    style: AppTextStyle.normalText.copyWith(
                      color: AppTheme.progressColor,
                      fontWeight: FontWeight.bold,
                    ),
                    onChanged: _isRunning
                        ? null // kunci saat sedang berjalan
                        : (val) {
                            if (val != null) {
                              setState(() => _tempatPercobaan = val);
                              _updateAnimationConfig();
                            }
                          },
                    items: _daftarTempat.map((t) {
                      return DropdownMenuItem<_TempatPercobaan>(
                        value: t,
                        child: Text(
                          '${t.emoji}  ${t.nama}',
                          style: AppTextStyle.normalText.copyWith(
                            color: AppTheme.putih,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),

          // // Nilai g aktual (kecil, di bawah dropdown)
          // Padding(
          //   padding: const EdgeInsets.only(top: 2, bottom: 6),
          //   child: Align(
          //     alignment: Alignment.centerRight,
          //     child: Text(
          //       'g = ${_gravitasi.toStringAsFixed(2)} m/s²',
          //       style: AppTextStyle.normalText.copyWith(
          //         fontSize: 10,
          //         color: AppTheme.textColor,
          //       ),
          //     ),
          //   ),
          // ),
          const SizedBox(height: 6),
          const Divider(color: AppTheme.textColor, height: 1, thickness: 0.3),
          const SizedBox(height: 6),

          _monitorRow(
            'Panjang Tali (L)',
            '${_panjangTali.toStringAsFixed(2)} m',
          ),
          _monitorRow(
            'Massa Bandul (m)',
            '${_massaBandul.toStringAsFixed(2)} kg',
          ),
          _monitorRow('Sudut Simpangan (θ)', '${_sudut.toStringAsFixed(1)}°'),
          // ── Switch Hambatan Udara ──────────────────────────────────────────
          const Divider(color: AppTheme.textColor, height: 1, thickness: 0.3),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _adaAtmosfer
                              ? Icons.air_outlined
                              : Icons.do_not_disturb_alt_outlined,
                          size: 16,
                          color: _adaAtmosfer
                              ? AppTheme.bottonColor
                              : AppTheme.merah,
                        ),
                        const SizedBox(width: 6),
                        Text('Hambatan Udara', style: AppTextStyle.normalText),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _tempatPercobaan.atmosfer,
                      style: AppTextStyle.normalText.copyWith(
                        fontSize: 10,
                        color: AppTheme.textColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    if (_hambatanUdara && _adaAtmosfer)
                      Text(
                        'b = ${_tempatPercobaan.b} kg/s  •  γ = ${_gamma.toStringAsFixed(3)} s⁻¹',
                        style: AppTextStyle.normalText.copyWith(
                          fontSize: 10,
                          color: AppTheme.progressColor,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else if (_hambatanUdara && !_adaAtmosfer)
                      Text(
                        'Tidak berpengaruh — tidak ada atmosfer',
                        style: AppTextStyle.normalText.copyWith(
                          fontSize: 10,
                          color: AppTheme.merah,
                        ),
                      ),
                  ],
                ),
              ),
              Switch(
                value: _hambatanUdara,
                onChanged: (v) => setState(() => _hambatanUdara = v),
                activeThumbColor: _adaAtmosfer
                    ? AppTheme.progressColor
                    : AppTheme.merah,
                activeTrackColor:
                    (_adaAtmosfer ? AppTheme.progressColor : AppTheme.merah)
                        .withValues(alpha: 0.3),
                inactiveThumbColor: AppTheme.textColor,
                inactiveTrackColor: AppTheme.textColor.withValues(alpha: 0.2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _monitorRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyle.normalText),
          Text(
            value,
            style: AppTextStyle.normalText.copyWith(
              color: AppTheme.progressColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ── Kartu Kontrol Parameter ───────────────────────────────────────────────
  Widget _buildKontrolCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune, color: AppTheme.bottonColor, size: 18),
              const SizedBox(width: 8),
              Text(
                'KONTROL PARAMETER',
                style: AppTextStyle.normalText2.copyWith(
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.putih,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSlider(
            label: 'Sudut Simpangan (θ)',
            value: _sudut,
            min: 0,
            max: 80,
            unit: '°',
            onChanged: (v) {
              setState(() => _sudut = v);
              _updateAnimationConfig();
            },
          ),
          _buildSlider(
            label: 'Panjang Tali (L)',
            value: _panjangTali,
            min: 0.1,
            max: 3.0,
            unit: ' m',
            onChanged: (v) {
              setState(() => _panjangTali = v);
              _updateAnimationConfig();
            },
          ),
          _buildSlider(
            label: 'Massa Bandul (m)',
            value: _massaBandul,
            min: 0.1,
            max: 5.0,
            unit: ' kg',
            onChanged: (v) => setState(() => _massaBandul = v),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String unit,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyle.normalText),
            Text(
              '${value.toStringAsFixed(1)}$unit',
              style: AppTextStyle.normalText.copyWith(
                color: AppTheme.progressColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.progressColor,
            inactiveTrackColor: AppTheme.textColor.withValues(alpha: 0.3),
            thumbColor: AppTheme.progressColor,
            overlayColor: AppTheme.progressColor.withValues(alpha: 0.15),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            trackHeight: 3,
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }

  // ── Kartu Panduan ─────────────────────────────────────────────────────────
  Widget _buildPanduanCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Panduan Eksperimen',
            style: AppTextStyle.subjudul.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 10),
          Text(
            'Simulator ini mengintegrasikan mekanika bandul dengan representasi '
            'gelombang sinusoidal. Amati bagaimana perubahan Panjang Tali (L) secara '
            'langsung mempengaruhi periode ayunan dan frekuensi gelombang yang '
            'dihasilkan. Dalam kondisi ideal, perhatikan bahwa Massa (m) tidak '
            'mengubah periode sistem.',
            style: AppTextStyle.normalText.copyWith(
              color: AppTheme.putih,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          // Tombol unduh template
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundPrimary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.textColor.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.progressColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: AppTheme.progressColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Data_Lab.pdf',
                        style: AppTextStyle.normalText.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Unduh Template',
                        style: AppTextStyle.normalText.copyWith(
                          fontSize: 11,
                          color: AppTheme.textColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CustomPainter: Bandul
// ═══════════════════════════════════════════════════════════════════════════════
class _PendulumPainter extends CustomPainter {
  final double angle; // radian
  final double ropeLengthM; // meter (0.1 – 3.0)
  final double massaKg; // kg    (0.1 – 5.0)

  _PendulumPainter({
    required this.angle,
    this.ropeLengthM = 1.0,
    this.massaKg = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pivotX = size.width / 2;
    const pivotY = 12.0;

    // Panjang tali visual: 30% – 85% tinggi kanvas
    const minFrac = 0.30;
    const maxFrac = 0.85;
    const minL = 0.1;
    const maxL = 3.0;
    final fraction =
        minFrac + (ropeLengthM - minL) / (maxL - minL) * (maxFrac - minFrac);
    final ropeLength = size.height * fraction.clamp(minFrac, maxFrac);

    // Radius bola: 8 – 22 px sesuai massa
    const minR = 8.0;
    const maxR = 22.0;
    const minM = 0.1;
    const maxM = 5.0;
    final bobRadius = (minR + (massaKg - minM) / (maxM - minM) * (maxR - minR))
        .clamp(minR, maxR);

    final bobX = pivotX + ropeLength * sin(angle);
    final bobY = pivotY + ropeLength * cos(angle);

    // ── Garis keseimbangan (vertikal putus-putus) ───────────────────────────
    final dashPaint = Paint()
      ..color = AppTheme.textColor
      ..strokeWidth = 1;
    double y = pivotY;
    while (y < pivotY + ropeLength + bobRadius) {
      canvas.drawLine(Offset(pivotX, y), Offset(pivotX, y + 5), dashPaint);
      y += 10;
    }

    // ── Garis tali ──────────────────────────────────────────────────────────
    final ropePaint = Paint()
      ..color = AppTheme.putih
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(pivotX, pivotY), Offset(bobX, bobY), ropePaint);

    // ── Label panjang tali ───────────────────────────────────────────────────
    _drawText(
      canvas,
      '${ropeLengthM.toStringAsFixed(1)} m',
      Offset(pivotX + 6, pivotY + ropeLength / 2 - 6),
      TextStyle(
        color: AppTheme.textColor,
        fontSize: 9,
        fontWeight: FontWeight.w500,
      ),
    );

    // ── Titik pivot ─────────────────────────────────────────────────────────
    final pivotPaint = Paint()..color = AppTheme.textColor;
    canvas.drawCircle(Offset(pivotX, pivotY), 4, pivotPaint);

    // ── Glow bola ───────────────────────────────────────────────────────────
    final glowPaint = Paint()
      ..color = const Color(0xFF3B82F6).withValues(alpha: 0.25)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, bobRadius * 0.5);
    canvas.drawCircle(Offset(bobX, bobY), bobRadius * 1.3, glowPaint);

    // ── Bola bandul dengan gradient ─────────────────────────────────────────
    final bobGrad = Paint()
      ..shader =
          RadialGradient(
            center: const Alignment(-0.3, -0.3),
            colors: [AppTheme.putih, AppTheme.ballColor],
          ).createShader(
            Rect.fromCircle(center: Offset(bobX, bobY), radius: bobRadius),
          );
    canvas.drawCircle(Offset(bobX, bobY), bobRadius, bobGrad);

    // ── Label massa di dalam bola (jika cukup besar) ─────────────────────────
    if (bobRadius >= 12) {
      _drawText(
        canvas,
        '${massaKg.toStringAsFixed(1)}kg',
        Offset(bobX - bobRadius * 0.6, bobY - 5),
        TextStyle(
          color: AppTheme.putih,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_PendulumPainter old) =>
      old.angle != angle ||
      old.ropeLengthM != ropeLengthM ||
      old.massaKg != massaKg;
}
