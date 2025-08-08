import 'package:flutter/material.dart';
import 'package:rbike_mobile/models/equipment.dart';
import 'package:rbike_mobile/models/cart.dart';
import 'package:flutter/widgets.dart';
import 'package:collection/collection.dart';

class CartProvider with ChangeNotifier {
  Cart cart = Cart();

  addToCart(
    int equipmentId,
    int quantity,
    String name,
    double price,
    String? image,
  ) {
    CartItem? existingItem = cart.items.firstWhereOrNull(
      (item) => item.isEquipment && item.id == equipmentId,
    );

    if (existingItem != null) {
      existingItem.count += quantity;
    } else {
      Equipment equipment = Equipment(
        equipmentId: equipmentId,
        name: name,
        price: price,
        image: image,
      );
      cart.items.add(CartItem.equipment(equipment, quantity));
    }
    notifyListeners();
  }

  removeFromCart(int equipmentId) {
    cart.items.removeWhere(
      (item) => item.isEquipment && item.id == equipmentId,
    );
    notifyListeners();
  }

  CartItem? findInCart(int equipmentId) {
    CartItem? item = cart.items.firstWhereOrNull(
      (item) => item.isEquipment && item.id == equipmentId,
    );
    return item;
  }

  double get totalPrice {
    return cart.items.fold(0.0, (sum, item) => sum + (item.price * item.count));
  }

  int get totalItems {
    return cart.items.fold(0, (sum, item) => sum + item.count);
  }

  void clearCart() {
    cart.items.clear();
    notifyListeners();
  }
}
