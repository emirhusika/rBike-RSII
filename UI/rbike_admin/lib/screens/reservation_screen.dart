import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rbike_admin/layouts/master_screen.dart';
import 'package:rbike_admin/models/reservation.dart';
import 'package:rbike_admin/models/search_result.dart';
import 'package:rbike_admin/providers/popup_dialogs.dart';
import 'package:rbike_admin/providers/reservation_provider.dart';
import 'package:rbike_admin/widgets/pagination_widget.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({Key? key}) : super(key: key);

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  late ReservationProvider _reservationProvider;
  SearchResult<Reservation>? _reservationResult;
  bool _isLoading = false;
  String _currentStatusFilter = "Active";
  final TextEditingController _searchController = TextEditingController();

  int _currentPage = 1;
  final int _pageSize = 9;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reservationProvider = context.read<ReservationProvider>();
    _loadReservations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReservations() async {
    setState(() => _isLoading = true);

    try {
      SearchResult<Reservation> result;
      final username =
          _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim();

      if (_currentStatusFilter == "Active") {
        result = await _reservationProvider.getActiveReservations(
          page: _currentPage,
          pageSize: _pageSize,
          username: username,
        );
      } else {
        result = await _reservationProvider.getCompletedReservations(
          page: _currentPage,
          pageSize: _pageSize,
          username: username,
        );
      }

      setState(() => _reservationResult = result);
    } catch (e) {
      MyDialogs.showError(context, e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onStatusFilterChanged(String status) {
    setState(() {
      _currentStatusFilter = status;
      _currentPage = 1;
      _searchController.clear();
    });
    _loadReservations();
  }

  Future<void> _acceptReservation(int id) async {
    try {
      await _reservationProvider.accept(id);
      MyDialogs.showSuccess(
        context,
        "Rezervacija prihvaćena.",
        _loadReservations,
      );
    } catch (e) {
      MyDialogs.showError(context, e.toString());
    }
  }

  Future<void> _rejectReservation(int id) async {
    try {
      await _reservationProvider.reject(id);
      MyDialogs.showSuccess(
        context,
        "Rezervacija odbijena.",
        _loadReservations,
      );
    } catch (e) {
      MyDialogs.showError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Rezervacije",
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF9F8F8), Color(0xFF494646)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            _buildFilterRow(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildContent(),
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

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pretraži rezervacije po korisničkom imenu...',
                prefixIcon: Icon(Icons.search),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _currentPage = 1;
                            });
                            _loadReservations();
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _currentPage = 1;
                });
                _loadReservations();
              },
            ),
          ),
          SizedBox(width: 16),
          _buildFilterButton("Active"),
          SizedBox(width: 8),
          _buildFilterButton("Processed"),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String status) {
    return TextButton(
      onPressed: () => _onStatusFilterChanged(status),
      child: Text(
        status,
        style: TextStyle(
          color:
              _currentStatusFilter == status
                  ? const Color.fromARGB(134, 252, 1, 1)
                  : const Color.fromARGB(255, 84, 82, 82),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reservationResult == null || _reservationResult!.result.isEmpty) {
      return const Center(child: Text('Nema rezervacija.'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
        ),
        child: _buildReservationTable(),
      ),
    );
  }

  Widget _buildReservationTable() {
    return DataTable(
      headingRowColor: WidgetStateProperty.resolveWith(
        (states) => Colors.blueGrey.shade200,
      ),
      columns: [
        const DataColumn(label: Text('Biciklo')),
        const DataColumn(label: Text('Korisnik')),
        const DataColumn(label: Text('Rezervacija od')),
        const DataColumn(label: Text('Rezervacija do')),
        const DataColumn(label: Text('Status')),
        if (_currentStatusFilter == "Active")
          const DataColumn(label: Text('Akcija')),
      ],
      rows:
          _reservationResult!.result.map((r) {
            return DataRow(
              cells: [
                DataCell(Text(r.bikeName ?? 'Nepoznato')),
                DataCell(Text(r.username ?? 'Nepoznato')),
                DataCell(
                  Text(
                    r.startDateTime != null
                        ? DateFormat(
                          'dd.MM.yyyy HH:mm',
                        ).format(r.startDateTime!)
                        : '-',
                  ),
                ),
                DataCell(
                  Text(
                    r.endDateTime != null
                        ? DateFormat('dd.MM.yyyy HH:mm').format(r.endDateTime!)
                        : '-',
                  ),
                ),
                DataCell(Text(r.status ?? '')),
                if (_currentStatusFilter == "Active")
                  DataCell(
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => _acceptReservation(r.reservationId!),
                          child: const Text("Prihvati"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _rejectReservation(r.reservationId!),
                          child: const Text("Odbij"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }).toList(),
    );
  }

  Widget _buildPaginationControls() {
    return PaginationWidget(
      currentPage: _currentPage,
      totalCount: _reservationResult?.count ?? 0,
      pageSize: _pageSize,
      isLoading: _isLoading,
      onPageChanged: (newPage) {
        setState(() => _currentPage = newPage);
        _loadReservations();
      },
    );
  }
}
