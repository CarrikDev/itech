import 'package:flutter/foundation.dart';
import '../api/mqtt_service.dart';
import '../services/notification_service.dart';

class SensorProvider with ChangeNotifier {
  // =====================
  // STATE
  // =====================
  double _soilMoisture = 0.0;
  bool _waterLevelOk = true; // default aman
  bool _isOnline = false;
  DateTime _lastUpdate = DateTime.now();

  // 🔑 untuk edge detection (notif hanya saat berubah)
  bool _lastWaterLevelOk = true;

  // =====================
  // GETTER
  // =====================
  double get soilMoisture => _soilMoisture;
  bool get waterLevelOk => _waterLevelOk;
  bool get isOnline => _isOnline;
  DateTime get lastUpdate => _lastUpdate;

  // =====================
  // CONSTRUCTOR
  // =====================
  SensorProvider() {
    _listenToMqtt();
  }

  // =====================
  // MQTT LISTENER
  // =====================
  void _listenToMqtt() {
    final mqtt = MqttService();

    mqtt.statusStream.listen((data) {
      // =====================
      // SOIL MOISTURE
      // =====================
      if (data.containsKey('soil_moisture')) {
        final raw = data['soil_moisture'];
        if (raw is num) {
          _soilMoisture = raw.toDouble();
        }
      }

      // =====================
      // WATER LEVEL (PELAMPUNG)
      // TOLERAN: bool / int / string
      // =====================
      if (data.containsKey('water_available')) {
        final raw = data['water_available'];

        if (raw is bool) {
          _waterLevelOk = raw;
        } else if (raw is num) {
          _waterLevelOk = raw == 1;
        } else if (raw is String) {
          _waterLevelOk = raw.toLowerCase() == 'true';
        }

        debugPrint(
          'MQTT water_available raw=$raw -> parsed=$_waterLevelOk',
        );
      }

      // =====================
      // ONLINE STATUS
      // =====================
      if (data.containsKey('is_online')) {
        final raw = data['is_online'];
        if (raw is bool) {
          _isOnline = raw;
        }
      }

      _lastUpdate = DateTime.now();

      // 🔔 NOTIFICATION CHECK (SEBELUM notifyListeners)
      _checkNotifications();

      notifyListeners();
    });
  }

  // =====================
  // NOTIFICATION LOGIC
  // =====================
  void _checkNotifications() {
    // =====================
    // TANAH KERING
    // =====================
    if (_soilMoisture < 20) {
      NotificationService.show(
        'Tanah Kering',
        'Kelembapan tanah rendah. Disarankan menyiram.',
      );
    }

    // =====================
    // AIR HABIS (EDGE ONLY)
    // =====================
    if (_lastWaterLevelOk == true && _waterLevelOk == false) {
      NotificationService.show(
        'Air Habis',
        'Tangki air kosong. Pompa dinonaktifkan.',
      );
    }

    // update state terakhir
    _lastWaterLevelOk = _waterLevelOk;
  }
}
