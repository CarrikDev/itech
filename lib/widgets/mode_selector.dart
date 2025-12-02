// lib/widgets/mode_selector.dart
import 'package:flutter/material.dart';
import 'package:itech/api/mqtt_service.dart';

class ModeSelector extends StatefulWidget {
  @override
  _ModeSelectorState createState() => _ModeSelectorState();
}

class _ModeSelectorState extends State<ModeSelector> {
  String? _selectedMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Mode',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        RadioListTile<String>(
          title: Text('Manual'),
          value: 'manual',
          groupValue: _selectedMode,
          onChanged: (value) {
            setState(() {
              _selectedMode = value;
              MqttService().publishCommand({
                'action': 'set_mode',
                'mode': value,
              });
            });
          },
        ),
        RadioListTile<String>(
          title: Text('Jadwal'),
          value: 'schedule',
          groupValue: _selectedMode,
          onChanged: (value) {
            setState(() {
              _selectedMode = value;
              MqttService().publishCommand({
                'action': 'set_mode',
                'mode': value,
              });
            });
          },
        ),
        RadioListTile<String>(
          title: Text('Sensor'),
          value: 'sensor',
          groupValue: _selectedMode,
          onChanged: (value) {
            setState(() {
              _selectedMode = value;
              MqttService().publishCommand({
                'action': 'set_mode',
                'mode': value,
              });
            });
          },
        ),
      ],
    );
  }
}