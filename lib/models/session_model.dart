
import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_model.freezed.dart';
part 'session_model.g.dart';

@freezed
class SessionModel with _$SessionModel {
  const factory SessionModel({
  @JsonKey(name: 'id') int? id,
  @JsonKey(name: 'table_id') int? tableId,
  @JsonKey(name: 'customer_count') int? customerCount,
  @JsonKey(name: 'start_time') String? startTime,
  @JsonKey(name: 'end_time') String? endTime,
  @JsonKey(name: 'status') String? status,
  @JsonKey(name: 'timeused') String? timeused,
  }) = _SessionModel;

  factory SessionModel.fromJson(Map<String, dynamic> json) => _$SessionModelFromJson(json);
}
