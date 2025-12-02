// lib/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> show(String title, String body) async {
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        'smart_garden_channel',
        'Smart Garden Alerts',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
    await _notificationsPlugin.show(0, title, body, platformChannelSpecifics);
  }
}