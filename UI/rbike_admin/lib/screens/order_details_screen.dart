import 'package:flutter/material.dart';
import 'package:rbike_admin/layouts/master_screen.dart';
import 'package:rbike_admin/models/order.dart';
import 'package:rbike_admin/providers/utils.dart';
import 'package:rbike_admin/providers/popup_dialogs.dart';
import 'package:rbike_admin/providers/order_provider.dart';
import 'package:provider/provider.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Order order;
  final VoidCallback? onOrderUpdated;

  const OrderDetailsScreen({Key? key, required this.order, this.onOrderUpdated})
    : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late OrderProvider _orderProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _orderProvider = context.read<OrderProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Detalji narudžbe",
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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderHeader(),
              SizedBox(height: 24),
              _buildOrderInfo(),
              SizedBox(height: 24),
              _buildOrderItems(),
              SizedBox(height: 24),
              if (widget.order.status == 'Pending') _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Container(
      padding: EdgeInsets.all(20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.order.orderCode ?? 'N/A',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              _buildStatusChip(widget.order.status),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Ukupna vrijednost narudžbe: ${formatNumber(widget.order.totalAmount)} KM',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfo() {
    return Container(
      padding: EdgeInsets.all(20),
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
          Text(
            'Informacije o narudžbi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          _buildInfoRow('Korisnik', widget.order.username ?? 'N/A'),
          _buildInfoRow('Datum narudžbe', _formatDate(widget.order.orderDate)),
          if (widget.order.modifiedDate != null)
            _buildInfoRow('Ažurirano', _formatDate(widget.order.modifiedDate!)),
          if (widget.order.deliveryAddress != null)
            _buildInfoRow('Adresa dostave', widget.order.deliveryAddress!),
          if (widget.order.city != null)
            _buildInfoRow('Grad', widget.order.city!),
          if (widget.order.postalCode != null)
            _buildInfoRow('Poštanski broj', widget.order.postalCode!),
          if (widget.order.transactionNumber != null)
            _buildInfoRow('Broj transakcije', widget.order.transactionNumber!),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    return Container(
      padding: EdgeInsets.all(20),
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
          Text(
            'Stavke narudžbe (${widget.order.orderItems.length})',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          if (widget.order.orderItems.isEmpty)
            Text(
              'Nema stavki u narudžbi.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            )
          else
            ...widget.order.orderItems
                .map((item) => _buildOrderItemCard(item))
                .toList(),
        ],
      ),
    );
  }

  Widget _buildOrderItemCard(dynamic item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child:
                item.equipment?.image != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: imageFromString(item.equipment!.image!),
                    )
                    : Icon(Icons.inventory_2, color: Colors.grey[400]),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.equipment?.name ?? 'Nepoznato',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Količina: ${item.quantity}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                if (item.equipment?.price != null)
                  Text(
                    'Cijena: ${formatNumber(item.equipment!.price)} KM',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          if (item.equipment?.price != null)
            Text(
              '${formatNumber(item.equipment!.price * item.quantity)} KM',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(20),
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
          Text(
            'Akcije',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _updateOrderStatus('Processed'),
                  icon: Icon(Icons.check_circle, color: Colors.white),
                  label: Text('Obradi narudžbu'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _updateOrderStatus('Rejected'),
                  icon: Icon(Icons.cancel, color: Colors.white),
                  label: Text('Odbij narudžbu'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
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
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _updateOrderStatus(String newStatus) async {
    String action = newStatus == 'Processed' ? 'obrađiti' : 'odbaciti';

    MyDialogs.showQuestion(
      context,
      'Da li ste sigurni da želite $action narudžbu ${widget.order.orderCode}?',
      () async {
        try {
          await _orderProvider.update(widget.order.orderId!, {
            'status': newStatus,
          });

          String statusText =
              newStatus == 'Processed' ? 'obrađena' : 'odbijena';
          MyDialogs.showSuccess(
            context,
            'Narudžba je uspješno $statusText',
            () {
              Navigator.of(context).pop();
              widget.onOrderUpdated?.call();
            },
          );
        } catch (e) {
          MyDialogs.showError(context, 'Greška pri ažuriranju statusa: $e');
        }
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
