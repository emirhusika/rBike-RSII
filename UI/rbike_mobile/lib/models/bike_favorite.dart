import 'package:json_annotation/json_annotation.dart';
import 'package:rbike_mobile/models/bike.dart';

part 'bike_favorite.g.dart';

@JsonSerializable()
class BikeFavorite {
  int? favoriteId;
  int? bikeId;
  int? userId;
  String? bikeName;
  String? username;
  Bike? bike;

  BikeFavorite();

  factory BikeFavorite.fromJson(Map<String, dynamic> json) {
    final bikeFavorite = _$BikeFavoriteFromJson(json);
    if (json['bike'] != null) {
      bikeFavorite.bike = Bike.fromJson(json['bike'] as Map<String, dynamic>);
      bikeFavorite.bikeName = bikeFavorite.bike!.name;
    }
    if (json['user'] != null) {
      bikeFavorite.username = json['user']['username'] as String?;
    }
    return bikeFavorite;
  }

  Map<String, dynamic> toJson() => _$BikeFavoriteToJson(this);
} 