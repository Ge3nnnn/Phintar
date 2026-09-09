// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodoModel _$TodoModelFromJson(Map<String, dynamic> json) => TodoModel(
  id: json['id'] as String? ?? '',
  title: json['title'] as String? ?? '',
  description: json['description'] as String? ?? '',
  isCompleted: json['isCompleted'] as bool? ?? false,
  userId: json['userId'] as String? ?? '',
  createdAt: dateTimeFromJson(json['createdAt']),
);

Map<String, dynamic> _$TodoModelToJson(TodoModel instance) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'isCompleted': instance.isCompleted,
  'userId': instance.userId,
  'createdAt': dateTimeToJson(instance.createdAt),
};
