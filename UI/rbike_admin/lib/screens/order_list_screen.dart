import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rbike_admin/layouts/master_screen.dart';
import 'package:rbike_admin/models/order.dart';
import 'package:rbike_admin/models/search_result.dart';
import 'package:rbike_admin/providers/order_provider.dart';
import 'package:rbike_admin/providers/utils.dart';
import 'package:rbike_admin/screens/order_details_screen.dart';
import 'package:rbike_admin/providers/popup_dialogs.dart';
import 'package:rbike_admin/widgets/pagination_widget.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  late OrderProvider provider;
  SearchResult<Order>? result = null;
  bool _isLoading = false;

  int _currentPage = 1;
  final int _pageSize = 10;

  TextEditingController _orderCodeController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  String _selectedStatus = 'All';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    provider = context.read<OrderProvider>();
  }

  @override
  void initState() {
    super.initState();
    provider = context.read<OrderProvider>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      var filter = {
        'orderCode': _orderCodeController.text,
        'username': _usernameController.text,
        'page': _currentPage,
        'pageSize': _pageSize,
      };

      if (_selectedStatus != 'All') {
        filter['status'] = _selectedStatus;
      }

      result = await provider.get(filter: filter);
    } catch (e) {
      MyDialogs.showError(context, 'Greška pri učitavanju narudžbi: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateOrderStatus(Order order, String newStatus) async {
    try {
      if (newStatus == 'Processed') {
        await provider.processOrder(order.orderId!);
      } else if (newStatus == 'Rejected') {
        await provider.rejectOrder(order.orderId!);
      }
      await _loadData();

      String statusText = newStatus == 'Processed' ? 'obrađena' : 'odbijena';
      MyDialogs.showSuccess(context, 'Narudžba je uspješno $statusText', () {});
    } catch (e) {
      MyDialogs.showError(context, 'Greška pri ažuriranju statusa: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Upravljanje narudžbama",
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
            _buildSearch(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildResultView(),
                    const SizedBox(height: 20),
                    _buildPaginationControls(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _orderCodeController,
                  decoration: InputDecoration(
                    labelText: "Broj narudžbe",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: "Korisnik",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
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
                    DropdownMenuItem(value: 'All', child: Text('Svi statusi')),
                    DropdownMenuItem(
                      value: 'Pending',
                      child: Text('Na čekanju'),
                    ),
                    DropdownMenuItem(
                      value: 'Processed',
                      child: Text('Obrađeno'),
                    ),
                    DropdownMenuItem(
                      value: 'Rejected',
                      child: Text('Odbijeno'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                      _currentPage = 1;
                    });
                    _loadData();
                  },
                ),
              ),
              SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  setState(() {
                    _currentPage = 1;
                  });
                  await _loadData();
                },
                icon: Icon(Icons.search),
                label: Text("Pretraga"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (result == null || result!.result.isEmpty) {
      return const Center(
        child: Text('Nema narudžbi.', style: TextStyle(fontSize: 16)),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
        ),
        child: DataTable(
          showCheckboxColumn: false,
          columnSpacing: 16,
          horizontalMargin: 16,
          columns: [
            DataColumn(
              label: Expanded(
                child: Text(
                  "Broj narudžbe",
                  style: TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  "Korisnik",
                  style: TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  "Datum",
                  style: TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  "Iznos",
                  style: TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  "Status",
                  style: TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  "Adresa dostave",
                  style: TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  "Transakcija",
                  style: TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  "Akcije",
                  style: TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
          rows:
              result!.result.map((order) {
                return DataRow(
                  onSelectChanged: (selected) {
                    if (selected == true) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) => OrderDetailsScreen(
                                order: order,
                                onOrderUpdated: () => _loadData(),
                              ),
                        ),
                      );
                    }
                  },
                  cells: [
                    DataCell(
                      Text(
                        order.orderCode ?? 'N/A',
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DataCell(
                      Text(
                        order.username ?? 'N/A',
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DataCell(
                      Text(
                        _formatDate(order.orderDate),
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DataCell(
                      Text(
                        '${formatNumber(order.totalAmount)} KM',
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DataCell(_buildStatusChip(order.status)),
                    DataCell(
                      Text(
                        order.deliveryAddress ?? 'N/A',
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DataCell(
                      order.transactionNumber != null
                          ? Text(
                            order.transactionNumber!,
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'monospace',
                            ),
                            overflow: TextOverflow.ellipsis,
                          )
                          : Text(
                            'N/A',
                            style: TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                    ),
                    DataCell(
                      order.status == 'Pending'
                          ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                onPressed:
                                    () => _showStatusUpdateDialog(
                                      order,
                                      'Processed',
                                    ),
                                tooltip: 'Obradi',
                                padding: EdgeInsets.all(4),
                                constraints: BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                onPressed:
                                    () => _showStatusUpdateDialog(
                                      order,
                                      'Rejected',
                                    ),
                                tooltip: 'Odbij',
                                padding: EdgeInsets.all(4),
                                constraints: BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                            ],
                          )
                          : Text(
                            order.status == 'Processed'
                                ? 'Obrađeno'
                                : 'Odbijeno',
                            style: TextStyle(
                              color:
                                  order.status == 'Processed'
                                      ? Colors.green
                                      : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                    ),
                  ],
                );
              }).toList(),
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
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  void _showStatusUpdateDialog(Order order, String newStatus) {
    String action = newStatus == 'Processed' ? 'obraditi' : 'odbaciti';

    MyDialogs.showQuestion(
      context,
      'Da li ste sigurni da želite $action narudžbu ${order.orderCode}?',
      () => _updateOrderStatus(order, newStatus),
    );
  }

  Widget _buildPaginationControls() {
    return PaginationWidget(
      currentPage: _currentPage,
      totalCount: result?.count ?? 0,
      pageSize: _pageSize,
      isLoading: _isLoading,
      onPageChanged: (newPage) {
        setState(() => _currentPage = newPage);
        _loadData();
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
