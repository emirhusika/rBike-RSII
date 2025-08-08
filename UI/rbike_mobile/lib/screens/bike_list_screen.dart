import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rbike_mobile/layouts/master_screen.dart';
import 'package:rbike_mobile/models/bike.dart';
import 'package:rbike_mobile/models/search_result.dart';
import 'package:rbike_mobile/providers/bike_provider.dart';
import 'package:rbike_mobile/providers/cart_provider.dart';
import 'package:rbike_mobile/providers/utils.dart';
import 'package:rbike_mobile/screens/bike_details_screen.dart'; // import za detalje

class BikeListScreen extends StatefulWidget {
  static const String routeName = "/bike";

  const BikeListScreen({Key? key}) : super(key: key);

  @override
  State<BikeListScreen> createState() => _BikeListScreenState();
}

class _BikeListScreenState extends State<BikeListScreen> {
  BikeProvider? _bikeProvider = null;
  CartProvider? _cartProvider = null;
  SearchResult<Bike>? data = null;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bikeProvider = context.read<BikeProvider>();
    _cartProvider = context.read<CartProvider>();
    loadData();
  }

  Future loadData() async {
    var tmpData = await _bikeProvider?.get(filter: {'stateMachine': 'active'});
    setState(() {
      data = tmpData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Bicikli",
      data == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildBikeSearch(),
                Expanded(
                  child: Container(
                    child: GridView(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 4 / 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 30,
                      ),
                      scrollDirection: Axis.horizontal,
                      children: _buildBikeCardList(),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildBikeSearch() {
    return Row(
      children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onSubmitted: (value) async {
                var tmpData = await _bikeProvider?.get(
                  filter: {
                    'fts': _searchController.text,
                    'stateMachine': 'active',
                  },
                );
                setState(() {
                  data = tmpData;
                });
              },
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () async {
              var tmpData = await _bikeProvider?.get(
                filter: {
                  'fts': _searchController.text,
                  'stateMachine': 'active',
                },
              );
              setState(() {
                data = tmpData;
              });
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildBikeCardList() {
    if (data == null || data!.result.isEmpty) {
      return [Center(child: Text('Nema bicikala.'))];
    }

    return data!.result.map((bike) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BikeDetailsScreen(bike: bike),
            ),
          );
        },
        child: Container(
          margin: EdgeInsets.all(8),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    child:
                        bike.image == null
                            ? Placeholder()
                            : imageFromString(bike.image!),
                  ),
                  SizedBox(height: 8),
                  Text(
                    bike.name ?? "",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.access_time_outlined,
                      color: Colors.green[700],
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "${formatNumber(bike.price)} KM/Dan",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
