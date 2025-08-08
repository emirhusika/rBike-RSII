import 'package:rbike_admin/models/order.dart';
import 'package:rbike_admin/models/search_result.dart';
import 'package:rbike_admin/providers/base_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderProvider extends BaseProvider<Order> {
  OrderProvider() : super("Order");

  @override
  Order fromJson(data) {
    return Order.fromJson(data);
  }

  Future<SearchResult<Order>> getPendingOrders({Map<String, dynamic>? filter}) async {
    return await get(filter: {'status': 'Pending', ...?filter});
  }

  Future<SearchResult<Order>> getProcessedOrders({Map<String, dynamic>? filter}) async {
    return await get(filter: {'status': 'Processed', ...?filter});
  }

  Future<SearchResult<Order>> getRejectedOrders({Map<String, dynamic>? filter}) async {
    return await get(filter: {'status': 'Rejected', ...?filter});
  }

  Future<Order> processOrder(int orderId) async {
    var url = "$baseUrl$end/$orderId/process";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.put(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw new Exception("Unknown error");
    }
  }

  Future<Order> rejectOrder(int orderId) async {
    var url = "$baseUrl$end/$orderId/reject";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.put(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw new Exception("Unknown error");
    }
  }
} 