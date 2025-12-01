
import 'package:freezed_annotation/freezed_annotation.dart';

part 'menu_model.freezed.dart';
part 'menu_model.g.dart';

@freezed
class MenuModel with _$MenuModel {
  const factory MenuModel({
  @JsonKey(name: 'id') int? id,
  @JsonKey(name: 'name') String? name,
  @JsonKey(name: 'price') int? price,
  @JsonKey(name: 'category') String? category,
  @JsonKey(name: 'image_url') String? imageUrl,
  }) = _MenuModel;

  factory MenuModel.fromJson(Map<String, dynamic> json) => _$MenuModelFromJson(json);
}
