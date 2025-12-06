// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      userId: json['user_id'] as String?,
      userEmail: json['user_email'] as String?,
      userName: json['user_name'] as String?,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'user_email': instance.userEmail,
      'user_name': instance.userName,
      'created_at': instance.createdAt,
    };
