import 'equipment.dart';

class OrderItem {
  final int? orderItemsId;
  final int orderId;
  final int equipmentId;
  final int quantity;
  final Equipment? equipment;

  OrderItem({
    this.orderItemsId,
    required this.orderId,
    required this.equipmentId,
    required this.quantity,
    this.equipment,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      orderItemsId: json['orderItemsId'],
      orderId: json['orderId'],
      equipmentId: json['equipmentId'],
      quantity: json['quantity'],
      equipment: json['equipment'] != null 
          ? Equipment.fromJson(json['equipment']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderItemsId': orderItemsId,
      'orderId': orderId,
      'equipmentId': equipmentId,
      'quantity': quantity,
    };
  }
} 