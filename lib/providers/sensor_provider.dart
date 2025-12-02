// lib/providers/sensor_provider.dart
import 'package:flutter/foundation.dart';
import 'package:itech/api/mqtt_service.dart';
import '../services/notification_service.dart';

class SensorProvider with ChangeNotifier {
  double _soilMoisture = 0;
  int _waterLevel = 0;
  String _mode = 'unknown';
  bool _isOnline = false;
  DateTime _lastUpdate = DateTime.now();

  double get soilMoisture => _soilMoisture;
  int get waterLevel => _waterLevel;
  String get mode => _mode;
  bool get isOnline => _isOnline;
  DateTime get lastUpdate => _lastUpdate;

  SensorProvider() {
    _listenToMqtt();
  }

  void _listenToMqtt() {
    final mqtt = MqttService();
    mqtt.sensorStream.listen((data) {
      _soilMoisture = (data['soil_moisture'] as num).toDouble();
      _waterLevel = data['water_level'] as int;
      notifyListeners();
      _checkNotifications();
    });

    mqtt.statusStream.listen((data) {
      _mode = data['mode'] as String;
      _isOnline = data['is_online'] as bool;
      _lastUpdate = DateTime.parse(data['last_update']);
      notifyListeners();
    });
  }

  void _checkNotifications() {
    if (_soilMoisture < 20) {
      NotificationService.show('Tanah Kering!', 'Kelembapan sangat rendah. Siram sekarang!');
    }
    if (_waterLevel < 100) {
      NotificationService.show('Air Habis!', 'Tangki hampir kosong!');
    }
  }
}