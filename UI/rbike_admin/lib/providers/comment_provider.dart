import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rbike_admin/models/comment.dart';
import 'package:rbike_admin/providers/base_provider.dart';

class CommentProvider extends BaseProvider<Comment> {
  CommentProvider() : super("Comment");

  @override
  Comment fromJson(data) {
    return Comment.fromJson(data);
  }

  Future<List<Comment>> getAllComments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$end?status=active'),
        headers: createHeaders(),
      );

      if (isValidResponse(response)) {
        final data = json.decode(response.body);
        if (data['resultList'] != null) {
          final List<dynamic> comments = data['resultList'];
          return comments.map((json) => Comment.fromJson(json)).toList();
        }
        return [];
      } else {
        throw Exception('Failed to load comments');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Comment> deleteComment(int commentId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$end/$commentId'),
        headers: createHeaders(),
      );

      if (isValidResponse(response)) {
        final data = json.decode(response.body);
        return Comment.fromJson(data);
      } else {
        throw Exception('Failed to delete comment');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
