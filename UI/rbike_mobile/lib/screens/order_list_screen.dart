import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rbike_mobile/layouts/master_screen.dart';
import 'package:rbike_mobile/models/order.dart';
import 'package:rbike_mobile/models/search_result.dart';
import 'package:rbike_mobile/providers/order_provider.dart';
import 'package:rbike_mobile/providers/auth_provider.dart';
import 'package:rbike_mobile/providers/utils.dart';
import 'package:rbike_mobile/screens/order_details_screen.dart';

class OrderListScreen extends StatefulWidget {
  static const String routeName = "/orders";

  const OrderListScreen({Key? key}) : super(key: key);

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  OrderProvider? _orderProvider = null;
  SearchResult<Order>? data = null;
  bool _isLoading = false;
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    _orderProvider = context.read<OrderProvider>();
    loadData();
  }

  Future loadData() async {
    setState(() => _isLoading = true);

    try {
      var userId = AuthProvider.userId;
      if (userId == null) return;

      var filter = {'userId': userId.toString()};
      if (_selectedStatus != 'All') {
        filter['status'] = _selectedStatus;
      }

      var tmpData = await _orderProvider?.get(filter: filter);

      if (tmpData != null && tmpData.result.isNotEmpty) {
        tmpData.result.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      }

      setState(() {
        data = tmpData;
      });
    } catch (e) {
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Moje narudžbe",
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 249, 248, 248),
              const Color.fromARGB(255, 73, 70, 70),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            _buildStatusFilter(),
            Expanded(
              child:
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : data == null || data!.result.isEmpty
                      ? Center(
                        child: Text(
                          'Nemate narudžbi.',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                      : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: data!.result.length,
                        itemBuilder: (context, index) {
                          return _buildOrderCard(data!.result[index]);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: "Status",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              items: [
                DropdownMenuItem(value: 'All', child: Text('Sve')),
                DropdownMenuItem(value: 'Pending', child: Text('Na čekanju')),
                DropdownMenuItem(value: 'Processed', child: Text('Obrađeno')),
                DropdownMenuItem(value: 'Rejected', child: Text('Odbijeno')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
                loadData();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(order: order),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.orderCode ?? 'N/A',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),

              SizedBox(height: 12),

              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    'Datum: ${_formatDate(order.orderDate)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),

              SizedBox(height: 8),

              Row(
                children: [
                  Icon(Icons.attach_money, size: 16, color: Colors.green[700]),
                  SizedBox(width: 8),
                  Text(
                    'Ukupno: ${formatNumber(order.totalAmount)} KM',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),

              if (order.modifiedDate != null) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.update, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 8),
                    Text(
                      'Ažurirano: ${_formatDate(order.modifiedDate!)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],

              SizedBox(height: 12),

              Row(
                children: [
                  Icon(Icons.inventory_2, size: 16, color: Colors.blue[600]),
                  SizedBox(width: 8),
                  Text(
                    'Broj stavki: ${order.orderItems.length}',
                    style: TextStyle(fontSize: 14, color: Colors.blue[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status) {
      case 'Pending':
        color = Colors.orange;
        text = 'Na čekanju';
        break;
      case 'Processed':
        color = Colors.green;
        text = 'Obrađeno';
        break;
      case 'Rejected':
        color = Colors.red;
        text = 'Odbijeno';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
