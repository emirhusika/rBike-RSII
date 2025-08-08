// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EquipmentCategory _$EquipmentCategoryFromJson(Map<String, dynamic> json) =>
    EquipmentCategory(
      categoryId: (json['categoryId'] as num?)?.toInt(),
      equipmentName: json['equipmentName'] as String?,
    );

Map<String, dynamic> _$EquipmentCategoryToJson(EquipmentCategory instance) =>
    <String, dynamic>{
      'categoryId': instance.categoryId,
      'equipmentName': instance.equipmentName,
    };
