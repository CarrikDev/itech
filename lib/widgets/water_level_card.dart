// lib/widgets/water_level_card.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaterLevelCard extends StatefulWidget {
  final int level; // dalam ml

  const WaterLevelCard({Key? key, required this.level}) : super(key: key);

  @override
  State<WaterLevelCard> createState() => _WaterLevelCardState();
}

class _WaterLevelCardState extends State<WaterLevelCard> {
  int _tankCapacity = 1000; // default

  @override
  void initState() {
    super.initState();
    _loadTankCapacity();
  }

  Future<void> _loadTankCapacity() async {
    final prefs = await SharedPreferences.getInstance();
    final capacity = prefs.getInt('tank_capacity_ml') ?? 1000;
    if (mounted) {
      setState(() {
        _tankCapacity = capacity;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double fillRatio = _tankCapacity > 0
        ? (widget.level / _tankCapacity).clamp(0.0, 1.0)
        : 0.0;

    String statusText;
    Color statusColor;

    if (widget.level <= 0) {
      statusText = 'Air Habis! Isi Ulang';
      statusColor = Colors.red;
    } else if (widget.level < 100) {
      statusText = 'Air Hampir Habis!';
      statusColor = Colors.orange;
    } else {
      statusText = 'Air Masih Cukup';
      statusColor = Colors.green;
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
                  Container(
                    width: 60,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  // Isi air — sesuai kapasitas sebenarnya
                  FractionallySizedBox(
                    heightFactor: fillRatio,
                    child: Container(
                      width: 56,
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.3),
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
              '${widget.level} ml',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Dari $_tankCapacity ml • ${(fillRatio * 100).toInt()}%',
              style: TextStyle(fontSize: 12, color: Colors.grey),
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