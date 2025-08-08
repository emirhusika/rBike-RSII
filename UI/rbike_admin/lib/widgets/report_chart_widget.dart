import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportChartWidget extends StatelessWidget {
  final String topProductsJson;
  final double totalValue;

  const ReportChartWidget({
    Key? key,
    required this.topProductsJson,
    required this.totalValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    try {
      final List<dynamic> products = json.decode(topProductsJson);

      if (products.isEmpty) {
        return Container(
          height: 200,
          child: Center(
            child: Text(
              'Nema podataka za prikaz grafikona',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        );
      }

      return Column(
        children: [
          Container(
            height: 300,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Distribucija prodaje (kom)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sections: _buildPieChartSections(products),
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 16),

          Container(
            height: 300,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Vrijednost prodaje (BAM)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: _getMaxValue(products),
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() >= 0 &&
                                      value.toInt() < products.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        products[value.toInt()]['Name'],
                                        style: TextStyle(fontSize: 10),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }
                                  return Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: TextStyle(fontSize: 10),
                                  );
                                },
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: _buildBarChartGroups(products),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    } catch (e) {
      return Container(
        height: 200,
        child: Center(
          child: Text(
            'Greška u prikazu grafikona',
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
        ),
      );
    }
  }

  List<PieChartSectionData> _buildPieChartSections(List<dynamic> products) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    return products.asMap().entries.map((entry) {
      final index = entry.key;
      final product = entry.value;
      final quantity = product['Quantity'] as int;
      final totalQuantity = products.fold<int>(
        0,
        (sum, p) => sum + p['Quantity'] as int,
      );
      final percentage =
          totalQuantity > 0 ? (quantity / totalQuantity) * 100 : 0.0;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: quantity.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<BarChartGroupData> _buildBarChartGroups(List<dynamic> products) {
    return products.asMap().entries.map((entry) {
      final index = entry.key;
      final product = entry.value;
      final totalValue = (product['TotalValue'] as num).toDouble();

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: totalValue,
            color: Colors.blue,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  double _getMaxValue(List<dynamic> products) {
    if (products.isEmpty) return 100;
    final maxValue = products
        .map((p) => (p['TotalValue'] as num).toDouble())
        .reduce((a, b) => a > b ? a : b);
    return maxValue * 1.2; // 20% padding
  }
}
