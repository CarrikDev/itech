// lib/api/mqtt_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MqttService {
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal();

  late MqttServerClient client;
  StreamController<Map<String, dynamic>> _sensorStreamController = StreamController.broadcast();
  StreamController<Map<String, dynamic>> _statusStreamController = StreamController.broadcast();

  Stream<Map<String, dynamic>> get sensorStream => _sensorStreamController.stream;
  Stream<Map<String, dynamic>> get statusStream => _statusStreamController.stream;

  Future<void> connect() async {
    final prefs = await SharedPreferences.getInstance();
    final broker = prefs.getString('mqtt_broker') ?? 'broker.hivemq.com';
    final port = prefs.getInt('mqtt_port') ?? 1883;
    final clientId = 'SmartGardenApp_${DateTime.now().millisecondsSinceEpoch}';

    client = MqttServerClient(broker, clientId);
    client.port = port;
    client.logging(on: false);
    client.keepAlivePeriod = 30;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;

    try {
      await client.connect();
      if (client.connectionStatus!.state == MqttConnectionState.connected) {
        client.subscribe('iot/plant/sensor', MqttQos.atLeastOnce);
        client.subscribe('iot/plant/status', MqttQos.atLeastOnce);

        client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
          final recMess = c[0].payload as MqttPublishMessage;
          final payload = String.fromCharCodes(recMess.payload.message);
          try {
            final data = Map<String, dynamic>.from(jsonDecode(payload));
            if (c[0].topic == 'iot/plant/sensor') {
              _sensorStreamController.add(data);
            } else if (c[0].topic == 'iot/plant/status') {
              _statusStreamController.add(data);
            }
          } catch (e) {
            print('MQTT payload error: $e');
          }
        });
      }
    } catch (e) {
      print('MQTT connection error: $e');
    }
  }

  void onConnected() => print('MQTT connected');
  void onDisconnected() => print('MQTT disconnected');
  void onSubscribed(String? topic) => print('Subscribed to $topic');

  void publishCommand(Map<String, dynamic> command) {
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      final clientMqtt = client;
      final builder = MqttClientPayloadBuilder();
      builder.addString(jsonEncode(command));
      clientMqtt.publishMessage('iot/plant/command', MqttQos.atLeastOnce, builder.payload!);
    }
  }

  void disconnect() {
    client.disconnect();
    _sensorStreamController.close();
    _statusStreamController.close();
  }
}