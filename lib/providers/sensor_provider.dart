// lib/providers/sensor_provider.dart
import 'package:flutter/foundation.dart';
import 'package:itech/api/mqtt_service.dart';
import '../services/notification_service.dart';

// ✅ Tambahkan class CalendarEvent di sini
class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final bool pinned;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.pinned = false,
  });
}

class SensorProvider with ChangeNotifier {
  double _soilMoisture = 0;
  int _waterLevel = 0;
  String _mode = 'unknown';
  bool _isOnline = false;
  DateTime _lastUpdate = DateTime.now();

  String? _nextWatering;
  String? _eventTitle;
  String? _eventDescription;
  List<CalendarEvent> _calendarEvents = []; // ✅ Tambahkan field

  double get soilMoisture => _soilMoisture;
  int get waterLevel => _waterLevel;
  String get mode => _mode;
  bool get isOnline => _isOnline;
  DateTime get lastUpdate => _lastUpdate;
  String? get nextWatering => _nextWatering;
  String? get eventTitle => _eventTitle;
  String? get eventDescription => _eventDescription;
  List<CalendarEvent> get calendarEvents => _calendarEvents; // ✅ Tambahkan getter

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

      _nextWatering = data['next_watering'] as String?;
      _eventTitle = data['event_title'] as String?;
      _eventDescription = data['event_description'] as String?;

      // ✅ Baca calendar_events dari payload MQTT
      if (data.containsKey('calendar_events')) {
        final events = (data['calendar_events'] as List)
            .map((e) => CalendarEvent(
                  id: e['id'],
                  title: e['title'],
                  description: e['description'],
                  dateTime: DateTime.parse(e['datetime']),
                  pinned: e['pinned'] ?? false,
                ))
            .toList();
        _calendarEvents = events;
      }

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