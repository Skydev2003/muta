import 'package:freezed_annotation/freezed_annotation.dart';

part 'history_model.freezed.dart';
part 'history_model.g.dart';

@freezed
class HistoryModel with _$HistoryModel {
  const factory HistoryModel({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'session_id') int? sessionId,
    @JsonKey(name: 'total_price') int? totalPrice,
    @JsonKey(name: 'items') int? items,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'table_name') String? tableName,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'user_email') String? userEmail,
    @JsonKey(name: 'user_name') String? userName,
  }) = _HistoryModel;

  factory HistoryModel.fromJson(
    Map<String, dynamic> json,
  ) => _$HistoryModelFromJson(json);
}
