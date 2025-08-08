import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  int? userId;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? username;
  bool? status;
  DateTime? dateRegistered;
  String? image;

  User({
    this.userId,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.username,
    this.status,
    this.dateRegistered,
    this.image,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
