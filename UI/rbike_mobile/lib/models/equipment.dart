import 'package:json_annotation/json_annotation.dart';

part 'equipment.g.dart';

@JsonSerializable()
class Equipment {
  int? equipmentId;
  String? name;
  String? description;
  double? price;
  String? image;
  String? status;
  int? stockQuantity;
  int? equipmentCategoryId;
  String? equipmentCategoryName;

  Equipment({
    this.equipmentId,
    this.name,
    this.description,
    this.price,
    this.image,
    this.status,
    this.stockQuantity,
    this.equipmentCategoryId,
    this.equipmentCategoryName,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) => _$EquipmentFromJson(json);
  Map<String, dynamic> toJson() => _$EquipmentToJson(this);
} 