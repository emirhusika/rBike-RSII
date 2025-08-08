import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rbike_mobile/models/reservation.dart';
import 'package:rbike_mobile/providers/reservation_provider.dart';
import 'package:rbike_mobile/layouts/master_screen.dart';

enum SortOrder { newest, oldest }

class MyReservationScreen extends StatefulWidget {
  final int userId;
  const MyReservationScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<MyReservationScreen> createState() => _MyReservationScreenState();
}

class _MyReservationScreenState extends State<MyReservationScreen> {
  final ReservationProvider _reservationProvider = ReservationProvider();

  List<Reservation> _reservations = [];
  bool _isLoading = false;
  SortOrder _sortOrder = SortOrder.newest;

  @override
  void initState() {
    super.initState();
    print("Otvaram MyReservationScreen za userId: ${widget.userId}");
    _loadReservations();
  }

  Future<void> _loadReservations({bool reset = false}) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    if (reset) _reservations.clear();

    try {
      final result = await _reservationProvider.getUserReservations(
        userId: widget.userId,
        page: 1,
        pageSize: 1000,
      );
      var fetched = result.result;
      fetched.sort(
        (a, b) =>
            _sortOrder == SortOrder.newest
                ? b.createdAt!.compareTo(a.createdAt!)
                : a.createdAt!.compareTo(b.createdAt!),
      );
      setState(() => _reservations = fetched);
    } catch (e) {
      print('Greška pri učitavanju rezervacija: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _changeSortOrder(SortOrder newOrder) {
    if (_sortOrder != newOrder) {
      setState(() => _sortOrder = newOrder);
      _loadReservations(reset: true);
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'processed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'active':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildReservationTile(Reservation r) {
    final statusColor = _getStatusColor(r.status);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            r.bike?.image != null
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    base64Decode(r.bike!.image!),
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                )
                : Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.directions_bike,
                    size: 40,
                    color: Colors.grey[500],
                  ),
                ),
            SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.bikeName ?? 'Bicikl',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Od: ${r.startDateTime?.toLocal().toString().substring(0, 16) ?? '-'}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Do: ${r.endDateTime?.toLocal().toString().substring(0, 16) ?? '-'}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.info, size: 16, color: statusColor),
                      SizedBox(width: 4),
                      Text(
                        r.status ?? '-',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4),
                      Text(
                        r.createdAt != null
                            ? r.createdAt!.toLocal().toString().substring(0, 16)
                            : '-',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Moje rezervacije",
      RefreshIndicator(
        onRefresh: () => _loadReservations(reset: true),
        child:
            _isLoading && _reservations.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                  itemCount: _reservations.length,
                  itemBuilder:
                      (ctx, idx) => _buildReservationTile(_reservations[idx]),
                ),
      ),
      actionButton: PopupMenuButton<SortOrder>(
        onSelected: _changeSortOrder,
        icon: const Icon(Icons.sort),
        itemBuilder:
            (_) => const [
              PopupMenuItem(value: SortOrder.newest, child: Text("Najnovije")),
              PopupMenuItem(value: SortOrder.oldest, child: Text("Najstarije")),
            ],
      ),
    );
  }
}
