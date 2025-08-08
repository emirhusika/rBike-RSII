import 'package:json_annotation/json_annotation.dart';

part 'equipment_category.g.dart';

@JsonSerializable()
class EquipmentCategory {
  int? categoryId;
  String? equipmentName;

  EquipmentCategory({
    this.categoryId,
    this.equipmentName,
  });

  factory EquipmentCategory.fromJson(Map<String, dynamic> json) => _$EquipmentCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$EquipmentCategoryToJson(this);
} 