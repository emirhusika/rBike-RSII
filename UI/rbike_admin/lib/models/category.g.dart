// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) =>
    Category()
      ..categoryId = (json['categoryId'] as num?)?.toInt()
      ..name = json['name'] as String?;

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'categoryId': instance.categoryId,
  'name': instance.name,
};
