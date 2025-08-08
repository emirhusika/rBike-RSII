import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rbike_mobile/layouts/master_screen.dart';
import 'package:rbike_mobile/models/equipment.dart';
import 'package:rbike_mobile/models/search_result.dart';
import 'package:rbike_mobile/providers/cart_provider.dart';
import 'package:rbike_mobile/providers/equipment_provider.dart';
import 'package:rbike_mobile/providers/utils.dart';
import 'package:rbike_mobile/screens/equipment_details_screen.dart';

class EquipmentListScreen extends StatefulWidget {
  static const String routeName = "/equipment";

  const EquipmentListScreen({Key? key}) : super(key: key);

  @override
  State<EquipmentListScreen> createState() => _EquipmentListScreenState();
}

class _EquipmentListScreenState extends State<EquipmentListScreen> {
  EquipmentProvider? _equipmentProvider = null;
  CartProvider? _cartProvider = null;
  SearchResult<Equipment>? data = null;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _equipmentProvider = context.read<EquipmentProvider>();
    _cartProvider = context.read<CartProvider>();
    loadData();
  }

  Future loadData() async {
    var tmpData = await _equipmentProvider?.get(filter: {'status': 'Active'});
    setState(() {
      data = tmpData!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Oprema",
      data == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildEquipmentSearch(),
                Expanded(
                  child: Container(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: data!.result.length,
                      itemBuilder: (context, index) {
                        return _buildEquipmentCard(data!.result[index]);
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEquipmentSearch() {
    return Row(
      children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) async {
                var tmpData = await _equipmentProvider?.get(
                  filter: {'status': 'Active', 'name': value},
                );
                setState(() {
                  data = tmpData!;
                });
              },
              decoration: InputDecoration(
                hintText: "Pretraži opremu...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEquipmentCard(Equipment equipment) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EquipmentDetailsScreen(equipment: equipment),
          ),
        );
      },
      child: Container(
        width: 280,
        margin: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                color: Colors.grey[100],
              ),
              child:
                  equipment.image == null
                      ? Icon(
                        Icons.inventory_2,
                        size: 80,
                        color: Colors.grey[400],
                      )
                      : ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: imageFromString(equipment.image!),
                      ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    equipment.name ?? "Nepoznato",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 8),

                  if (equipment.equipmentCategoryName != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        equipment.equipmentCategoryName!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            color: Colors.green[700],
                            size: 20,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "${formatNumber(equipment.price)} KM",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (equipment.stockQuantity ?? 0) > 0
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                (equipment.stockQuantity ?? 0) > 0
                                    ? Colors.green
                                    : Colors.red,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              (equipment.stockQuantity ?? 0) > 0
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              size: 14,
                              color:
                                  (equipment.stockQuantity ?? 0) > 0
                                      ? Colors.green[700]
                                      : Colors.red[700],
                            ),
                            SizedBox(width: 4),
                            Text(
                              (equipment.stockQuantity ?? 0) > 0
                                  ? "Dostupno"
                                  : "Nedostupno",
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    (equipment.stockQuantity ?? 0) > 0
                                        ? Colors.green[700]
                                        : Colors.red[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
