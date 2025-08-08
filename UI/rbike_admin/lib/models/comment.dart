import 'package:json_annotation/json_annotation.dart';

part 'comment.g.dart';

@JsonSerializable()
class Comment {
  int? commentId;
  String? content;
  DateTime? dateAdded;
  int? userId;
  int? bikeId;
  String? status;
  String? bikeName;
  String? username;

  Comment();

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);

  Map<String, dynamic> toJson() => _$CommentToJson(this);
} 