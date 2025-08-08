// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  userId: (json['userId'] as num?)?.toInt(),
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  username: json['username'] as String?,
  status: json['status'] as bool?,
  dateRegistered:
      json['dateRegistered'] == null
          ? null
          : DateTime.parse(json['dateRegistered'] as String),
  userRoles:
      (json['userRoles'] as List<dynamic>?)
          ?.map((e) => UserRole.fromJson(e as Map<String, dynamic>))
          .toList(),
  image: json['image'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'userId': instance.userId,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'email': instance.email,
  'phone': instance.phone,
  'username': instance.username,
  'status': instance.status,
  'dateRegistered': instance.dateRegistered?.toIso8601String(),
  'userRoles': instance.userRoles,
  'image': instance.image,
};

UserRole _$UserRoleFromJson(Map<String, dynamic> json) => UserRole(
  userRoleId: (json['userRoleId'] as num?)?.toInt(),
  userId: (json['userId'] as num?)?.toInt(),
  roleId: (json['roleId'] as num?)?.toInt(),
  role:
      json['role'] == null
          ? null
          : Role.fromJson(json['role'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserRoleToJson(UserRole instance) => <String, dynamic>{
  'userRoleId': instance.userRoleId,
  'userId': instance.userId,
  'roleId': instance.roleId,
  'role': instance.role,
};

Role _$RoleFromJson(Map<String, dynamic> json) => Role(
  roleId: (json['roleId'] as num?)?.toInt(),
  name: json['name'] as String?,
  description: json['description'] as String?,
);

Map<String, dynamic> _$RoleToJson(Role instance) => <String, dynamic>{
  'roleId': instance.roleId,
  'name': instance.name,
  'description': instance.description,
};
