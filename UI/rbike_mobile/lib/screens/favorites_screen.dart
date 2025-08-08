import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rbike_mobile/models/bike_favorite.dart';
import 'package:rbike_mobile/providers/auth_provider.dart';
import 'package:rbike_mobile/providers/bike_favorite_provider.dart';
import 'package:rbike_mobile/providers/utils.dart';
import 'package:rbike_mobile/screens/bike_details_screen.dart';
import 'package:rbike_mobile/layouts/master_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final BikeFavoriteProvider _bikeFavoriteProvider = BikeFavoriteProvider();
  List<BikeFavorite> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    if (AuthProvider.userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final favorites = await _bikeFavoriteProvider.getUserFavorites(
        AuthProvider.userId!,
      );

      final activeFavorites =
          favorites.where((f) => f.bike?.stateMachine == 'active').toList();
      if (mounted) {
        setState(() {
          _favorites = activeFavorites;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška pri učitavanju favorita: ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _removeFavorite(BikeFavorite favorite) async {
    try {
      await _bikeFavoriteProvider.removeFromFavorites(
        favorite.bikeId!,
        AuthProvider.userId!,
      );
      if (mounted) {
        setState(() {
          _favorites.removeWhere((f) => f.favoriteId == favorite.favoriteId);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Uklonjeno iz favorita')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška pri uklanjanju: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      'Moji favoriti',
      _isLoading
          ? Center(child: CircularProgressIndicator())
          : AuthProvider.userId == null
          ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Prijavite se da vidite svoje favorite',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          )
          : _favorites.isEmpty
          ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Nemate favorita',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Dodajte bicikle u favorite da ih vidite ovdje',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          )
          : RefreshIndicator(
            onRefresh: _loadFavorites,
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final favorite = _favorites[index];
                final bike = favorite.bike;

                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading:
                        bike?.image != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                base64Decode(bike!.image!),
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            )
                            : Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.directions_bike,
                                color: Colors.grey[600],
                              ),
                            ),
                    title: Text(bike?.name ?? 'Nepoznat bicikl'),
                    subtitle: Text(
                      'Cijena: ${formatNumber(bike?.price ?? 0)} KM',
                      style: TextStyle(color: Colors.green[700]),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.favorite, color: Colors.red),
                      onPressed: () => _removeFavorite(favorite),
                    ),
                    onTap: () {
                      if (bike != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BikeDetailsScreen(bike: bike),
                          ),
                        ).then((_) => _loadFavorites());
                      }
                    },
                  ),
                );
              },
            ),
          ),
      actionButton: IconButton(
        icon: Icon(Icons.refresh),
        onPressed: _loadFavorites,
      ),
    );
  }
}
