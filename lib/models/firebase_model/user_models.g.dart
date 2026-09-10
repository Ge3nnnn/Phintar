// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModelFirebase _$UserModelFirebaseFromJson(Map<String, dynamic> json) =>
    UserModelFirebase(
      uid: json['uid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      createdAt: dateTimeFromJson(json['createdAt']),
      photoUrl: json['photoUrl'] as String? ?? '',
    );

Map<String, dynamic> _$UserModelFirebaseToJson(UserModelFirebase instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'email': instance.email,
      'createdAt': dateTimeToJson(instance.createdAt),
      'photoUrl': instance.photoUrl,
    };
