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
  List<UserRole>? userRoles;
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
    this.userRoles,
    this.image,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  bool hasAdminRole() {
    return userRoles?.any((role) => role.role?.name == 'Admin') ?? false;
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    } else {
      return username ?? 'Unknown User';
    }
  }
}

@JsonSerializable()
class UserRole {
  int? userRoleId;
  int? userId;
  int? roleId;
  Role? role;

  UserRole({this.userRoleId, this.userId, this.roleId, this.role});

  factory UserRole.fromJson(Map<String, dynamic> json) =>
      _$UserRoleFromJson(json);
  Map<String, dynamic> toJson() => _$UserRoleToJson(this);
}

@JsonSerializable()
class Role {
  int? roleId;
  String? name;
  String? description;

  Role({this.roleId, this.name, this.description});

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);
  Map<String, dynamic> toJson() => _$RoleToJson(this);
}
