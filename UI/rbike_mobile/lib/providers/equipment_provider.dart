import 'package:rbike_mobile/models/equipment.dart';
import 'package:rbike_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EquipmentProvider extends BaseProvider<Equipment> {
  EquipmentProvider() : super('Equipment');

  @override
  Equipment fromJson(data) {
    return Equipment.fromJson(data);
  }

  Future<List<Equipment>> getRecommended(int equipmentId) async {
    final url = Uri.parse('$baseUrl$end/$equipmentId/recommend');
    final response = await http.get(url, headers: createHeaders());
    if (response.statusCode < 299) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => Equipment.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load recommended equipment");
    }
  }
}
