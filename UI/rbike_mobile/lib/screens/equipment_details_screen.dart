import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rbike_mobile/models/equipment.dart';
import 'package:rbike_mobile/providers/cart_provider.dart';
import 'package:rbike_mobile/providers/utils.dart';
import 'package:rbike_mobile/layouts/master_screen.dart';
import 'package:rbike_mobile/screens/cart_screen.dart';
import 'package:rbike_mobile/providers/equipment_provider.dart';

class EquipmentDetailsScreen extends StatefulWidget {
  final Equipment equipment;

  const EquipmentDetailsScreen({Key? key, required this.equipment})
    : super(key: key);

  @override
  State<EquipmentDetailsScreen> createState() => _EquipmentDetailsScreenState();
}

class _EquipmentDetailsScreenState extends State<EquipmentDetailsScreen> {
  CartProvider? _cartProvider = null;
  int _quantity = 1;
  bool _isAddingToCart = false;
  Uint8List? _cachedImageData;
  List<Equipment>? _recommended;
  bool _loadingRecommended = false;
  // 1. Add a local image cache to the state
  Map<int, Uint8List> _recommendedImageCache = {};

  @override
  void initState() {
    super.initState();
    _cartProvider = context.read<CartProvider>();
    _cacheImageData();
    _fetchRecommended();
  }

  void _cacheImageData() {
    if (widget.equipment.image != null) {
      _cachedImageData = base64Decode(widget.equipment.image!);
    }
  }

  Future<void> _fetchRecommended() async {
    setState(() {
      _loadingRecommended = true;
    });
    try {
      final provider = context.read<EquipmentProvider>();
      final rec = await provider.getRecommended(widget.equipment.equipmentId!);
      for (var eq in rec) {
        if (eq.image != null &&
            eq.image!.isNotEmpty &&
            eq.equipmentId != null) {
          try {
            _recommendedImageCache[eq.equipmentId!] = base64Decode(eq.image!);
          } catch (_) {}
        }
      }
      setState(() {
        _recommended = rec;
      });
    } catch (e) {
      setState(() {
        _recommended = [];
      });
    } finally {
      setState(() {
        _loadingRecommended = false;
      });
    }
  }

  Future<void> _showResultDialog(
    String title,
    String content, {
    bool success = true,
  }) async {
    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: success ? Colors.green[50] : Colors.red[50],
            title: Row(
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: success ? Colors.green : Colors.red,
                ),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(color: success ? Colors.green : Colors.red),
                ),
              ],
            ),
            content: Text(content, style: TextStyle(color: Colors.black)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  'OK',
                  style: TextStyle(color: success ? Colors.green : Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _addToCart() async {
    if (_quantity <= 0) {
      await _showResultDialog(
        'Greška',
        'Količina mora biti veća od 0',
        success: false,
      );
      return;
    }

    if (_quantity > (widget.equipment.stockQuantity ?? 0)) {
      await _showResultDialog(
        'Greška',
        'Nema dovoljno proizvoda na stanju',
        success: false,
      );
      return;
    }

    setState(() => _isAddingToCart = true);

    try {
      await _cartProvider?.addToCart(
        widget.equipment.equipmentId!,
        _quantity,
        widget.equipment.name ?? 'Oprema',
        widget.equipment.price ?? 0,
        widget.equipment.image,
      );

      await _showResultDialog(
        'Uspješno',
        'Oprema dodana u korpu',
        success: true,
      );
    } catch (e) {
      await _showResultDialog(
        'Greška',
        'Greška: ${e.toString()}',
        success: false,
      );
    } finally {
      setState(() => _isAddingToCart = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final equipment = widget.equipment;
    return MasterScreen(
      equipment.name ?? 'Detalji opreme',
      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            equipment.image == null
                ? Container(
                  height: 250,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.inventory_2,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                )
                : Image.memory(
                  _cachedImageData!,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.label, size: 28, color: Colors.black54),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          equipment.name ?? '',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8),

                  if (equipment.equipmentCategoryName != null) ...[
                    Row(
                      children: [
                        Icon(Icons.category, size: 20, color: Colors.black54),
                        SizedBox(width: 6),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 255 * 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            equipment.equipmentCategoryName!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                  ],

                  if (equipment.description != null &&
                      equipment.description!.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.description,
                          size: 20,
                          color: Colors.black54,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            equipment.description!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                  ],

                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        size: 24,
                        color: Colors.green[700],
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${formatNumber(equipment.price)} KM',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  Row(
                    children: [
                      Icon(Icons.inventory_2, size: 20, color: Colors.black54),
                      SizedBox(width: 6),
                      Text(
                        (equipment.stockQuantity ?? 0) > 0
                            ? 'Dostupno'
                            : 'Nedostupno',
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              (equipment.stockQuantity ?? 0) > 0
                                  ? Colors.green[700]
                                  : Colors.red[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  Row(
                    children: [
                      Text(
                        'Količina:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 16),
                      IconButton(
                        onPressed:
                            _quantity > 1
                                ? () {
                                  setState(() {
                                    _quantity--;
                                  });
                                }
                                : null,
                        icon: Icon(Icons.remove_circle_outline),
                        color: _quantity > 1 ? Colors.blue : Colors.grey,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _quantity.toString(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed:
                            _quantity < (equipment.stockQuantity ?? 0)
                                ? () {
                                  setState(() {
                                    _quantity++;
                                  });
                                }
                                : null,
                        icon: Icon(Icons.add_circle_outline),
                        color:
                            _quantity < (equipment.stockQuantity ?? 0)
                                ? Colors.blue
                                : Colors.grey,
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed:
                          (equipment.stockQuantity ?? 0) > 0 && !_isAddingToCart
                              ? _addToCart
                              : null,
                      icon:
                          _isAddingToCart
                              ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : Icon(Icons.add_shopping_cart),
                      label: Text(
                        _isAddingToCart
                            ? 'Dodavanje...'
                            : (equipment.stockQuantity ?? 0) > 0
                            ? 'Dodaj u korpu'
                            : 'Nedostupno',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            (equipment.stockQuantity ?? 0) > 0
                                ? Colors.blue
                                : Colors.grey,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 32),

                  if (_loadingRecommended)
                    Center(child: CircularProgressIndicator()),
                  if (!_loadingRecommended &&
                      _recommended != null &&
                      _recommended!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preporučeni proizvodi',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        SizedBox(height: 12),
                        SizedBox(
                          height: 240,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _recommended!.length,
                            itemBuilder: (context, index) {
                              final rec = _recommended![index];
                              return _buildRecommendedCard(rec);
                            },
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
      actionButton: _buildCartButton(),
    );
  }

  Widget _buildCartButton() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final itemCount = cartProvider.cart.items.length;
        return Stack(
          children: [
            IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => CartScreen()),
                );
              },
            ),
            if (itemCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    itemCount.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // 3. Use the cache in _buildRecommendedCard
  Widget _buildRecommendedCard(Equipment equipment) {
    Uint8List? imageData =
        equipment.equipmentId != null
            ? _recommendedImageCache[equipment.equipmentId!]
            : null;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => EquipmentDetailsScreen(equipment: equipment),
          ),
        );
      },
      child: Container(
        width: 180,
        margin: EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 90,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                color: Colors.grey[100],
              ),
              child:
                  imageData == null
                      ? Icon(
                        Icons.inventory_2,
                        size: 50,
                        color: Colors.grey[400],
                      )
                      : ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Image.memory(imageData),
                      ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    equipment.name ?? "Nepoznato",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6),
                  if (equipment.equipmentCategoryName != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
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
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        color: Colors.green[700],
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "${formatNumber(equipment.price)} KM",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
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
