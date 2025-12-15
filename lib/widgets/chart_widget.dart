// lib/widgets/chart_widget.dart
import 'package:flutter/material.dart';

class ChartWidget extends StatelessWidget {
  final String mode; // 'moisture', 'daily', 'timer', 'calendar'
  final String? nextWatering; // ISO8601 string from IoT
  final String? titleLabel;
  final String? descriptionLabel;

  const ChartWidget({
    Key? key,
    required this.mode,
    this.nextWatering,
    this.titleLabel,
    this.descriptionLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String mainText;
    // String title = titleLabel ?? 'Penyiraman Berikutnya';
    String title = titleLabel ?? 'Fitur ini belum tersedia!';
    String description = descriptionLabel ?? '';

    if (mode == 'moisture') {
      mainText = 'Sedang Mendeteksi...';
      title = 'Deteksi Kelembapan';
      description = 'Penyiraman akan dilakukan ketika kelembapan terdeteksi kering';
    } else if (nextWatering == null) {
      mainText = 'Coming Soon!';
    } else {
      try {
        final target = DateTime.parse(nextWatering!);
        final now = DateTime.now();
        if (target.isBefore(now)) {
          mainText = 'Waktunya Menyiram!';
        } else {
          final diff = target.difference(now);
          final h = diff.inHours % 24;
          final m = diff.inMinutes % 60;
          final s = diff.inSeconds % 60;
          mainText = '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
        }
      } catch (e) {
        mainText = 'Coming Soon!';
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Penyiraman Berikutnya', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text(
              mainText,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.yellow),
            ),
            SizedBox(height: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            if (description.isNotEmpty)
              Text(description, style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}