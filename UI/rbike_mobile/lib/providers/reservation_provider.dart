import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rbike_mobile/models/reservation.dart';
import 'package:rbike_mobile/models/search_result.dart';
import 'package:rbike_mobile/providers/base_provider.dart';

class ReservationProvider extends BaseProvider<Reservation> {
  ReservationProvider() : super('Reservation');

  @override
  Reservation fromJson(data) {
    return Reservation.fromJson(data);
  }

  Future<List<Reservation>> getReservationsForDate(
    int bikeId,
    DateTime date,
  ) async {
    final url = Uri.parse(
      '$baseUrl$end/calendar?bikeId=$bikeId&date=${date.toIso8601String()}',
    );
    final response = await http.get(url, headers: createHeaders());
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Reservation.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load reservations: ${response.body}');
    }
  }

  Future<Reservation> insertReservation(Map<String, dynamic> request) async {
    final url = Uri.parse('$baseUrl$end');
    final response = await http.post(
      url,
      headers: createHeaders(),
      body: jsonEncode(request),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return Reservation.fromJson(data);
    } else {
      throw Exception('Failed to create reservation: ${response.body}');
    }
  }

  Future<SearchResult<Reservation>> getUserReservations({
    required int userId,
    int page = 1,
    int pageSize = 10,
  }) async {
    final query = '?userId=$userId&page=$page&pageSize=$pageSize';
    final url = Uri.parse('$baseUrl$end$query');
    final resp = await http.get(url, headers: createHeaders());

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      return SearchResult<Reservation>.fromJson(data, fromJson);
    } else {
      throw Exception('Greška pri dohvaćanju rezervacija korisnika');
    }
  }
}
