import 'dart:math';
import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:blabla/constants/appbar.dart';
import 'package:flutter/material.dart';

class LaboOsilasi extends StatefulWidget {
  const LaboOsilasi({super.key});

  @override
  State<LaboOsilasi> createState() => _LaboOsilasiState();
}

class _LaboOsilasiState extends State<LaboOsilasi>
    with TickerProviderStateMixin {
  // ── Parameter kontrol ──────────────────────────────────────────────────────
  double _sudut = 30; // derajat
  double _panjangTali = 1.0; // meter
  double _massaBandul = 1.0; // kg
  double _skalaGrafik = 1.0; // amplitudo

  // ── State simulasi ─────────────────────────────────────────────────────────
  bool _isRunning = false;
  late AnimationController _animController;
  late Animation<double> _pendulumAnim;

  // Osilogram — buffer titik gelombang sinus
  final List<double> _waveBuffer = List.filled(120, 0.0);

  // Controller kedua khusus osilogram — accumulate phase tiap frame
  late AnimationController _waveController;
  double _phase = 0.0; // radian, terus bertambah

  @override
  void initState() {
    super.initState();

    // Bandul
    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (_periode * 1000).round()),
    );
    _updateAnimationConfig();

    // Osilogram: controller cepat (16ms ≈ 60fps) yang berjalan repeat
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    );
    _waveController.addListener(_onWaveTick);
  }

  /// Hitung periode berdasarkan panjang tali (T = 2π√(L/g))
  double get _periode => 2 * pi * sqrt(_panjangTali / 9.81);
  double get _frekuensi => 1 / _periode;
  double get _panjangGelombang => _frekuensi > 0 ? 1 / _frekuensi * 2 : 0;

  /// Update konfigurasi animasi bandul
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

  /// Listener osilogram — dipanggil tiap kali _waveController tick
  void _onWaveTick() {
    // Setiap tick: tambah fase proporsional terhadap frekuensi
    // dt ≈ 16ms = 0.016 detik
    const dt = 0.016;
    _phase += 2 * pi * _frekuensi * dt;

    setState(() {
      _waveBuffer.removeAt(0);
      _waveBuffer.add(sin(_phase) * _skalaGrafik);
    });
  }

  void _toggleSimulasi() {
    setState(() {
      _isRunning = !_isRunning;
    });
    if (_isRunning) {
      _animController.repeat(reverse: true);
      _waveController.repeat(); // mulai osilogram
    } else {
      _animController.stop();
      _waveController.stop(); // pause osilogram
    }
  }

  void _reset() {
    // Stop dulu di luar setState
    _animController.stop();
    _animController.reset();
    _waveController.stop();
    _waveController.reset();

    setState(() {
      _isRunning = false;
      _phase = 0.0;

      // Kosongkan buffer
      for (int i = 0; i < _waveBuffer.length; i++) {
        _waveBuffer[i] = 0;
      }

      // Reset semua parameter ke nilai minimum
      _sudut = 5;
      _panjangTali = 0.1;
      _massaBandul = 0.1;
      _skalaGrafik = 1.0;
      _updateAnimationConfig();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: CustomAppBar2(
        title: "Laboratorium: Gelombang & Osilasi",
        prefixIcon: Icons.arrow_back,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVisualisasiCard(),
            const SizedBox(height: 14),
            _buildMonitoringCard(),
            const SizedBox(height: 14),
            _buildKontrolCard(),
            const SizedBox(height: 14),
            _buildPanduanCard(),
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
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Label domain ruang
          _labelDomain('DOMAIN RUANG (BANDUL)'),
          const SizedBox(height: 8),

          // Visualisasi bandul
          _buildPendulumCanvas(),
          const SizedBox(height: 14),

          // Label domain waktu
          _labelDomain('DOMAIN WAKTU (OSILOGRAM)'),
          const SizedBox(height: 8),

          // Visualisasi osilogram
          _buildOsilogramCanvas(),
          const SizedBox(height: 16),

          // Tombol Reset & Mulai
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white70,
                    size: 16,
                  ),
                  label: const Text(
                    'RESET',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
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

  Widget _labelDomain(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        color: AppTheme.textColor,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
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
      builder: (_, _) {
        final angle = _isRunning ? _pendulumAnim.value : -_sudut * pi / 180;
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
              ropeLengthM: _panjangTali, // 0.1 – 3.0 m
              massaKg: _massaBandul, // 0.1 – 5.0 kg
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }

  // ── Kanvas Osilogram ──────────────────────────────────────────────────────
  Widget _buildOsilogramCanvas() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppTheme.backgroundPrimary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        painter: _OsilogramPainter(
          waveData: List.from(_waveBuffer),
          color: AppTheme.progressColor,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }

  // ── Kartu Monitoring ──────────────────────────────────────────────────────
  Widget _buildMonitoringCard() {
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
              const Icon(
                Icons.bar_chart_rounded,
                color: AppTheme.bottonColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'MONITORING DATA',
                style: AppTextStyle.normalText.copyWith(
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: AppTheme.textColor, height: 1),
          const SizedBox(height: 10),
          _monitorRow('Periode (T)', '${_periode.toStringAsFixed(2)} s'),
          _monitorRow('Frekuensi (f)', '${_frekuensi.toStringAsFixed(2)} Hz'),
          _monitorRow(
            'Panjang Gelombang (λ)',
            '${_panjangGelombang.toStringAsFixed(2)} m',
          ),
          _monitorRow('Gravitasi (g)', '9.81 m/s²'),
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
                style: AppTextStyle.normalText.copyWith(
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSlider(
            label: 'Sudut Simpangan (θ)',
            value: _sudut,
            min: 5,
            max: 60,
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
          _buildSlider(
            label: 'Skala Grafik (Amplitudo)',
            value: _skalaGrafik,
            min: 0.1,
            max: 3.0,
            unit: 'x',
            onChanged: (v) => setState(() => _skalaGrafik = v),
          ),
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
            'Panduan Eksperimen Terpadu',
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
              color: Colors.white70,
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
      ..color = Colors.white12
      ..strokeWidth = 1;
    double y = pivotY;
    while (y < pivotY + ropeLength + bobRadius) {
      canvas.drawLine(Offset(pivotX, y), Offset(pivotX, y + 5), dashPaint);
      y += 10;
    }

    // ── Garis tali ──────────────────────────────────────────────────────────
    final ropePaint = Paint()
      ..color = Colors.white38
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(pivotX, pivotY), Offset(bobX, bobY), ropePaint);

    // ── Label panjang tali ───────────────────────────────────────────────────
    _drawText(
      canvas,
      '${ropeLengthM.toStringAsFixed(1)} m',
      Offset(pivotX + 6, pivotY + ropeLength / 2 - 6),
      const TextStyle(
        color: Colors.white38,
        fontSize: 9,
        fontWeight: FontWeight.w500,
      ),
    );

    // ── Titik pivot ─────────────────────────────────────────────────────────
    final pivotPaint = Paint()..color = Colors.white54;
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
            colors: [const Color(0xFFBAE6FD), const Color(0xFF1D4ED8)],
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
        const TextStyle(
          color: Colors.white70,
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

// ═══════════════════════════════════════════════════════════════════════════════
// CustomPainter: Osilogram (gelombang sinus)
// ═══════════════════════════════════════════════════════════════════════════════
class _OsilogramPainter extends CustomPainter {
  final List<double> waveData;
  final Color color;

  _OsilogramPainter({required this.waveData, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (waveData.isEmpty) return;

    final midY = size.height / 2;
    final amplitude = size.height * 0.38;
    final stepX = size.width / (waveData.length - 1);

    // Grid garis tengah
    final gridPaint = Paint()
      ..color = Colors.white10
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, midY), Offset(size.width, midY), gridPaint);

    // Kurva gelombang
    final wavePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    for (int i = 0; i < waveData.length; i++) {
      final x = i * stepX;
      final y = midY - waveData[i] * amplitude;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, wavePaint);

    // Glow effect
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(_OsilogramPainter old) => old.waveData != waveData;
}
