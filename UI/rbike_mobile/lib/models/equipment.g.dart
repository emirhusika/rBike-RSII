// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Equipment _$EquipmentFromJson(Map<String, dynamic> json) => Equipment(
  equipmentId: (json['equipmentId'] as num?)?.toInt(),
  name: json['name'] as String?,
  description: json['description'] as String?,
  price: (json['price'] as num?)?.toDouble(),
  image: json['image'] as String?,
  status: json['status'] as String?,
  stockQuantity: (json['stockQuantity'] as num?)?.toInt(),
  equipmentCategoryId: (json['equipmentCategoryId'] as num?)?.toInt(),
  equipmentCategoryName: json['equipmentCategoryName'] as String?,
);

Map<String, dynamic> _$EquipmentToJson(Equipment instance) => <String, dynamic>{
  'equipmentId': instance.equipmentId,
  'name': instance.name,
  'description': instance.description,
  'price': instance.price,
  'image': instance.image,
  'status': instance.status,
  'stockQuantity': instance.stockQuantity,
  'equipmentCategoryId': instance.equipmentCategoryId,
  'equipmentCategoryName': instance.equipmentCategoryName,
};
