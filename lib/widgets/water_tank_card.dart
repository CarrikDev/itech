// lib/widgets/water_tank_card.dart
import 'package:flutter/material.dart';

class WaterTankCard extends StatelessWidget {
  final int level; // dalam ml

  const WaterTankCard({Key? key, required this.level}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String statusText;
    Color statusColor;
    Color tankColor;

    if (level <= 0) {
      statusText = 'Air Habis! Isi Ulang';
      statusColor = Colors.red;
      tankColor = Colors.red.withOpacity(0.3);
    } else if (level < 100) {
      statusText = 'Air Hampir Habis!';
      statusColor = Colors.orange;
      tankColor = Colors.orange.withOpacity(0.3);
    } else {
      statusText = 'Air Masih Cukup';
      statusColor = Colors.green;
      tankColor = Colors.green.withOpacity(0.2);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Volume Air',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            // Visual tabung air
            SizedBox(
              height: 100,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Tabung luar
                  Container(
                    width: 60,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  // Isi air
                  FractionallySizedBox(
                    heightFactor: level <= 0 ? 0.01 : (level / 1000).clamp(0.0, 1.0),
                    child: Container(
                      width: 56,
                      decoration: BoxDecoration(
                        color: tankColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(6),
                          bottomRight: Radius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Text(
              '$level ml',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              statusText,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}