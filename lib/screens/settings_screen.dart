// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _weatherKeyController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();
  final TextEditingController _mqttBrokerController = TextEditingController();
  final TextEditingController _mqttPortController = TextEditingController();
  final TextEditingController _mqttUserController = TextEditingController();
  final TextEditingController _mqttPasswordController = TextEditingController();
  final TextEditingController _moistureThresholdController = TextEditingController();
  final TextEditingController _waterThresholdController = TextEditingController();
  final TextEditingController _tankCapacityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _weatherKeyController.text = prefs.getString('weather_api_key') ?? '';
      _latController.text = prefs.getString('weather_lat') ?? '-3.5952';
      _lonController.text = prefs.getString('weather_lon') ?? '98.6722';
      _mqttBrokerController.text = prefs.getString('mqtt_broker') ?? 'broker.hivemq.com';
      _mqttPortController.text = prefs.getInt('mqtt_port')?.toString() ?? '1883';
      _mqttUserController.text = prefs.getString('mqtt_user') ?? '';
      _mqttPasswordController.text = prefs.getString('mqtt_password') ?? '';
      _moistureThresholdController.text = prefs.getInt('moisture_threshold')?.toString() ?? '20';
      _waterThresholdController.text = prefs.getInt('water_threshold')?.toString() ?? '100';
      _tankCapacityController.text = prefs.getInt('tank_capacity_ml')?.toString() ?? '1000';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (_latController.text.isEmpty || _lonController.text.isEmpty) {
      _showError('Masukkan latitude dan longitude!');
      return;
    }

    if (!_isValidNumber(_moistureThresholdController.text) ||
        !_isValidNumber(_waterThresholdController.text) ||
        !_isValidNumber(_tankCapacityController.text) ||
        !_isValidNumber(_mqttPortController.text)) {
      _showError('Pastikan semua nilai numerik valid!');
      return;
    }

    // Simpan semua ke SharedPreferences
    await prefs.setString('weather_api_key', _weatherKeyController.text.trim());
    await prefs.setString('weather_lat', _latController.text.trim());
    await prefs.setString('weather_lon', _lonController.text.trim());
    await prefs.setString('mqtt_broker', _mqttBrokerController.text.trim());
    await prefs.setInt('mqtt_port', int.parse(_mqttPortController.text.trim()));
    await prefs.setString('mqtt_user', _mqttUserController.text.trim());
    await prefs.setString('mqtt_password', _mqttPasswordController.text.trim());
    await prefs.setInt('moisture_threshold', int.parse(_moistureThresholdController.text.trim()));
    await prefs.setInt('water_threshold', int.parse(_waterThresholdController.text.trim()));
    await prefs.setInt('tank_capacity_ml', int.parse(_tankCapacityController.text.trim()));

    _showSuccess('Pengaturan disimpan!');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  bool _isValidNumber(String? text) {
    if (text == null || text.isEmpty) return false;
    return int.tryParse(text.trim()) != null;
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
            SizedBox(height: 16),
            TextField(
              controller: _latController,
              keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: InputDecoration(
                labelText: 'Latitude (°)',
                helperText: 'Contoh: -3.5952 (Medan)',
              ),
            ),
            TextField(
              controller: _lonController,
              keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: InputDecoration(
                labelText: 'Longitude (°)',
                helperText: 'Contoh: 98.6722 (Medan)',
              ),
            ),
            SizedBox(height: 24),
            TextField(
              controller: _mqttBrokerController,
              decoration: InputDecoration(labelText: 'MQTT Broker'),
            ),
            TextField(
              controller: _mqttPortController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'MQTT Port'),
            ),
            TextField(
              controller: _mqttUserController,
              decoration: InputDecoration(labelText: 'MQTT Username (opsional)'),
            ),
            TextField(
              controller: _mqttPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'MQTT Password (opsional)'),
            ),
            SizedBox(height: 24),
            TextField(
              controller: _moistureThresholdController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Threshold Kelembapan (%)',
                helperText: 'Notifikasi jika kelembapan < nilai ini',
              ),
            ),
            TextField(
              controller: _waterThresholdController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Threshold Air (ml)',
                helperText: 'Notifikasi jika air < nilai ini',
              ),
            ),
            SizedBox(height: 24),
            TextField(
              controller: _tankCapacityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Kapasitas Tangki (ml)',
                helperText: 'Volume maksimal tangki air',
              ),
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