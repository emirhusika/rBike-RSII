// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bike_favorite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BikeFavorite _$BikeFavoriteFromJson(Map<String, dynamic> json) =>
    BikeFavorite()
      ..favoriteId = (json['favoriteId'] as num?)?.toInt()
      ..bikeId = (json['bikeId'] as num?)?.toInt()
      ..userId = (json['userId'] as num?)?.toInt()
      ..bikeName = json['bikeName'] as String?
      ..username = json['username'] as String?
      ..bike =
          json['bike'] == null
              ? null
              : Bike.fromJson(json['bike'] as Map<String, dynamic>);

Map<String, dynamic> _$BikeFavoriteToJson(BikeFavorite instance) =>
    <String, dynamic>{
      'favoriteId': instance.favoriteId,
      'bikeId': instance.bikeId,
      'userId': instance.userId,
      'bikeName': instance.bikeName,
      'username': instance.username,
      'bike': instance.bike,
    };
