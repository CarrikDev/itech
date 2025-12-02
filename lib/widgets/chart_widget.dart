// lib/widgets/chart_widget.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartWidget extends StatelessWidget {
  final double moisture;

  const ChartWidget({Key? key, required this.moisture}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Data dummy histori (misal 6 jam terakhir)
    final List<double> dummyHistory = [40, 45, 50, 48, 42, moisture];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Histori Kelembapan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(dummyHistory.length, (index) =>
                          FlSpot(index.toDouble(), dummyHistory[index])),
                      isCurved: true,
                      color: Color(0xFFA8E6CF),
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: true, color: Color(0x33A8E6CF)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}