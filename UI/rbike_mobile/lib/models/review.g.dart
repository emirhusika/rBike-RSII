// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) =>
    Review()
      ..bikeReviewId = (json['bikeReviewId'] as num?)?.toInt()
      ..bikeId = (json['bikeId'] as num?)?.toInt()
      ..userId = (json['userId'] as num?)?.toInt()
      ..rating = (json['rating'] as num?)?.toInt()
      ..datum =
          json['date'] == null ? null : DateTime.parse(json['date'] as String)
      ..bikeName = json['bikeName'] as String?
      ..username = json['username'] as String?;

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
  'bikeReviewId': instance.bikeReviewId,
  'bikeId': instance.bikeId,
  'userId': instance.userId,
  'rating': instance.rating,
  'date': instance.datum?.toIso8601String(),
  'bikeName': instance.bikeName,
  'username': instance.username,
};
