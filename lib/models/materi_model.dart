import 'dart:convert';

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
  final List<ContentBlock> blocks;

  const MateriModel({
    required this.id,
    required this.title,
    required this.category,
    this.description,
    this.bannerUrl = '',
    this.lottieUrl,
    this.sortOrder = 0,
    required this.blocks,
  });

  /// Creates a [MateriModel] from a SQLite row map.
  /// [content_blocks] column is a JSON-encoded string.
  factory MateriModel.fromMap(Map<String, dynamic> map) {
    List<ContentBlock> blocks = [];
    if (map['content_blocks'] != null) {
      final decoded = json.decode(map['content_blocks'] as String);
      blocks = (decoded as List<dynamic>)
          .map((e) => ContentBlock.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return MateriModel(
      id: (map['id'] as num).toInt(),
      title: map['title'] as String,
      category: (map['category'] as String?) ?? '',
      description: map['description'] as String?,
      bannerUrl: (map['banner_url'] as String?) ?? '',
      lottieUrl: map['lottie_url'] as String?,
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
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

    return MateriModel(
      id: (json['id'] as num).toInt(),
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
      blocks: blocks,
    );
  }

  /// Converts to a SQLite row map. [content_blocks] is JSON-encoded.
  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'category': category,
        'description': description,
        'banner_url': bannerUrl,
        'lottie_url': lottieUrl,
        'sort_order': sortOrder,
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
        'content_blocks': blocks.map((e) => e.toJson()).toList(),
      };
}
