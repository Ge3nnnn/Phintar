import 'package:blabla/data/models/lab_model.dart';
import 'package:blabla/views/5_features/lab_page/simulations/pendulum_parameter.dart';
import 'package:flutter/material.dart';

/// Registry that maps simulation type strings to physics engine widgets.
///
/// To add a new simulation type:
/// 1. Create a new simulation widget (e.g., `spring_simulation.dart`)
/// 2. Register it in the [build] method's switch statement
///
/// This is the ONLY file you need to edit when adding a new physics engine type.
class SimRegistry {
  /// Builds the simulation widget for the given [simType].
  ///
  /// [parameters] contains current slider values keyed by parameter key.
  /// [environments] contains available experiment locations.
  /// [isRunning] indicates whether the simulation is currently playing.
  /// [onParameterChanged] callback when a parameter is updated by the sim.
  static Widget build({
    required String simType,
    required Map<String, double> parameters,
    required List<LabEnvironment> environments,
    required bool isRunning,
    bool airResistance = false,
    int selectedEnvironmentIndex = 0,
  }) {
    switch (simType) {
      case 'pendulum':
        return PendulumSimulation(
          parameters: parameters,
          environments: environments,
          isRunning: isRunning,
          airResistance: airResistance,
          selectedEnvironmentIndex: selectedEnvironmentIndex,
        );

      // Add new simulation types here:
      // case 'spring':
      //   return SpringSimulation(parameters: parameters, ...);
      // case 'wave':
      //   return WaveSimulation(parameters: parameters, ...);

      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.science_outlined, color: Colors.grey, size: 48),
              const SizedBox(height: 12),
              Text(
                'Simulasi "$simType" belum tersedia',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        );
    }
  }
}
