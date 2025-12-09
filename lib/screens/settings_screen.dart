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
  final TextEditingController _moistureThresholdController = TextEditingController();
  final TextEditingController _waterThresholdController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _radiusController = TextEditingController();

  String _containerShape = 'persegi';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _weatherKeyController.text = prefs.getString('weather_api_key') ?? '';
      _latController.text = prefs.getString('weather_lat') ?? '-3.5952'; // Medan default
      _lonController.text = prefs.getString('weather_lon') ?? '98.6722';
      _mqttBrokerController.text = prefs.getString('mqtt_broker') ?? 'broker.hivemq.com';
      _mqttPortController.text = prefs.getInt('mqtt_port')?.toString() ?? '1883';
      _moistureThresholdController.text = prefs.getInt('moisture_threshold')?.toString() ?? '20';
      _waterThresholdController.text = prefs.getInt('water_threshold')?.toString() ?? '100';

      _containerShape = prefs.getString('container_shape') ?? 'persegi';
      _lengthController.text = prefs.getDouble('container_length')?.toStringAsFixed(1) ?? '10.0';
      _widthController.text = prefs.getDouble('container_width')?.toStringAsFixed(1) ?? '10.0';
      _heightController.text = prefs.getDouble('container_height')?.toStringAsFixed(1) ?? '10.0';
      _radiusController.text = prefs.getDouble('container_radius')?.toStringAsFixed(1) ?? '5.0';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Validasi koordinat
    if (_latController.text.isEmpty || _lonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Masukkan latitude dan longitude!')),
      );
      return;
    }

    // Simpan
    prefs.setString('weather_api_key', _weatherKeyController.text.trim());
    prefs.setString('weather_lat', _latController.text.trim());
    prefs.setString('weather_lon', _lonController.text.trim());
    prefs.setString('mqtt_broker', _mqttBrokerController.text.trim());
    prefs.setInt('mqtt_port', int.tryParse(_mqttPortController.text.trim()) ?? 1883);
    prefs.setInt('moisture_threshold', int.tryParse(_moistureThresholdController.text.trim()) ?? 20);
    prefs.setInt('water_threshold', int.tryParse(_waterThresholdController.text.trim()) ?? 100);

    prefs.setString('container_shape', _containerShape);
    prefs.setDouble('container_length', double.tryParse(_lengthController.text.trim()) ?? 10.0);
    prefs.setDouble('container_width', double.tryParse(_widthController.text.trim()) ?? 10.0);
    prefs.setDouble('container_height', double.tryParse(_heightController.text.trim()) ?? 10.0);
    prefs.setDouble('container_radius', double.tryParse(_radiusController.text.trim()) ?? 5.0);

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
            SizedBox(height: 16),

            // Koordinat Lokasi
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

            // MQTT
            TextField(
              controller: _mqttBrokerController,
              decoration: InputDecoration(labelText: 'MQTT Broker (ex: broker.hivemq.com)'),
            ),
            TextField(
              controller: _mqttPortController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'MQTT Port'),
            ),
            SizedBox(height: 24),

            // Threshold
            TextField(
              controller: _moistureThresholdController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Threshold Kelembapan (%)',
                helperText: 'Notifikasi muncul jika kelembapan < nilai ini',
              ),
            ),
            TextField(
              controller: _waterThresholdController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Threshold Air (ml)',
                helperText: 'Notifikasi muncul jika air < nilai ini',
              ),
            ),
            SizedBox(height: 24),

            // Wadah Air
            Text('Wadah Air (untuk hitung kapasitas maksimal)', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: _containerShape,
              onChanged: (value) => setState(() => _containerShape = value!),
              items: [
                DropdownMenuItem(value: 'persegi', child: Text('Persegi')),
                DropdownMenuItem(value: 'persegi_panjang', child: Text('Persegi Panjang')),
                DropdownMenuItem(value: 'lingkaran', child: Text('Lingkaran')),
              ],
              decoration: InputDecoration(labelText: 'Bentuk Wadah'),
            ),
            SizedBox(height: 12),

            if (_containerShape == 'persegi' || _containerShape == 'persegi_panjang') ...[
              TextField(
                controller: _lengthController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Panjang (cm)'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _widthController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Lebar (cm)'),
              ),
              SizedBox(height: 8),
            ],
            if (_containerShape == 'lingkaran') ...[
              TextField(
                controller: _radiusController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Jari-jari (cm)'),
              ),
              SizedBox(height: 8),
            ],
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Tinggi (cm)'),
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