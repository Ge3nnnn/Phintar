import 'dart:async';
import 'dart:math';

import 'package:blabla/constants/app_theme.dart';
import 'package:blabla/constants/app_typografy.dart';
import 'package:blabla/data/models/lab_model.dart';
import 'package:blabla/views/5_features/lab_page/simulations/sim_registry.dart';
import 'package:blabla/widgets/app_bar.dart';
import 'package:flutter/material.dart';

/// Dynamic lab simulation screen — the SINGLE template for ALL labs.
///
/// Receives a [LabModel] and dynamically builds:
/// - Guide card from [lab.guideText]
/// - Simulation canvas via [SimRegistry] using [lab.simType]
/// - Parameter sliders from [lab.parameters]
/// - Environment selector from [lab.environments]
///
/// Usage:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => LabSimulationScreen(lab: someLabModel),
/// ));
/// ```
class LabSimulationScreen extends StatefulWidget {
  final LabModel lab;

  const LabSimulationScreen({super.key, required this.lab});

  @override
  State<LabSimulationScreen> createState() => _LabSimulationScreenState();
}

class _LabSimulationScreenState extends State<LabSimulationScreen>
    with SingleTickerProviderStateMixin {
  // ── Current parameter values ──────────────────────────────────────────────
  late Map<String, double> _paramValues;

  // ── Simulation state ──────────────────────────────────────────────────────
  bool _isRunning = false;
  bool _airResistance = false;
  int _selectedEnvIndex = 0;
  late AnimationController _animController;

  // ── Stopwatch ─────────────────────────────────────────────────────────────
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _stopwatchTimer;
  final ValueNotifier<Duration> _elapsedNotifier =
      ValueNotifier<Duration>(Duration.zero);

  @override
  void initState() {
    super.initState();
    // Initialize slider values from database parameter defaults
    _paramValues = {
      for (final p in widget.lab.parameters) p.key: p.defaultValue,
    };

    _animController = AnimationController(
      vsync: this,
      duration: Duration(microseconds: ((_periode / 2) * 1000000).round()),
    );
    _animController.addStatusListener((status) {
      if (!_isRunning) return;
      if (status == AnimationStatus.completed) {
        _animController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animController.forward();
      }
    });
  }

  // ── Physics calculations (generic pendulum, extensible) ───────────────────
  LabEnvironment get _currentEnv =>
      widget.lab.environments.isNotEmpty &&
              _selectedEnvIndex < widget.lab.environments.length
          ? widget.lab.environments[_selectedEnvIndex]
          : const LabEnvironment(
              name: 'Bumi',
              emoji: '🌍',
              gravity: 9.81,
              drag: 0.5,
              atmosphere: 'Default',
            );

  double get _gravity => _currentEnv.gravity;
  double get _ropeLength => _paramValues['ropeLength'] ?? 1.0;
  double get _mass => _paramValues['mass'] ?? 1.0;
  double get _angle => _paramValues['angle'] ?? 30.0;

  /// Period for pendulum: T = 2π√(L/g)
  double get _periode => 2 * pi * sqrt(_ropeLength / _gravity);

  double get _gamma =>
      _airResistance ? (_currentEnv.drag / (2 * _mass)) : 0.0;
  bool get _hasAtmosphere => _currentEnv.drag > 0.0;

  void _updateAnimationConfig() {
    _animController.duration = Duration(
      microseconds: ((_periode / 2) * 1000000).round(),
    );
  }

  void _toggleSimulation() {
    if (_isRunning) {
      _animController.stop();
      _stopwatch.stop();
      _stopwatchTimer?.cancel();
    } else {
      _stopwatch.start();
      _stopwatchTimer = Timer.periodic(
        const Duration(milliseconds: 100),
        (_) => _elapsedNotifier.value = _stopwatch.elapsed,
      );
      if (_animController.status == AnimationStatus.reverse) {
        _animController.reverse();
      } else {
        _animController.forward();
      }
    }
    setState(() => _isRunning = !_isRunning);
  }

  void _reset() {
    _animController.stop();
    _animController.reset();
    _stopwatchTimer?.cancel();
    _stopwatch.reset();
    _elapsedNotifier.value = Duration.zero;

    setState(() {
      _isRunning = false;
      _airResistance = false;
      _selectedEnvIndex = 0;
      // Reset all parameter values to defaults
      _paramValues = {
        for (final p in widget.lab.parameters) p.key: p.defaultValue,
      };
      _updateAnimationConfig();
    });
  }

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
    _elapsedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: CustomAppBar2(
        title: "Lab: ${widget.lab.title}",
        prefixIcon: Icons.arrow_back,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Guide Card ───────────────────────────────────────────
            if (widget.lab.guideText != null &&
                widget.lab.guideText!.isNotEmpty)
              _buildGuideCard(),
            const SizedBox(height: 14),

            // ── Visualization Card ───────────────────────────────────
            _buildVisualizationCard(),
            const SizedBox(height: 14),

            // ── Experiment Conditions ────────────────────────────────
            if (widget.lab.environments.isNotEmpty)
              _buildConditionsCard(),
            if (widget.lab.environments.isNotEmpty)
              const SizedBox(height: 14),

            // ── Parameter Controls ───────────────────────────────────
            _buildControlsCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Guide Card ────────────────────────────────────────────────────────────
  Widget _buildGuideCard() {
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
            widget.lab.guideText!,
            style: AppTextStyle.normalText.copyWith(
              color: AppTheme.putih,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ── Visualization Card ────────────────────────────────────────────────────
  Widget _buildVisualizationCard() {
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
              const Icon(Icons.monitor, color: AppTheme.bottonColor, size: 18),
              const SizedBox(width: 8),
              Text(
                'Visualisasi Simulasi',
                style: AppTextStyle.normalText.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.putih,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Simulation canvas via SimRegistry
          AnimatedBuilder(
            animation: Listenable.merge([_animController, _elapsedNotifier]),
            builder: (context, _) {
              final u = _animController.value;
              final t = _stopwatch.elapsed.inMilliseconds / 1000.0;
              final damping =
                  _airResistance && _hasAtmosphere ? exp(-_gamma * t) : 1.0;
              final maxAngleDeg = _angle * damping;
              final angleRad = -maxAngleDeg * cos(pi * u) * pi / 180;

              // Update parameters with animated angle for the simulation widget
              final animatedParams = Map<String, double>.from(_paramValues);
              animatedParams['angle'] = angleRad * 180 / pi; // back to degrees for display

              return SimRegistry.build(
                simType: widget.lab.simType,
                parameters: {
                  ...animatedParams,
                  // Pass the actual radian angle for the painter
                  '_animatedAngleRad': angleRad,
                },
                environments: widget.lab.environments,
                isRunning: _isRunning,
                airResistance: _airResistance,
                selectedEnvironmentIndex: _selectedEnvIndex,
              );
            },
          ),
          const SizedBox(height: 16),

          // Reset | Stopwatch | Start/Pause buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh, color: AppTheme.putih, size: 16),
                  label: Text('RESET', style: AppTextStyle.botttonText),
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
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundPrimary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isRunning
                          ? AppTheme.progressColor.withValues(alpha: 0.5)
                          : AppTheme.textColor,
                    ),
                  ),
                  child: ValueListenableBuilder<Duration>(
                    valueListenable: _elapsedNotifier,
                    builder: (context, elapsed, _) {
                      return Row(
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
                            _formatElapsed(elapsed),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: _isRunning
                                  ? AppTheme.progressColor
                                  : AppTheme.textColor,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _toggleSimulation,
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

  // ── Experiment Conditions Card ────────────────────────────────────────────
  Widget _buildConditionsCard() {
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
              const Icon(Icons.science_outlined,
                  color: AppTheme.bottonColor, size: 18),
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

          // ── Environment Dropdown ───────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tempat Percobaan', style: AppTextStyle.normalText),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundPrimary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.progressColor.withValues(alpha: 0.4),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedEnvIndex,
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
                        ? null
                        : (val) {
                            if (val != null) {
                              setState(() => _selectedEnvIndex = val);
                              _updateAnimationConfig();
                            }
                          },
                    items: List.generate(widget.lab.environments.length, (i) {
                      final env = widget.lab.environments[i];
                      return DropdownMenuItem<int>(
                        value: i,
                        child: Text(
                          '${env.emoji}  ${env.name}',
                          style: AppTextStyle.normalText.copyWith(
                            color: AppTheme.putih,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Divider(color: AppTheme.textColor, height: 1, thickness: 0.3),
          const SizedBox(height: 6),

          // ── Monitor rows for current parameters ────────────────────────
          _monitorRow(
            'Percepatan Gravitasi (g)',
            '${_gravity.toStringAsFixed(2)} m/s²',
          ),
          ...widget.lab.parameters.map((p) => _monitorRow(
                p.label,
                '${(_paramValues[p.key] ?? p.defaultValue).toStringAsFixed(2)}${p.unit}',
              )),

          // ── Air Resistance Switch ─────────────────────────────────────
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
                          _hasAtmosphere
                              ? Icons.air_outlined
                              : Icons.do_not_disturb_alt_outlined,
                          size: 16,
                          color: _hasAtmosphere
                              ? AppTheme.bottonColor
                              : AppTheme.merah,
                        ),
                        const SizedBox(width: 6),
                        Text('Hambatan Udara', style: AppTextStyle.normalText),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _currentEnv.atmosphere,
                      style: AppTextStyle.normalText.copyWith(
                        fontSize: 10,
                        color: AppTheme.textColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    if (_airResistance && _hasAtmosphere)
                      Text(
                        'b = ${_currentEnv.drag} kg/s  •  γ = ${_gamma.toStringAsFixed(3)} s⁻¹',
                        style: AppTextStyle.normalText.copyWith(
                          fontSize: 10,
                          color: AppTheme.progressColor,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else if (_airResistance && !_hasAtmosphere)
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
                value: _airResistance,
                onChanged: (v) => setState(() => _airResistance = v),
                activeThumbColor:
                    _hasAtmosphere ? AppTheme.progressColor : AppTheme.merah,
                activeTrackColor:
                    (_hasAtmosphere ? AppTheme.progressColor : AppTheme.merah)
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

  // ── Parameter Controls Card ───────────────────────────────────────────────
  Widget _buildControlsCard() {
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

          // Dynamically build sliders from lab.parameters
          ...widget.lab.parameters.map((param) {
            return _buildSlider(
              label: param.label,
              value: _paramValues[param.key] ?? param.defaultValue,
              min: param.min,
              max: param.max,
              unit: param.unit,
              onChanged: (v) {
                setState(() => _paramValues[param.key] = v);
                _updateAnimationConfig();
              },
            );
          }),

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
}
