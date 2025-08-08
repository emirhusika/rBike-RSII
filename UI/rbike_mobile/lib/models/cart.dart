import 'package:rbike_mobile/models/equipment.dart';

class Cart {
  List<CartItem> items = [];
}

class CartItem {
  CartItem.equipment(this.equipment, this.count);
  
  Equipment? equipment;
  late int count;
  
  bool get isEquipment => equipment != null;
  
  String get name => equipment?.name ?? 'Unknown';
  double get price => equipment?.price ?? 0.0;
  String? get image => equipment?.image;
  int get id => equipment?.equipmentId ?? 0;
}
