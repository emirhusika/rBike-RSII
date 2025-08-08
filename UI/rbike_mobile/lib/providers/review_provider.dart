import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rbike_mobile/models/review.dart';
import 'package:rbike_mobile/providers/base_provider.dart';
import 'package:rbike_mobile/providers/utils.dart';

class ReviewProvider extends BaseProvider<Review> {
  ReviewProvider() : super("Review");

  @override
  Review fromJson(data) {
    return Review.fromJson(data);
  }

  Future<List<Review>> getReviewsForBike(int bikeId) async {
    try {
      final result = await get(filter: {'bikeId': bikeId});
      return result.result;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<double> getAverageRating(int bikeId) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}Review/average/$bikeId'),
        headers: createHeaders(),
      );

      if (response.statusCode == 200) {
        return double.parse(response.body);
      } else {
        return 0.0;
      }
    } catch (e) {
      return 0.0;
    }
  }

  Future<Review?> getUserReview(int bikeId, int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}Review/user/$bikeId/$userId'),
        headers: createHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data != null ? Review.fromJson(data) : null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<Review> addReview(int bikeId, int userId, int rating) async {
    try {
      return await insert({
        'bikeId': bikeId,
        'userId': userId,
        'rating': rating,
      });
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
} 