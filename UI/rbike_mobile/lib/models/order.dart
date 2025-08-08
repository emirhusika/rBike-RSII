import 'order_item.dart';

class Order {
  final int? orderId;
  final int userId;
  final DateTime orderDate;
  final String status;
  final String? transactionNumber;
  final double totalAmount;
  final String? orderCode;
  final String? deliveryAddress;
  final String? city;
  final String? postalCode;
  final DateTime? modifiedDate;
  final List<OrderItem> orderItems;
  final String? username;

  Order({
    this.orderId,
    required this.userId,
    required this.orderDate,
    required this.status,
    this.transactionNumber,
    required this.totalAmount,
    this.orderCode,
    this.deliveryAddress,
    this.city,
    this.postalCode,
    this.modifiedDate,
    this.orderItems = const [],
    this.username,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'],
      userId: json['userId'],
      orderDate: DateTime.parse(json['orderDate']),
      status: json['status'],
      transactionNumber: json['transactionNumber'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      orderCode: json['orderCode'],
      deliveryAddress: json['deliveryAddress'],
      city: json['city'],
      postalCode: json['postalCode'],
      modifiedDate:
          json['modifiedDate'] != null
              ? DateTime.parse(json['modifiedDate'])
              : null,
      orderItems:
          json['orderItems'] != null
              ? (json['orderItems'] as List)
                  .map((item) => OrderItem.fromJson(item))
                  .toList()
              : [],
      username: json['user']?['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'userId': userId,
      'orderDate': orderDate.toIso8601String(),
      'status': status,
      'transactionNumber': transactionNumber,
      'totalAmount': totalAmount,
      'orderCode': orderCode,
      'deliveryAddress': deliveryAddress,
      'city': city,
      'postalCode': postalCode,
      'modifiedDate': modifiedDate?.toIso8601String(),
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
    };
  }
}
