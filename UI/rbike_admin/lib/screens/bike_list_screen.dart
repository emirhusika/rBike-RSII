import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rbike_admin/layouts/master_screen.dart';
import 'package:rbike_admin/models/bike.dart';
import 'package:rbike_admin/models/search_result.dart';
import 'package:rbike_admin/providers/bike_provider.dart';
import 'package:rbike_admin/providers/utils.dart';
import 'package:rbike_admin/screens/bike_details_screen.dart';
import 'package:rbike_admin/widgets/pagination_widget.dart';

class BikeListScreen extends StatefulWidget {
  const BikeListScreen({super.key});

  @override
  State<BikeListScreen> createState() => _BikeListScreenState();
}

class _BikeListScreenState extends State<BikeListScreen> {
  late BikeProvider provider;
  SearchResult<Bike>? result = null;
  bool _isLoading = false;

  int _currentPage = 1;
  final int _pageSize = 9;

  TextEditingController _ftsEditingController = TextEditingController();
  TextEditingController _bikeCodeController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    provider = context.read<BikeProvider>();
  }

  @override
  void initState() {
    super.initState();
    provider = context.read<BikeProvider>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      var filter = {
        'fts': _ftsEditingController.text,
        'bikeCode': _bikeCodeController.text,
        'page': _currentPage,
        'pageSize': _pageSize,
      };

      result = await provider.get(filter: filter);
    } catch (e) {
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Lista bicikala",
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
              controller: _ftsEditingController,
              decoration: InputDecoration(labelText: "Naziv"),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _bikeCodeController,
              decoration: InputDecoration(labelText: "Šifra"),
            ),
          ),
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
                MaterialPageRoute(builder: (context) => BikeDetailsScreen()),
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
      return const Center(child: Text('Nema bicikala.'));
    }

    return Container(
      width: double.infinity,
      child: SingleChildScrollView(
        child: DataTable(
          showCheckboxColumn: false,
          columns: [
            DataColumn(label: Text("Naziv")),
            DataColumn(label: Text("Šifra")),
            DataColumn(label: Text("Cijena")),
            DataColumn(label: Text("Slika")),
            DataColumn(label: Text("Stanje")),
            DataColumn(label: Text("Akcija")),
          ],
          rows:
              result!.result.map((e) {
                return DataRow(
                  onSelectChanged: (selected) {
                    if (selected == true) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => BikeDetailsScreen(bike: e),
                        ),
                      );
                    }
                  },
                  cells: [
                    DataCell(Text(e.name ?? "")),
                    DataCell(Text(e.bikeCode ?? "")),
                    DataCell(Text(formatNumber(e.price))),
                    DataCell(
                      e.image != null
                          ? Container(
                            width: 100,
                            height: 100,
                            child: imageFromString(e.image!),
                          )
                          : Text(""),
                    ),
                    DataCell(Text(e.stateMachine ?? "")),
                    DataCell(
                      FutureBuilder<List<String>>(
                        future: provider.getAllowedActions(e.bikeId!),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          }
                          final allowed = snapshot.data!;
                          if (allowed.contains('ActivateAsync')) {
                            return ElevatedButton(
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: Text('Potvrda'),
                                        content: Text(
                                          'Jeste li sigurni da želite aktivirati ovaj bicikl?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.of(
                                                  context,
                                                ).pop(false),
                                            child: Text('Ne'),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.of(
                                                  context,
                                                ).pop(true),
                                            child: Text('Da'),
                                          ),
                                        ],
                                      ),
                                );
                                if (confirmed == true) {
                                  await provider.activate(e.bikeId!);
                                  await _loadData();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[700],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                elevation: 2,
                              ),
                              child: Text(
                                'Aktiviraj',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          } else if (allowed.contains('HideAsync')) {
                            return ElevatedButton(
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: Text('Potvrda'),
                                        content: Text(
                                          'Jeste li sigurni da želite deaktivirati ovaj bicikl?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.of(
                                                  context,
                                                ).pop(false),
                                            child: Text('Ne'),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.of(
                                                  context,
                                                ).pop(true),
                                            child: Text('Da'),
                                          ),
                                        ],
                                      ),
                                );
                                if (confirmed == true) {
                                  await provider.hide(e.bikeId!);
                                  await _loadData();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[700],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                elevation: 2,
                              ),
                              child: Text(
                                'Deaktiviraj',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          } else if (allowed.contains('EditAsync')) {
                            return ElevatedButton(
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: Text('Potvrda'),
                                        content: Text(
                                          'Jeste li sigurni da želite vratiti bicikl u draft stanje?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.of(
                                                  context,
                                                ).pop(false),
                                            child: Text('Ne'),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.of(
                                                  context,
                                                ).pop(true),
                                            child: Text('Da'),
                                          ),
                                        ],
                                      ),
                                );
                                if (confirmed == true) {
                                  await provider.edit(e.bikeId!);
                                  await _loadData();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                elevation: 2,
                              ),
                              child: Text(
                                'Vrati u draft',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          } else {
                            return SizedBox.shrink();
                          }
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
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
}
