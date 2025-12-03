// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HistoryModelImpl _$$HistoryModelImplFromJson(Map<String, dynamic> json) =>
    _$HistoryModelImpl(
      id: (json['id'] as num?)?.toInt(),
      sessionId: (json['session_id'] as num?)?.toInt(),
      totalPrice: (json['total_price'] as num?)?.toInt(),
      items: (json['items'] as num?)?.toInt(),
      createdAt: json['created_at'] as String?,
      tableName: json['table_name'] as String?,
      userId: json['user_id'] as String?,
      userEmail: json['user_email'] as String?,
    );

Map<String, dynamic> _$$HistoryModelImplToJson(_$HistoryModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'session_id': instance.sessionId,
      'total_price': instance.totalPrice,
      'items': instance.items,
      'created_at': instance.createdAt,
      'table_name': instance.tableName,
      'user_id': instance.userId,
      'user_email': instance.userEmail,
    };
