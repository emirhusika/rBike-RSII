// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reservation _$ReservationFromJson(Map<String, dynamic> json) =>
    Reservation()
      ..reservationId = (json['reservationId'] as num?)?.toInt()
      ..bikeId = (json['bikeId'] as num?)?.toInt()
      ..bikeName = json['bikeName'] as String?
      ..userId = (json['userId'] as num?)?.toInt()
      ..username = json['username'] as String?
      ..createdAt =
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String)
      ..startDateTime =
          json['startDateTime'] == null
              ? null
              : DateTime.parse(json['startDateTime'] as String)
      ..endDateTime =
          json['endDateTime'] == null
              ? null
              : DateTime.parse(json['endDateTime'] as String)
      ..status = json['status'] as String?
      ..bike =
          json['bike'] == null
              ? null
              : Bike.fromJson(json['bike'] as Map<String, dynamic>);

Map<String, dynamic> _$ReservationToJson(Reservation instance) =>
    <String, dynamic>{
      'reservationId': instance.reservationId,
      'bikeId': instance.bikeId,
      'bikeName': instance.bikeName,
      'userId': instance.userId,
      'username': instance.username,
      'createdAt': instance.createdAt?.toIso8601String(),
      'startDateTime': instance.startDateTime?.toIso8601String(),
      'endDateTime': instance.endDateTime?.toIso8601String(),
      'status': instance.status,
      'bike': instance.bike,
    };
