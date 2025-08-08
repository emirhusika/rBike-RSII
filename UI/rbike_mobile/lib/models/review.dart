import 'package:json_annotation/json_annotation.dart';

part 'review.g.dart';

@JsonSerializable()
class Review {
  int? bikeReviewId;
  int? bikeId;
  int? userId;
  int? rating;
  @JsonKey(name: 'date')
  DateTime? datum;
  String? bikeName;
  String? username;

  Review();

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewToJson(this);
} 