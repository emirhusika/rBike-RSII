import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rbike_mobile/models/comment.dart';
import 'package:rbike_mobile/providers/auth_provider.dart';
import 'package:rbike_mobile/providers/base_provider.dart';

class CommentProvider extends BaseProvider<Comment> {
  CommentProvider() : super("Comment");

  @override
  Comment fromJson(data) {
    return Comment.fromJson(data);
  }

  Future<List<Comment>> getCommentsForBike(int bikeId) async {
    try {
      final result = await get(filter: {'bikeId': bikeId, 'status': 'active'});
      return result.result;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Comment> addComment(int bikeId, int userId, String content) async {
    try {
      return await insert({
        'bikeId': bikeId,
        'userId': userId,
        'content': content,
      });
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Comment>> getAllComments() async {
    try {
      final result = await get(filter: {'status': 'active'});
      return result.result;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
} 