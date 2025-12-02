// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _weatherKeyController = TextEditingController();
  final TextEditingController _mqttBrokerController = TextEditingController();
  final TextEditingController _mqttPortController = TextEditingController();
  final TextEditingController _moistureThresholdController = TextEditingController();
  final TextEditingController _waterThresholdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _weatherKeyController.text = prefs.getString('weather_api_key') ?? '';
      _mqttBrokerController.text = prefs.getString('mqtt_broker') ?? 'broker.hivemq.com';
      _mqttPortController.text = prefs.getInt('mqtt_port')?.toString() ?? '1883';
      _moistureThresholdController.text = prefs.getInt('moisture_threshold')?.toString() ?? '20';
      _waterThresholdController.text = prefs.getInt('water_threshold')?.toString() ?? '100';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    // Simpan hanya jika tidak kosong
    if (_weatherKeyController.text.isNotEmpty) {
      prefs.setString('weather_api_key', _weatherKeyController.text.trim());
    }
    if (_mqttBrokerController.text.isNotEmpty) {
      prefs.setString('mqtt_broker', _mqttBrokerController.text.trim());
    }
    if (_mqttPortController.text.isNotEmpty) {
      prefs.setInt('mqtt_port', int.tryParse(_mqttPortController.text.trim()) ?? 1883);
    }
    if (_moistureThresholdController.text.isNotEmpty) {
      prefs.setInt('moisture_threshold', int.tryParse(_moistureThresholdController.text.trim()) ?? 20);
    }
    if (_waterThresholdController.text.isNotEmpty) {
      prefs.setInt('water_threshold', int.tryParse(_waterThresholdController.text.trim()) ?? 100);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pengaturan disimpan!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pengaturan')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _weatherKeyController,
              decoration: InputDecoration(labelText: 'OpenWeatherMap API Key'),
            ),
            TextField(
              controller: _mqttBrokerController,
              decoration: InputDecoration(labelText: 'MQTT Broker (ex: broker.hivemq.com)'),
            ),
            TextField(
              controller: _mqttPortController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'MQTT Port'),
            ),
            TextField(
              controller: _moistureThresholdController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Threshold Kelembapan (%)'),
            ),
            TextField(
              controller: _waterThresholdController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Threshold Air (ml)'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveSettings,
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}