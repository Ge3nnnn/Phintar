import 'dart:convert';

/// Configuration for a single adjustable parameter in a lab simulation.
///
/// Example: Sudut Simpangan (θ) with range 0–90°, default 30°.
/// The UI builds a slider for each [LabParameter].
class LabParameter {
  final String key;
  final String label;
  final String unit;
  final double min;
  final double max;
  final double defaultValue;

  const LabParameter({
    required this.key,
    required this.label,
    required this.unit,
    required this.min,
    required this.max,
    required this.defaultValue,
  });

  factory LabParameter.fromJson(Map<String, dynamic> json) {
    return LabParameter(
      key: json['key'] as String,
      label: json['label'] as String,
      unit: (json['unit'] as String?) ?? '',
      min: (json['min'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
      defaultValue: (json['defaultValue'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'label': label,
        'unit': unit,
        'min': min,
        'max': max,
        'defaultValue': defaultValue,
      };
}

/// An experiment location/environment with its physical properties.
///
/// Used by simulations that support different gravity/atmospheric conditions.
class LabEnvironment {
  final String name;
  final String emoji;
  final double gravity;
  final double drag;
  final String atmosphere;

  const LabEnvironment({
    required this.name,
    required this.emoji,
    required this.gravity,
    required this.drag,
    required this.atmosphere,
  });

  factory LabEnvironment.fromJson(Map<String, dynamic> json) {
    return LabEnvironment(
      name: json['name'] as String,
      emoji: (json['emoji'] as String?) ?? '🌍',
      gravity: (json['gravity'] as num).toDouble(),
      drag: (json['drag'] as num?)?.toDouble() ?? 0.0,
      atmosphere: (json['atmosphere'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'emoji': emoji,
        'gravity': gravity,
        'drag': drag,
        'atmosphere': atmosphere,
      };
}

/// Model for a virtual laboratory simulation.
///
/// [simType] maps to a registered simulation engine widget (e.g., 'pendulum').
/// [parameters] and [environments] are stored as JSON strings in SQLite
/// and decoded into typed lists for dynamic UI generation.
class LabModel {
  final int id;
  final String title;
  final String? subtitle;
  final String? description;
  final String simType;
  final String? guideText;
  final String? iconName;
  final List<LabParameter> parameters;
  final List<LabEnvironment> environments;
  final int sortOrder;

  const LabModel({
    required this.id,
    required this.title,
    this.subtitle,
    this.description,
    required this.simType,
    this.guideText,
    this.iconName,
    this.parameters = const [],
    this.environments = const [],
    this.sortOrder = 0,
  });

  /// Creates a [LabModel] from a SQLite row map.
  factory LabModel.fromMap(Map<String, dynamic> map) {
    List<LabParameter> params = [];
    if (map['parameters'] != null && (map['parameters'] as String).isNotEmpty) {
      final decoded = json.decode(map['parameters'] as String);
      params = (decoded as List<dynamic>)
          .map((e) => LabParameter.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<LabEnvironment> envs = [];
    if (map['environments'] != null &&
        (map['environments'] as String).isNotEmpty) {
      final decoded = json.decode(map['environments'] as String);
      envs = (decoded as List<dynamic>)
          .map((e) => LabEnvironment.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return LabModel(
      id: (map['id'] as num).toInt(),
      title: map['title'] as String,
      subtitle: map['subtitle'] as String?,
      description: map['description'] as String?,
      simType: map['sim_type'] as String,
      guideText: map['guide_text'] as String?,
      iconName: map['icon_name'] as String?,
      parameters: params,
      environments: envs,
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  /// Creates a [LabModel] from a JSON map (used for seed data).
  factory LabModel.fromJson(Map<String, dynamic> json) {
    List<LabParameter> params = [];
    if (json['parameters'] != null) {
      params = (json['parameters'] as List<dynamic>)
          .map((e) => LabParameter.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<LabEnvironment> envs = [];
    if (json['environments'] != null) {
      envs = (json['environments'] as List<dynamic>)
          .map((e) => LabEnvironment.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return LabModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      description: json['description'] as String?,
      simType: (json['sim_type'] as String?) ??
          (json['simType'] as String?) ??
          'unknown',
      guideText:
          (json['guide_text'] as String?) ?? (json['guideText'] as String?),
      iconName:
          (json['icon_name'] as String?) ?? (json['iconName'] as String?),
      parameters: params,
      environments: envs,
      sortOrder: (json['sort_order'] as num?)?.toInt() ??
          (json['sortOrder'] as num?)?.toInt() ??
          0,
    );
  }

  /// Converts to a SQLite row map.
  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'description': description,
        'sim_type': simType,
        'guide_text': guideText,
        'icon_name': iconName,
        'parameters': json.encode(parameters.map((e) => e.toJson()).toList()),
        'environments':
            json.encode(environments.map((e) => e.toJson()).toList()),
        'sort_order': sortOrder,
      };
}
