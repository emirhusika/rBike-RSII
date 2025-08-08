import 'package:json_annotation/json_annotation.dart';

part 'bike.g.dart';

@JsonSerializable()
class Bike {
  int? bikeId;
  String? name;
  String? image;
  String? bikeCode;
  double? price;
  int? categoryId;
  String? stateMachine;

  Bike({this.bikeId, this.name, this.stateMachine});

  /// Connect the generated [_$PersonFromJson] function to the `fromJson`
  /// factory.
  factory Bike.fromJson(Map<String, dynamic> json) => _$BikeFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$BikeToJson(this);
}
