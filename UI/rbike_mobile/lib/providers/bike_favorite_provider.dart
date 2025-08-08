import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rbike_mobile/models/bike_favorite.dart';
import 'package:rbike_mobile/providers/base_provider.dart';

class BikeFavoriteProvider extends BaseProvider<BikeFavorite> {
  BikeFavoriteProvider() : super('BikeFavorite');

  @override
  BikeFavorite fromJson(data) {
    return BikeFavorite.fromJson(data);
  }

  Future<bool> isFavorite(int bikeId, int userId) async {
    final url = Uri.parse('$baseUrl$end/check/$bikeId?userId=$userId');
    final response = await http.get(url, headers: createHeaders());
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['isFavorite'] as bool;
    } else {
      throw Exception('Failed to check favorite status: ${response.body}');
    }
  }

  Future<List<BikeFavorite>> getUserFavorites(int userId) async {
    final url = Uri.parse('$baseUrl$end/user?userId=$userId');
    final response = await http.get(url, headers: createHeaders());
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => BikeFavorite.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load user favorites: ${response.body}');
    }
  }

  Future<void> addToFavorites(int bikeId, int userId) async {
    final url = Uri.parse('$baseUrl$end');
    final response = await http.post(
      url,
      headers: createHeaders(),
      body: jsonEncode({
        'bikeId': bikeId,
        'userId': userId,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to add to favorites: ${response.body}');
    }
  }

  Future<void> removeFromFavorites(int bikeId, int userId) async {
    final url = Uri.parse('$baseUrl$end/remove/$bikeId?userId=$userId');
    final response = await http.delete(url, headers: createHeaders());

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to remove from favorites: ${response.body}');
    }
  }
} 