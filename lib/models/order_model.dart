
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

@freezed
class OrderModel with _$OrderModel {
  const factory OrderModel({
  @JsonKey(name: 'id') int? id,
  @JsonKey(name: 'session_id') String? sessionId,
  @JsonKey(name: 'menu_id') int? menuId,
  @JsonKey(name: 'quantity') int? quantity,
  @JsonKey(name: 'price') int? price,
  @JsonKey(name: 'created_at') String? createdAt,
  @JsonKey(name: 'name') String? name,
  @JsonKey(name: 'image') String? image,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) => _$OrderModelFromJson(json);
}
