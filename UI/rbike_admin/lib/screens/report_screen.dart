import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rbike_admin/models/report.dart';
import 'package:rbike_admin/providers/report_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:rbike_admin/providers/popup_dialogs.dart';
import 'package:rbike_admin/widgets/report_chart_widget.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int? _selectedMonth;
  int? _selectedYear;
  Report? _report;
  bool _loading = false;
  final _provider = ReportProvider();

  List<int> _years = List.generate(5, (i) => DateTime.now().year - i);
  List<int> _months = List.generate(12, (i) => i + 1);

  void _generateReport() async {
    if (_selectedMonth == null || _selectedYear == null) {
      MyDialogs.showError(context, 'Molimo odaberite i mjesec i godinu.');
      return;
    }
    setState(() => _loading = true);
    try {
      final report = await _provider.generateReport(
        _selectedMonth!,
        _selectedYear!,
      );
      setState(() {
        _report = report;
        _loading = false;
      });
      if (report == null) {
        MyDialogs.showError(
          context,
          'Nema podataka za odabrani mjesec/godinu.',
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      String msg = e.toString().replaceAll('Exception: ', '');
      if (msg.contains('No data found for the selected month and year.')) {
        msg = 'Nema podataka za odabrani mjesec/godinu.';
      }
      MyDialogs.showError(context, msg);
    }
  }

  void _downloadReport() async {
    if (_report == null) return;

    print('Starting PDF download for report ID: ${_report!.reportId}');

    final response = await _provider.downloadReportPdf(_report!.reportId);
    if (response == null) {
      print('Download response is null');
      MyDialogs.showError(context, 'Greška pri preuzimanju PDF-a.');
      return;
    }

    print(
      'Download response received, status: ${response.statusCode}, body length: ${response.bodyBytes.length}',
    );

    String defaultFileName =
        'Izvjestaj_${_report!.month}_${_report!.year}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    print('Using filename: $defaultFileName');

    try {
      print('Opening file picker dialog...');
      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Odaberite lokaciju za spremanje PDF izvještaja',
        fileName: defaultFileName,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      print('File picker result: $savePath');

      if (savePath != null) {
        print('User selected save path: $savePath');
        try {
          final file = File(savePath);
          await file.writeAsBytes(response.bodyBytes);
          print('PDF saved successfully to: $savePath');
          MyDialogs.showSuccess(context, 'PDF uspješno preuzet!', () {});
        } catch (fileError) {
          print('Error writing file: $fileError');
          MyDialogs.showError(
            context,
            'Greška pri spremanju datoteke: ${fileError.toString()}',
          );
        }
      } else {
        print('User cancelled file save');
      }
    } catch (e) {
      print('Error with file picker: $e');

      try {
        print('Trying fallback save to downloads...');
        final downloadsPath = '/tmp';
        final fallbackPath = '$downloadsPath/$defaultFileName';
        final file = File(fallbackPath);
        await file.writeAsBytes(response.bodyBytes);
        print('PDF saved to fallback location: $fallbackPath');
        MyDialogs.showSuccess(
          context,
          'PDF uspješno preuzet na: $fallbackPath',
          () {},
        );
      } catch (fallbackError) {
        print('Fallback save also failed: $fallbackError');
        MyDialogs.showError(
          context,
          'Greška pri spremanju PDF-a: ${e.toString()}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Izvještaj o narudžbama'),
        centerTitle: true,
        backgroundColor: Colors.red[700],
        elevation: 2,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.red[700]),
                            SizedBox(width: 8),
                            Text(
                              'Odaberite mjesec i godinu',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                decoration: InputDecoration(
                                  labelText: 'Mjesec',
                                  border: OutlineInputBorder(),
                                ),
                                value: _selectedMonth,
                                items:
                                    _months
                                        .map(
                                          (m) => DropdownMenuItem(
                                            value: m,
                                            child: Text(m.toString()),
                                          ),
                                        )
                                        .toList(),
                                onChanged:
                                    (v) => setState(() => _selectedMonth = v),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                decoration: InputDecoration(
                                  labelText: 'Godina',
                                  border: OutlineInputBorder(),
                                ),
                                value: _selectedYear,
                                items:
                                    _years
                                        .map(
                                          (y) => DropdownMenuItem(
                                            value: y,
                                            child: Text(y.toString()),
                                          ),
                                        )
                                        .toList(),
                                onChanged:
                                    (v) => setState(() => _selectedYear = v),
                              ),
                            ),
                            SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: _loading ? null : _generateReport,
                              icon: Icon(Icons.search, color: Colors.white),
                              label:
                                  _loading
                                      ? SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                      : Text(
                                        'Generiši',
                                        style: TextStyle(color: Colors.white),
                                      ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[700],
                                padding: EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 32),
                if (_report != null)
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.summarize, color: Colors.red[700]),
                              SizedBox(width: 8),
                              Text(
                                'Sažetak izvještaja',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Divider(height: 32, thickness: 1.2),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.attach_money,
                                color: Colors.green[700],
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Ukupna vrijednost:',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${_report!.totalValue.toStringAsFixed(2)} BAM',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber[700]),
                              SizedBox(width: 8),
                              Text(
                                'Top 3 proizvoda:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          ..._parseTopProducts(_report!.topProductsJson),
                          SizedBox(height: 20),
                          // Add charts
                          ReportChartWidget(
                            topProductsJson: _report!.topProductsJson,
                            totalValue: _report!.totalValue,
                          ),
                          SizedBox(height: 28),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: _downloadReport,
                              icon: Icon(Icons.download, color: Colors.white),
                              label: Text(
                                'Preuzmi PDF izvještaj',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[700],
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _parseTopProducts(String jsonStr) {
    try {
      final List<dynamic> list = json.decode(jsonStr);
      if (list.isEmpty) {
        return [Text('Nema podataka.')];
      }
      return list.map((item) {
        return Text(
          '- ${item['Name']} (${item['Quantity']} kom, ${item['TotalValue'].toStringAsFixed(2)} BAM)',
        );
      }).toList();
    } catch (e) {
      return [Text('Greška u prikazu top proizvoda.')];
    }
  }
}
