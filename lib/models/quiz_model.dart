import 'dart:convert';

/// Model for a single quiz question.
///
/// [options] is stored as a JSON array of strings in SQLite.
/// [correctIndex] is the 0-based index into [options].
class QuizQuestionModel {
  final int? id;
  final int quizId;
  final String? topic;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;
  final int sortOrder;

  const QuizQuestionModel({
    this.id,
    required this.quizId,
    this.topic,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
    this.sortOrder = 0,
  });

  /// Creates from a map. [options] can be a List or JSON-encoded string.
  factory QuizQuestionModel.fromMap(Map<String, dynamic> map) {
    List<String> opts = [];
    if (map['options'] != null) {
      final raw = map['options'];
      if (raw is List) {
        opts = raw.map((e) => e.toString()).toList();
      } else if (raw is String && raw.isNotEmpty) {
        try {
          final decoded = json.decode(raw);
          if (decoded is List) {
            opts = decoded.map((e) => e.toString()).toList();
          }
        } catch (_) {
          opts = [raw];
        }
      }
    }

    return QuizQuestionModel(
      id: map['id'] != null ? (map['id'] as num).toInt() : null,
      quizId: (map['quiz_id'] as num?)?.toInt() ??
          (map['quizId'] as num?)?.toInt() ??
          0,
      topic: map['topic'] as String?,
      question: map['question'] as String,
      options: opts,
      correctIndex: (map['correct_index'] as num?)?.toInt() ??
          (map['correctIndex'] as num?)?.toInt() ??
          0,
      explanation: map['explanation'] as String?,
      sortOrder: (map['sort_order'] as num?)?.toInt() ??
          (map['sortOrder'] as num?)?.toInt() ??
          0,
    );
  }

  /// Creates from a JSON map (seed data).
  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    List<String> opts = [];
    if (json['options'] != null) {
      opts = (json['options'] as List<dynamic>).map((e) => e.toString()).toList();
    }

    return QuizQuestionModel(
      id: json['id'] != null ? (json['id'] as num).toInt() : null,
      quizId: (json['quiz_id'] as num?)?.toInt() ??
          (json['quizId'] as num?)?.toInt() ??
          0,
      topic: json['topic'] as String?,
      question: json['question'] as String,
      options: opts,
      correctIndex: (json['correct_index'] as num?)?.toInt() ??
          (json['correctIndex'] as num?)?.toInt() ??
          0,
      explanation: json['explanation'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ??
          (json['sortOrder'] as num?)?.toInt() ??
          0,
    );
  }

  /// Converts to a Firestore map.
  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
      'quiz_id': quizId,
      'question': question,
      'options': options,
      'correct_index': correctIndex,
      'sort_order': sortOrder,
    };
    if (id != null) map['id'] = id;
    if (topic != null) map['topic'] = topic;
    if (explanation != null) map['explanation'] = explanation;
    return map;
  }

  /// Converts to a SQLite row map. [options] is JSON-encoded.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'quiz_id': quizId,
      'topic': topic,
      'question': question,
      'options': json.encode(options),
      'correct_index': correctIndex,
      'explanation': explanation,
      'sort_order': sortOrder,
    };
    if (id != null) map['id'] = id;
    return map;
  }
}

/// Model for a quiz (collection of questions).
///
/// [questions] can be embedded inline or loaded separately.
class QuizModel {
  final int id;
  final String title;
  final String? category;
  final String? description;
  final int timeLimitMinutes;
  final int sortOrder;
  final List<QuizQuestionModel> questions;

  const QuizModel({
    required this.id,
    required this.title,
    this.category,
    this.description,
    this.timeLimitMinutes = 20,
    this.sortOrder = 0,
    this.questions = const [],
  });

  /// Creates from a map. Supports inline questions or external list.
  factory QuizModel.fromMap(Map<String, dynamic> map,
      [List<QuizQuestionModel>? questions]) {
    List<QuizQuestionModel> qList = questions ?? [];
    if (qList.isEmpty && map['questions'] != null && map['questions'] is List) {
      final quizId = (map['id'] as num?)?.toInt() ?? 0;
      qList = (map['questions'] as List<dynamic>).map((e) {
        final qMap = e as Map<String, dynamic>;
        if (!qMap.containsKey('quiz_id') && !qMap.containsKey('quizId')) {
          qMap['quiz_id'] = quizId;
        }
        return QuizQuestionModel.fromMap(qMap);
      }).toList();
    }

    return QuizModel(
      id: (map['id'] as num).toInt(),
      title: map['title'] as String,
      category: map['category'] as String?,
      description: map['description'] as String?,
      timeLimitMinutes: (map['time_limit_minutes'] as num?)?.toInt() ??
          (map['timeLimitMinutes'] as num?)?.toInt() ??
          20,
      sortOrder: (map['sort_order'] as num?)?.toInt() ??
          (map['sortOrder'] as num?)?.toInt() ??
          0,
      questions: qList,
    );
  }

  /// Creates from a JSON map (seed data). Questions are inline.
  factory QuizModel.fromJson(Map<String, dynamic> json) {
    List<QuizQuestionModel> questions = [];
    if (json['questions'] != null) {
      final quizId =
          (json['id'] as num?)?.toInt() ?? 0;
      questions = (json['questions'] as List<dynamic>).map((e) {
        final qMap = e as Map<String, dynamic>;
        // Inject quiz_id if not present
        if (!qMap.containsKey('quiz_id') && !qMap.containsKey('quizId')) {
          qMap['quiz_id'] = quizId;
        }
        return QuizQuestionModel.fromJson(qMap);
      }).toList();
    }

    return QuizModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      category: json['category'] as String?,
      description: json['description'] as String?,
      timeLimitMinutes: (json['time_limit_minutes'] as num?)?.toInt() ??
          (json['timeLimitMinutes'] as num?)?.toInt() ??
          20,
      sortOrder: (json['sort_order'] as num?)?.toInt() ??
          (json['sortOrder'] as num?)?.toInt() ??
          0,
      questions: questions,
    );
  }

  /// Converts to a Firestore-friendly Map.
  Map<String, dynamic> toFirestore() => {
        'id': id,
        'title': title,
        'category': category,
        'description': description,
        'time_limit_minutes': timeLimitMinutes,
        'sort_order': sortOrder,
        'questions': questions.map((q) => q.toFirestore()).toList(),
      };

  /// Converts to a SQLite row map (questions stored separately).
  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'category': category,
        'description': description,
        'time_limit_minutes': timeLimitMinutes,
        'sort_order': sortOrder,
      };

  /// Returns a copy with the given questions attached.
  QuizModel copyWithQuestions(List<QuizQuestionModel> questions) {
    return QuizModel(
      id: id,
      title: title,
      category: category,
      description: description,
      timeLimitMinutes: timeLimitMinutes,
      sortOrder: sortOrder,
      questions: questions,
    );
  }
}
