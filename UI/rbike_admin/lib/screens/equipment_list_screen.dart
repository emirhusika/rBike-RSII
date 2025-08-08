import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rbike_admin/layouts/master_screen.dart';
import 'package:rbike_admin/models/equipment.dart';
import 'package:rbike_admin/models/search_result.dart';
import 'package:rbike_admin/providers/equipment_provider.dart';
import 'package:rbike_admin/providers/utils.dart';
import 'package:rbike_admin/providers/popup_dialogs.dart';
import 'package:rbike_admin/screens/equipment_details_screen.dart';
import 'package:rbike_admin/widgets/pagination_widget.dart';

class EquipmentListScreen extends StatefulWidget {
  const EquipmentListScreen({super.key});

  @override
  State<EquipmentListScreen> createState() => _EquipmentListScreenState();
}

class _EquipmentListScreenState extends State<EquipmentListScreen> {
  late EquipmentProvider provider;
  SearchResult<Equipment>? result = null;
  bool _isLoading = false;

  int _currentPage = 1;
  final int _pageSize = 9;

  TextEditingController _nameController = TextEditingController();
  String _selectedStatus = 'Active';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    provider = context.read<EquipmentProvider>();
  }

  @override
  void initState() {
    super.initState();
    provider = context.read<EquipmentProvider>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      var filter = {
        'name': _nameController.text,
        'status': _selectedStatus,
        'page': _currentPage,
        'pageSize': _pageSize,
      };

      result = await provider.get(filter: filter);
    } catch (e) {
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleStatus(Equipment equipment) async {
    try {
      String newStatus = equipment.status == 'Active' ? 'Inactive' : 'Active';

      await provider.update(equipment.equipmentId!, {
        'name': equipment.name,
        'description': equipment.description,
        'price': equipment.price,
        'status': newStatus,
        'stockQuantity': equipment.stockQuantity,
        'equipmentCategoryId': equipment.equipmentCategoryId,
        if (equipment.image != null) 'image': equipment.image,
      });

      await _loadData();

      MyDialogs.showSuccess(
        context,
        'Oprema je ${newStatus == 'Active' ? 'aktivirana' : 'deaktivirana'}',
        () {},
      );
    } catch (e) {
      MyDialogs.showError(context, 'Greška: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Lista opreme",
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
      padding: const EdgeInsets.all(9.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Naziv"),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: "Status",
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'Active', child: Text('Aktivni')),
                DropdownMenuItem(value: 'Inactive', child: Text('Neaktivni')),
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
          SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () async {
              setState(() {
                _currentPage = 1;
              });
              await _loadData();
            },
            icon: Icon(Icons.search),
            label: Text("Pretraga"),
          ),
          SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EquipmentDetailsScreen(),
                ),
              );
            },
            icon: Icon(Icons.add),
            label: Text("Dodaj"),
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
      return Center(
        child: Text(
          _selectedStatus == 'Active'
              ? 'Nema aktivne opreme.'
              : 'Nema neaktivne opreme.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return Container(
      width: double.infinity,
      child: SingleChildScrollView(
        child: DataTable(
          showCheckboxColumn: false,
          columns: [
            DataColumn(label: Text("Naziv")),
            DataColumn(label: Text("Opis")),
            DataColumn(label: Text("Cijena")),
            DataColumn(label: Text("Status")),
            DataColumn(label: Text("Količina")),
            DataColumn(label: Text("Kategorija")),
            DataColumn(label: Text("Slika")),
            DataColumn(label: Text("Akcije")),
          ],
          rows:
              result!.result
                  .map(
                    (e) => DataRow(
                      onSelectChanged:
                          (selected) => {
                            if (selected == true)
                              {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder:
                                        (context) => EquipmentDetailsScreen(
                                          equipment: e,
                                        ),
                                  ),
                                ),
                              },
                          },
                      cells: [
                        DataCell(Text(e.name ?? "")),
                        DataCell(Text(e.description ?? "")),
                        DataCell(Text(formatNumber(e.price ?? 0))),
                        DataCell(
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  e.status == 'Active'
                                      ? Colors.green
                                      : Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              e.status == 'Active' ? 'Aktivan' : 'Neaktivan',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        DataCell(Text(e.stockQuantity?.toString() ?? "")),
                        DataCell(Text(e.equipmentCategoryName ?? "")),
                        DataCell(
                          e.image != null
                              ? Container(
                                width: 100,
                                height: 100,
                                child: imageFromString(e.image!),
                              )
                              : Text(""),
                        ),
                        DataCell(
                          ElevatedButton.icon(
                            onPressed: () => _toggleStatus(e),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  e.status == 'Active'
                                      ? Colors.orange
                                      : Colors.green,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                            ),
                            icon: Icon(
                              e.status == 'Active'
                                  ? Icons.block
                                  : Icons.check_circle_outline,
                              size: 16,
                            ),
                            label: Text(
                              e.status == 'Active'
                                  ? 'Deaktiviraj'
                                  : 'Aktiviraj',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList()
                  .cast<DataRow>(),
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    return IconPaginationWidget(
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
}
