// lib/widgets/pump_button.dart
import 'package:flutter/material.dart';
import '../api/mqtt_service.dart';

class PumpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        MqttService().publishCommand({
          'action': 'pump_on',
          'duration_sec': 10,
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Perintah dikirim!')));
      },
      icon: Icon(Icons.water_drop),
      label: Text('Siram Sekarang'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFA8E6CF),
        foregroundColor: Colors.black,
      ),
    );
  }
}