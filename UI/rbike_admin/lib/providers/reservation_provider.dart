import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rbike_admin/models/reservation.dart';
import 'package:rbike_admin/models/search_result.dart';
import 'package:rbike_admin/providers/base_provider.dart';

class ReservationProvider extends BaseProvider<Reservation> {
  ReservationProvider() : super("Reservation");

  @override
  Reservation fromJson(data) {
    return Reservation.fromJson(data);
  }

  Future<SearchResult<Reservation>> getActiveReservations({
    required int page,
    required int pageSize,
    String? username,
  }) async {
    var url = "$baseUrl$end/active?page=$page&pageSize=$pageSize";
    if (username != null && username.isNotEmpty) {
      url += "&username=$username";
    }
    var uri = Uri.parse(url);
    var response = await http.get(uri, headers: createHeaders());

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      var result = SearchResult<Reservation>();
      result.count = data['count'];
      for (var item in data['resultList']) {
        result.result.add(fromJson(item));
      }
      return result;
    } else {
      throw Exception("Neuspješno dohvatanje aktivnih rezervacija");
    }
  }

  Future<SearchResult<Reservation>> getCompletedReservations({
    required int page,
    required int pageSize,
    String? username,
  }) async {
    var url = "$baseUrl$end/completed?page=$page&pageSize=$pageSize";
    if (username != null && username.isNotEmpty) {
      url += "&username=$username";
    }
    var uri = Uri.parse(url);
    var response = await http.get(uri, headers: createHeaders());

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      var result = SearchResult<Reservation>();
      result.count = data['count'];
      for (var item in data['resultList']) {
        result.result.add(fromJson(item));
      }
      return result;
    } else {
      throw Exception("Neuspješno dohvatanje obrađenih rezervacija");
    }
  }

  Future<Reservation> accept(int id) async {
    var url = "$baseUrl$end/$id/accept";
    var response = await http.put(Uri.parse(url), headers: createHeaders());
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Neuspješno prihvatanje rezervacije");
    }
  }

  Future<Reservation> reject(int id) async {
    var url = "$baseUrl$end/$id/reject";
    var response = await http.put(Uri.parse(url), headers: createHeaders());
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Neuspješno odbijanje rezervacije");
    }
  }
}
