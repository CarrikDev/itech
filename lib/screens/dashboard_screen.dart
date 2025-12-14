// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

import 'package:itech/api/weather_api.dart';
import 'package:itech/api/mqtt_service.dart';
import '../providers/sensor_provider.dart';
import '../widgets/moisture_card.dart';
import '../widgets/water_level_card.dart';
import '../widgets/weather_forecast_card.dart';
import '../widgets/chart_widget.dart';

const Color primaryColor = Color(0xFFA8E6CF);
const Color secondaryColor = Color(0xFFFFD3B6);

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<WeatherData?> _weatherFuture;

  // ✅ Hapus semua state lokal untuk mode/jadwal — semua akan datang dari MQTT
  // SensorProvider akan menyediakan: mode, nextWatering, dll.

  @override
  void initState() {
    super.initState();
    _weatherFuture = WeatherApi.fetchWeather();

    // ✅ Pastikan SensorProvider sudah subscribe ke topik status MQTT
    // Misal: MqttService().subscribe('iot/plant/status', (payload) { ... });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: primaryColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sensor = Provider.of<SensorProvider>(context);
    final avg7Days = (sensor.soilMoisture * 0.9 + 10).clamp(0.0, 100.0);

    // ✅ Ambil mode langsung dari sensor (yang diupdate via MQTT)
    String displayMode;
    switch (sensor.mode) {
      case 'moisture':
        displayMode = 'Deteksi Kelembapan';
        break;
      case 'daily':
        displayMode = 'Harian';
        break;
      case 'timer':
        displayMode = 'Timer';
        break;
      default:
        displayMode = 'Tidak Diketahui';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('ITech: GreenDrop'),
        centerTitle: false,
        leading: Icon(Icons.park, color: primaryColor),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: sensor.isOnline ? Colors.green.shade100 : Colors.red.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              sensor.isOnline ? 'Online' : 'Offline',
              style: TextStyle(
                color: sensor.isOnline ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _weatherFuture = WeatherApi.fetchWeather();
          });
          // ❌ Tidak perlu load settings — semua data real-time dari MQTT
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: secondaryColor.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Mode: $displayMode',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.brown,
                  ),
                ),
              ),
              SizedBox(height: 16),
              MoistureCard(current: sensor.soilMoisture, average7Days: avg7Days),
              SizedBox(height: 16),
              WaterLevelCard(level: sensor.waterLevel),
              SizedBox(height: 16),
              FutureBuilder<WeatherData?>(
                future: _weatherFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return WeatherForecastCard(forecast: snapshot.data!.forecast);
                  } else if (snapshot.hasError) {
                    return Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Gagal memuat cuaca', style: TextStyle(color: Colors.red)),
                      ),
                    );
                  } else {
                    return Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 12),
                            Text('Memuat cuaca...'),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: 16),
              // ✅ ChartWidget hanya menerima data dari SensorProvider (yang diupdate via MQTT)
              ChartWidget(
                mode: sensor.mode,
                nextWatering: sensor.nextWatering, // ISO8601 string dari IoT
                titleLabel: sensor.eventTitle,
                descriptionLabel: sensor.eventDescription,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.grid_view,
        activeIcon: Icons.close,
        backgroundColor: primaryColor,
        foregroundColor: Colors.black,
        spacing: 16,
        children: [
          SpeedDialChild(
            child: Icon(Icons.water_drop),
            label: 'Siram Sekarang',
            labelStyle: TextStyle(fontWeight: FontWeight.w600),
            onTap: () {
              MqttService().publishCommand({
                'action': 'pump_on',
                'duration_sec': 10,
              });
              _showSnackBar('Perintah siram dikirim!');
            },
          ),
          SpeedDialChild(
            child: Icon(Symbols.sprinkler),
            label: 'Penyiraman',
            labelStyle: TextStyle(fontWeight: FontWeight.w600),
            onTap: () => Navigator.pushNamed(context, '/schedule'),
          ),
          SpeedDialChild(
            child: Icon(Icons.settings),
            label: 'Pengaturan',
            labelStyle: TextStyle(fontWeight: FontWeight.w600),
            onTap: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
    );
  }
}