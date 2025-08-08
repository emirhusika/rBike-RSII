// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bike.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Bike _$BikeFromJson(Map<String, dynamic> json) =>
    Bike(
        bikeId: (json['bikeId'] as num?)?.toInt(),
        name: json['name'] as String?,
        stateMachine: json['stateMachine'] as String?,
      )
      ..image = json['image'] as String?
      ..bikeCode = json['bikeCode'] as String?
      ..price = (json['price'] as num?)?.toDouble()
      ..categoryId = (json['categoryId'] as num?)?.toInt();

Map<String, dynamic> _$BikeToJson(Bike instance) => <String, dynamic>{
  'bikeId': instance.bikeId,
  'name': instance.name,
  'image': instance.image,
  'bikeCode': instance.bikeCode,
  'price': instance.price,
  'categoryId': instance.categoryId,
  'stateMachine': instance.stateMachine,
};
