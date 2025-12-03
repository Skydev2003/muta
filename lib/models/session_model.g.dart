// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SessionModelImpl _$$SessionModelImplFromJson(Map<String, dynamic> json) =>
    _$SessionModelImpl(
      id: (json['id'] as num?)?.toInt(),
      tableId: (json['table_id'] as num?)?.toInt(),
      customerCount: (json['customer_count'] as num?)?.toInt(),
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      status: json['status'] as String?,
      timeused: json['timeused'] as String?,
    );

Map<String, dynamic> _$$SessionModelImplToJson(_$SessionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'table_id': instance.tableId,
      'customer_count': instance.customerCount,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'status': instance.status,
      'timeused': instance.timeused,
    };
