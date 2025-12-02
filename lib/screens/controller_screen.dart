// lib/screens/controller_screen.dart
import 'package:flutter/material.dart';
import '../widgets/mode_selector.dart';
import '../widgets/pump_button.dart';

class ControllerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kontrol')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            PumpButton(),
            SizedBox(height: 24),
            ModeSelector(),
            SizedBox(height: 24),
            ListTile(
              title: Text('Jadwal Siram'),
              trailing: Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/schedule'),
            ),
            ListTile(
              title: Text('Timer Siram'),
              trailing: Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/timer'),
            ),
          ],
        ),
      ),
    );
  }
}