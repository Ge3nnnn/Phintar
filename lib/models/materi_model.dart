import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single content block within a materi page.
/// Each block has a [type] that determines rendering and [content] data.
///
/// Supported types:
/// - 'text'     : Plain paragraph text
/// - 'subtitle' : Section subtitle heading
/// - 'image'    : Asset path or URL to image
/// - 'formula'  : Physics formula (rendered in a styled card)
/// - 'youtube'  : YouTube video ID
/// - 'lottie'   : Lottie animation asset path
/// - 'divider'  : A visual divider (content is ignored)
class ContentBlock {
  final String type;
  final String content;

  const ContentBlock({required this.type, required this.content});

  factory ContentBlock.fromJson(Map<String, dynamic> json) {
    return ContentBlock(
      type: json['type'] as String,
      content: json['content'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'content': content,
      };
}

/// Model for a learning material (materi) entry.
///
/// Content is stored as a JSON-encoded list of [ContentBlock]s in SQLite,
/// enabling rich, multi-section pages without schema changes.
class MateriModel {
  final int id;
  final String category;
  final String title;
  final String? description;
  final String bannerUrl;
  final String? lottieUrl;
  final int sortOrder;
  final int grade;
  final List<ContentBlock> blocks;

  const MateriModel({
    required this.id,
    required this.title,
    required this.category,
    this.description,
    this.bannerUrl = '',
    this.lottieUrl,
    this.sortOrder = 0,
    this.grade = 10,
    required this.blocks,
  });

  static int inferGrade(int id) {
    if (id >= 300) return 12;
    if (id >= 200) return 11;
    return 10;
  }

  /// Creates a [MateriModel] from a map.
  /// [content_blocks] can be a List or JSON-encoded string.
  factory MateriModel.fromMap(Map<String, dynamic> map) {
    List<ContentBlock> blocks = [];
    if (map['content_blocks'] != null) {
      final raw = map['content_blocks'];
      if (raw is List) {
        blocks = raw
            .map((e) => ContentBlock.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (raw is String && raw.isNotEmpty) {
        try {
          final decoded = json.decode(raw);
          if (decoded is List) {
            blocks = decoded
                .map((e) => ContentBlock.fromJson(e as Map<String, dynamic>))
                .toList();
          }
        } catch (_) {}
      }
    }

    final id = (map['id'] as num).toInt();
    final grade = (map['grade'] as num?)?.toInt() ?? inferGrade(id);

    return MateriModel(
      id: id,
      title: map['title'] as String,
      category: (map['category'] as String?) ?? '',
      description: map['description'] as String?,
      bannerUrl: (map['banner_url'] as String?) ?? '',
      lottieUrl: map['lottie_url'] as String?,
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
      grade: grade,
      blocks: blocks,
    );
  }

  /// Creates a [MateriModel] from a JSON map (used for seed data).
  factory MateriModel.fromJson(Map<String, dynamic> json) {
    List<ContentBlock> blocks = [];
    if (json['content_blocks'] != null) {
      blocks = (json['content_blocks'] as List<dynamic>)
          .map((e) => ContentBlock.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    // Also support the old 'blocks' key for backward compatibility
    if (blocks.isEmpty && json['blocks'] != null) {
      blocks = (json['blocks'] as List<dynamic>)
          .map((e) => ContentBlock.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final id = (json['id'] as num).toInt();
    final grade = (json['grade'] as num?)?.toInt() ?? inferGrade(id);

    return MateriModel(
      id: id,
      title: json['title'] as String,
      category: (json['category'] as String?) ?? '',
      description: json['description'] as String?,
      bannerUrl: (json['banner_url'] as String?) ??
          (json['bannerUrl'] as String?) ??
          '',
      lottieUrl:
          (json['lottie_url'] as String?) ?? (json['lottieUrl'] as String?),
      sortOrder: (json['sort_order'] as num?)?.toInt() ??
          (json['sortOrder'] as num?)?.toInt() ??
          0,
      grade: grade,
      blocks: blocks,
    );
  }

  /// Creates a [MateriModel] from a Firestore [DocumentSnapshot].
  factory MateriModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, [
    SnapshotOptions? options,
  ]) {
    final data = doc.data() ?? {};

    // ID parsing: prioritas data['id'], fallback parsing doc.id
    int id = 0;
    if (data['id'] != null) {
      id = (data['id'] is num)
          ? (data['id'] as num).toInt()
          : int.tryParse(data['id'].toString()) ?? 0;
    } else {
      id = int.tryParse(doc.id) ?? 0;
    }

    List<ContentBlock> blocks = [];
    final rawBlocks = data['content_blocks'] ?? data['blocks'];
    if (rawBlocks != null) {
      if (rawBlocks is List) {
        blocks = rawBlocks
            .map((e) => ContentBlock.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } else if (rawBlocks is String && rawBlocks.isNotEmpty) {
        try {
          final decoded = json.decode(rawBlocks);
          if (decoded is List) {
            blocks = decoded
                .map((e) => ContentBlock.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList();
          }
        } catch (_) {}
      }
    }

    final grade = (data['grade'] as num?)?.toInt() ?? inferGrade(id);

    return MateriModel(
      id: id,
      title: (data['title'] as String?) ?? '',
      category: (data['category'] as String?) ?? '',
      description: data['description'] as String?,
      bannerUrl: (data['banner_url'] as String?) ??
          (data['bannerUrl'] as String?) ??
          '',
      lottieUrl:
          (data['lottie_url'] as String?) ?? (data['lottieUrl'] as String?),
      sortOrder: (data['sort_order'] as num?)?.toInt() ??
          (data['sortOrder'] as num?)?.toInt() ??
          0,
      grade: grade,
      blocks: blocks,
    );
  }

  /// Converts to a Firestore-friendly Map.
  Map<String, dynamic> toFirestore() => {
        'id': id,
        'title': title,
        'category': category,
        'description': description,
        'banner_url': bannerUrl,
        'lottie_url': lottieUrl,
        'sort_order': sortOrder,
        'grade': grade,
        'content_blocks': blocks.map((e) => e.toJson()).toList(),
      };

  /// Converts to a SQLite row map. [content_blocks] is JSON-encoded.
  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'category': category,
        'description': description,
        'banner_url': bannerUrl,
        'lottie_url': lottieUrl,
        'sort_order': sortOrder,
        'grade': grade,
        'content_blocks': json.encode(blocks.map((e) => e.toJson()).toList()),
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'description': description,
        'banner_url': bannerUrl,
        'lottie_url': lottieUrl,
        'sort_order': sortOrder,
        'grade': grade,
        'content_blocks': blocks.map((e) => e.toJson()).toList(),
      };
}
