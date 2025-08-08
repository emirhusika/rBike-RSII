import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rbike_mobile/providers/auth_provider.dart';
import 'package:rbike_mobile/providers/cart_provider.dart';
import 'package:rbike_mobile/screens/bike_list_screen.dart';
import 'package:rbike_mobile/screens/cart_screen.dart';
import 'package:rbike_mobile/screens/equipment_list_screen.dart';
import 'package:rbike_mobile/screens/favorites_screen.dart';
import 'package:rbike_mobile/screens/my_reservation_screen.dart';
import 'package:rbike_mobile/screens/order_list_screen.dart';
import 'package:rbike_mobile/screens/profile_screen.dart';
import 'package:rbike_mobile/main.dart';

class MasterScreen extends StatefulWidget {
  MasterScreen(this.title, this.child, {super.key, this.actionButton});
  String title;
  Widget child;
  Widget? actionButton;

  @override
  State<MasterScreen> createState() => _MasterScreen();
}

class _MasterScreen extends State<MasterScreen> {
  CartProvider? _cartProvider;

  @override
  Widget build(BuildContext context) {
    _cartProvider = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [if (widget.actionButton != null) widget.actionButton!],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Text("Korpa (${_cartProvider?.cart.items.length ?? 0})"),
              leading: Icon(Icons.shopping_cart_outlined),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => CartScreen()),
                );
              },
            ),
            ListTile(
              title: Text("Bicikli"),
              leading: Icon(Icons.pedal_bike),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => BikeListScreen()),
                );
              },
            ),
            ListTile(
              title: Text("Oprema"),
              leading: Icon(Icons.handyman_outlined),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EquipmentListScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text("Rezervacije"),
              leading: Icon(Icons.history_outlined),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            MyReservationScreen(userId: AuthProvider.userId!),
                  ),
                );
              },
            ),
            ListTile(
              title: Text("Moje narudžbe"),
              leading: Icon(Icons.shopping_bag_outlined),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => OrderListScreen()),
                );
              },
            ),
            ListTile(
              title: Text("Moji favoriti"),
              leading: Icon(Icons.favorite_outline_sharp),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => FavoritesScreen()),
                );
              },
            ),
            ListTile(
              title: Text("Moj profil"),
              leading: Icon(Icons.person_outline),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
            ),
            Divider(),
            ListTile(
              title: Text("Odjavi se"),
              leading: Icon(Icons.logout, color: Colors.red),
              onTap: () {
                AuthProvider.username = null;
                AuthProvider.password = null;
                AuthProvider.userId = null;

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: widget.child),
          // Fixed home button at bottom of every screen
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 255 * 0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                FloatingActionButton(
                  heroTag: "back_button",
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.pop(context);
                    }
                  },
                  backgroundColor: Colors.white,
                  child: Icon(Icons.arrow_back, color: Colors.black),
                  mini: true,
                ),
                // Home button
                FloatingActionButton(
                  heroTag: "home_button",
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => BikeListScreen()),
                    (route) => false,
                  );
                },
                backgroundColor: Colors.white,
                child: Icon(Icons.home, color: Colors.black),
                mini: true,
              ),
                // Shop button (Equipment)
                FloatingActionButton(
                  heroTag: "shop_button",
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EquipmentListScreen(),
                      ),
                    );
                  },
                  backgroundColor: Colors.white,
                  child: Icon(Icons.shopping_bag, color: Colors.black),
                  mini: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
