import 'package:rbike_mobile/models/order.dart';
import 'package:rbike_mobile/models/search_result.dart';
import 'package:rbike_mobile/providers/base_provider.dart';

class OrderProvider extends BaseProvider<Order> {
  OrderProvider() : super("Order");

  @override
  Order fromJson(data) {
    return Order.fromJson(data);
  }

  Future<SearchResult<Order>> getUserOrders(int userId, {Map<String, dynamic>? filter}) async {
    return await get(filter: {'userId': userId, ...?filter});
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
}
