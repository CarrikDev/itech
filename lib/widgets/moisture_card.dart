// lib/widgets/moisture_card.dart
import 'package:flutter/material.dart';

Color _getMoistureColor(double moisture) {
  // 0–20 = merah, 20–40 = oranye, 40–60 = kuning, >60 = hijau
  if (moisture <= 20) return Colors.red;
  if (moisture <= 30) return Colors.orange;
  if (moisture <= 45) return Colors.amber;
  if (moisture <= 60) return Colors.greenAccent;
  return Colors.green;
}

String _getMoistureStatus(double moisture) {
  if (moisture <= 20) return 'Tanah sangat kering!';
  if (moisture <= 30) return 'Tanah kering';
  if (moisture <= 45) return 'Tanah kurang lembab';
  if (moisture <= 60) return 'Tanah lembab';
  return 'Tanah basah';
}

class MoistureCard extends StatelessWidget {
  final double current;
  final double average7Days;

  const MoistureCard({
    Key? key,
    required this.current,
    required this.average7Days,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kelembapan Tanah',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${current.toStringAsFixed(1)}%',
                  style: TextStyle(fontSize: 32, color: _getMoistureColor(current)),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _getMoistureColor(current).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            Text(
              _getMoistureStatus(current),
              style: TextStyle(
                color: _getMoistureColor(current),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            Text('Rata-rata 7 hari: ${average7Days.toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }
}