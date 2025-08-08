class Report {
  final int reportId;
  final int month;
  final int year;
  final double totalValue;
  final String topProductsJson;
  final DateTime createdAt;
  final int createdById;
  final String pdfFilePath;

  Report({
    required this.reportId,
    required this.month,
    required this.year,
    required this.totalValue,
    required this.topProductsJson,
    required this.createdAt,
    required this.createdById,
    required this.pdfFilePath,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      reportId: json['reportId'],
      month: json['month'],
      year: json['year'],
      totalValue: (json['totalValue'] as num).toDouble(),
      topProductsJson: json['topProductsJson'],
      createdAt: DateTime.parse(json['createdAt']),
      createdById: json['createdById'],
      pdfFilePath: json['pdfFilePath'],
    );
  }
} 