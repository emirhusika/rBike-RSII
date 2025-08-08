import 'dart:convert';
import 'package:rbike_admin/models/report.dart';
import 'package:rbike_admin/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class ReportProvider extends BaseProvider<Report> {
  ReportProvider() : super("Report");

  @override
  Report fromJson(data) {
    return Report.fromJson(data);
  }

  Future<Report?> generateReport(int month, int year) async {
    var url = "${baseUrl}${end}/generate?month=$month&year=$year";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.post(uri, headers: headers);
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    }
    return null;
  }

  Future<http.Response?> downloadReportPdf(int reportId) async {
    var url = "$baseUrl$end/download/$reportId";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      return response;
    }
    return null;
  }
}
