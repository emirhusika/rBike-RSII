// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) =>
    Comment()
      ..commentId = (json['commentId'] as num?)?.toInt()
      ..content = json['content'] as String?
      ..dateAdded =
          json['dateAdded'] == null
              ? null
              : DateTime.parse(json['dateAdded'] as String)
      ..userId = (json['userId'] as num?)?.toInt()
      ..bikeId = (json['bikeId'] as num?)?.toInt()
      ..status = json['status'] as String?
      ..bikeName = json['bikeName'] as String?
      ..username = json['username'] as String?;

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
  'commentId': instance.commentId,
  'content': instance.content,
  'dateAdded': instance.dateAdded?.toIso8601String(),
  'userId': instance.userId,
  'bikeId': instance.bikeId,
  'status': instance.status,
  'bikeName': instance.bikeName,
  'username': instance.username,
};
