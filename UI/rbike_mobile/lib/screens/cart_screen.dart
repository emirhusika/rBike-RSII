import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rbike_mobile/layouts/master_screen.dart';
import 'package:rbike_mobile/models/cart.dart';
import 'package:rbike_mobile/providers/cart_provider.dart';
import 'package:rbike_mobile/providers/order_provider.dart';
import 'package:rbike_mobile/providers/auth_provider.dart';
import 'package:rbike_mobile/providers/payment_service.dart';
import 'package:rbike_mobile/providers/utils.dart';
import 'package:rbike_mobile/screens/order_list_screen.dart';

class CartScreen extends StatefulWidget {
  static const String routeName = "/cart";

  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late CartProvider _cartProvider;
  late OrderProvider _orderProvider;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cartProvider = context.watch<CartProvider>();
    _orderProvider = context.read<OrderProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Korpa",
      Column(
        children: [
          Expanded(child: _buildProductCardList()),
          _buildTotalSection(),
          _buildBuyButton(),
        ],
      ),
    );
  }

  Widget _buildProductCardList() {
    if (_cartProvider.cart.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Vaša korpa je prazna',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _cartProvider.cart.items.length,
      itemBuilder: (context, index) {
        return _buildProductCard(_cartProvider.cart.items[index]);
      },
    );
  }

  Widget _buildProductCard(CartItem item) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[100],
          ),
          child:
              item.image == null
                  ? Icon(Icons.inventory_2, color: Colors.grey[400])
                  : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imageFromString(item.image!),
                  ),
        ),
        title: Text(item.name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${formatNumber(item.price)} KM'),
            Text(
              'Količina: ${item.count}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${formatNumber(item.price * item.count)} KM',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _cartProvider.removeFromCart(item.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSection() {
    if (_cartProvider.cart.items.isEmpty) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Ukupno:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '${formatNumber(_cartProvider.totalPrice)} KM',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyButton() {
    if (_cartProvider.cart.items.isEmpty) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isProcessing ? null : _processOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child:
              _isProcessing
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Obrađujem...'),
                    ],
                  )
                  : Text(
                    'Naruči (${_cartProvider.totalItems} stavki)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
        ),
      ),
    );
  }

  Future<void> _processOrder() async {
    if (AuthProvider.userId == null) {
      _showErrorDialog('Morate biti prijavljeni da biste napravili narudžbu.');
      return;
    }

    final addressData = await _showDeliveryAddressModal();
    if (addressData == null) {
      return;
    }
    final deliveryAddress = addressData['address'];
    final city = addressData['city'];
    final postalCode = addressData['postalCode'];

    setState(() => _isProcessing = true);

    try {
      final paymentResult = await PaymentService.processPayment(
        _cartProvider.totalPrice,
        AuthProvider.username ?? '',
      );

      if (!paymentResult.success) {
        _showErrorDialog('Greška pri plaćanju: ${paymentResult.message}');
        return;
      }

      final orderData = {
        'userId': AuthProvider.userId,
        'totalAmount': _cartProvider.totalPrice,
        'transactionNumber': paymentResult.paymentIntentId,
        'deliveryAddress': deliveryAddress,
        'city': city,
        'postalCode': postalCode,
        'orderItems':
            _cartProvider.cart.items
                .map((item) => {'equipmentId': item.id, 'quantity': item.count})
                .toList(),
      };

      final order = await _orderProvider.insert(orderData);

      _cartProvider.clearCart();

      _showSuccessDialog(order);
    } catch (e) {
      _showErrorDialog('Greška pri kreiranju narudžbe: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<Map<String, String>?> _showDeliveryAddressModal() async {
    final TextEditingController addressController = TextEditingController();
    final TextEditingController cityController = TextEditingController();
    final TextEditingController postalCodeController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue, size: 24),
                SizedBox(width: 8),
                Text('Adresa za dostavu'),
              ],
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Unesite podatke za dostavu vaše opreme:',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: 'Adresa za dostavu',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Adresa za dostavu je obavezna';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: cityController,
                    decoration: InputDecoration(
                      labelText: 'Grad',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Grad je obavezan';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: postalCodeController,
                    decoration: InputDecoration(
                      labelText: 'Poštanski broj',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Poštanski broj je obavezan';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Otkaži'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState?.validate() == true) {
                    Navigator.of(context).pop({
                      'address': addressController.text.trim(),
                      'city': cityController.text.trim(),
                      'postalCode': postalCodeController.text.trim(),
                    });
                  }
                },
                child: Text('Nastavi'),
              ),
            ],
          ),
    );
  }

  void _showSuccessDialog(dynamic order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 24),
                SizedBox(width: 8),
                Text('Uspješno!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Vaša narudžba je uspješno kreirana.'),
                SizedBox(height: 8),
                Text(
                  'Broj narudžbe: ${order.orderCode ?? 'N/A'}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Status: Na čekanju',
                  style: TextStyle(color: Colors.orange),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(
                    context,
                  ).pushReplacementNamed(OrderListScreen.routeName);
                },
                child: Text('Pogledaj narudžbe'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Nastavi kupovinu'),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error, color: Colors.red, size: 24),
                SizedBox(width: 8),
                Text('Greška'),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }
}
