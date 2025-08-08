//import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rbike_mobile/models/bike.dart';

part 'reservation.g.dart';

@JsonSerializable()
class Reservation {
  int? reservationId;
  int? bikeId;
  String? bikeName;
  int? userId;
  String? username;
  DateTime? createdAt;
  DateTime? startDateTime;
  DateTime? endDateTime;
  String? status;

  Bike? bike;

  Reservation();

  factory Reservation.fromJson(Map<String, dynamic> json) {
    final reservation = _$ReservationFromJson(json);
    if (json['bike'] != null) {
      reservation.bike = Bike.fromJson(json['bike'] as Map<String, dynamic>);
      reservation.bikeName = reservation.bike!.name;
    }
    if (json['user'] != null) {
      reservation.username = (json['user']['username'] as String?);
    }
    return reservation;
  }

  Map<String, dynamic> toJson() => _$ReservationToJson(this);
}
