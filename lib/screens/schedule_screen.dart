// lib/screens/schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:itech/api/mqtt_service.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  TimeOfDay _selectedTime = TimeOfDay(hour: 8, minute: 0);

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFFA8E6CF),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
      // Kirim ke MQTT
      MqttService().publishCommand({
        'action': 'set_schedule',
        'hour': _selectedTime.hour,
        'minute': _selectedTime.minute,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Jadwal Siram')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Atur waktu penyiraman otomatis:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            ListTile(
              title: Text('Waktu Siram'),
              subtitle: Text('${_selectedTime.format(context)}'),
              trailing: Icon(Icons.edit),
              onTap: () => _selectTime(context),
            ),
            SizedBox(height: 16),
            Text(
              'Catatan: Penyiraman hanya akan berjalan jika tanah kering.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}