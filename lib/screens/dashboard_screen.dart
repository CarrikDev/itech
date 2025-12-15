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
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<WeatherData?> _weatherFuture;

  @override
  void initState() {
    super.initState();
    _weatherFuture = WeatherApi.fetchWeather();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sensor = context.watch<SensorProvider>();

    /// hanya UI helper
    final avg7Days =
        (sensor.soilMoisture * 0.9 + 10).clamp(0.0, 100.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ITech: GreenDrop'),
        centerTitle: false,
        leading: const Icon(Icons.park, color: primaryColor),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: sensor.isOnline
                  ? Colors.green.shade100
                  : Colors.red.shade100,
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
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// MODE (COMING SOON – STATIC)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: secondaryColor.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Mode: Coming Soon',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.brown,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// KELEMBAPAN TANAH (MQTT)
              MoistureCard(
                current: sensor.soilMoisture,
                average7Days: avg7Days,
              ),

              const SizedBox(height: 16),

              /// LEVEL AIR (MQTT)
              WaterLevelCard(
                isWaterOk: sensor.waterLevelOk,
              ),

              const SizedBox(height: 16),

              /// CUACA
              FutureBuilder<WeatherData?>(
                future: _weatherFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return WeatherForecastCard(
                      forecast: snapshot.data!.forecast,
                    );
                  }

                  if (snapshot.hasError) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Gagal memuat cuaca',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }

                  return const Card(
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
                },
              ),

              const SizedBox(height: 16),

              /// CHART (DUMMY / AMAN)
              ChartWidget(
                mode: 'coming_soon',              // ⬅️ STATIC
                nextWatering: '-',                // ⬅️ STATIC
                titleLabel: 'Fitur Jadwal',
                descriptionLabel: 'Akan tersedia',
              ),
            ],
          ),
        ),
      ),

      /// ACTIONS
      floatingActionButton: SpeedDial(
        icon: Icons.grid_view,
        activeIcon: Icons.close,
        backgroundColor: primaryColor,
        foregroundColor: Colors.black,
        spacing: 16,
        children: [
          /// SIRAM SEKARANG (AKTIF)
          SpeedDialChild(
            child: const Icon(Icons.water_drop),
            label: 'Siram Sekarang',
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            onTap: () {
              MqttService().publishCommand({
                'action': 'pump_on',
                'duration_sec': 10,
              });

              _showSnackBar('Perintah siram dikirim');
            },
          ),

          /// DISABLED FEATURE
          SpeedDialChild(
            child: const Icon(Symbols.sprinkler, color: Colors.grey,),
            label: 'Penyiraman (soon)',
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
            onTap: () {},
          ),

          /// SETTINGS
          SpeedDialChild(
            child: const Icon(Icons.settings),
            label: 'Pengaturan',
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            onTap: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
    );
  }
}