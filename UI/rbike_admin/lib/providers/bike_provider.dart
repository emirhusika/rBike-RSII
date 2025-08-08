import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rbike_admin/models/bike.dart';
import 'package:rbike_admin/providers/base_provider.dart';

class BikeProvider extends BaseProvider<Bike> {
  BikeProvider() : super("Bike");

  @override
  Bike fromJson(data) {
    return Bike.fromJson(data);
  }

  Future<List<String>> getAllowedActions(int bikeId) async {
    final url = Uri.parse('$baseUrl$end/$bikeId/allowedActions');
    final response = await http.get(url, headers: createHeaders());
    if (isValidResponse(response)) {
      final data = jsonDecode(response.body);
      return List<String>.from(data);
    } else {
      throw Exception("Failed to fetch allowed actions");
    }
  }

  Future<void> activate(int bikeId) async {
    final url = Uri.parse('$baseUrl$end/$bikeId/activate');
    final response = await http.put(url, headers: createHeaders());
    if (!isValidResponse(response)) {
      throw Exception("Failed to activate bike");
    }
  }

  Future<void> hide(int bikeId) async {
    final url = Uri.parse('$baseUrl$end/$bikeId/hide');
    final response = await http.put(url, headers: createHeaders());
    if (!isValidResponse(response)) {
      throw Exception("Failed to hide bike");
    }
  }

  Future<void> edit(int bikeId) async {
    final url = Uri.parse('$baseUrl$end/$bikeId/edit');
    final response = await http.put(url, headers: createHeaders());
    if (!isValidResponse(response)) {
      throw Exception("Failed to return bike to draft");
    }
  }
}
