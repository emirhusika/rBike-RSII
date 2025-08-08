import 'package:flutter/material.dart';
import 'package:rbike_admin/providers/auth_provider.dart';
import 'package:rbike_admin/providers/popup_dialogs.dart';
import 'package:rbike_admin/screens/bike_list_screen.dart';
import 'package:rbike_admin/screens/equipment_list_screen.dart';
import 'package:rbike_admin/screens/reservation_screen.dart';
import 'package:rbike_admin/screens/user_list_screen.dart';
import 'package:rbike_admin/screens/comments_screen.dart';
import 'package:rbike_admin/screens/order_list_screen.dart';
import 'package:rbike_admin/screens/profile_screen.dart';
import 'package:rbike_admin/screens/report_screen.dart';
import 'package:rbike_admin/main.dart';

class MasterScreen extends StatefulWidget {
  MasterScreen(this.title, this.child, {super.key, this.actionButton});
  String title;
  Widget child;
  Widget? actionButton;

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (widget.actionButton != null) widget.actionButton!,
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: TextButton.icon(
              icon: Icon(Icons.logout, color: Colors.red),
              label: Text("odjava", style: TextStyle(color: Colors.red)),
              onPressed: () {
                _showLogoutDialog();
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, const Color.fromARGB(255, 157, 83, 83)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ListView(
            children: [
              ListTile(
                leading: Icon(Icons.arrow_back, color: Colors.white),
                title: Text(
                  "Back",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Future.delayed(Duration(milliseconds: 300), () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.people, color: Colors.white),
                title: Text(
                  "Korisnici",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => UserListScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.directions_bike, color: Colors.white),
                title: Text(
                  "Bicikli",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => BikeListScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.build, color: Colors.white),
                title: Text(
                  "Oprema",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EquipmentListScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.access_time_outlined, color: Colors.white),
                title: Text(
                  "Rezervacije",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ReservationScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.comment, color: Colors.white),
                title: Text(
                  "Komentari",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => CommentsScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.shopping_cart, color: Colors.white),
                title: Text(
                  "Narudžbe",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => OrderListScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.insert_chart, color: Colors.white),
                title: Text(
                  "Izvještaji",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ReportScreen()),
                  );
                },
              ),
              const Divider(color: Colors.white70, thickness: 1, height: 32),
              ListTile(
                leading: Icon(Icons.person, color: Colors.white),
                title: Text(
                  "Moj profil",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: widget.child,
    );
  }

  void _showLogoutDialog() {
    MyDialogs.showQuestion(
      context,
      "Da li ste sigurni da se želite odjaviti?",
      () {
        AuthProvider.username = null;
        AuthProvider.password = null;

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
        );
      },
    );
  }
}
