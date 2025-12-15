import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MqttService {
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal();

  MqttServerClient? _client;

  final StreamController<Map<String, dynamic>> _statusStreamController =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get statusStream =>
      _statusStreamController.stream;

  bool get isConnected =>
      _client?.connectionStatus?.state == MqttConnectionState.connected;

  Future<void> connect() async {
    if (isConnected) return;

    final prefs = await SharedPreferences.getInstance();
    final broker =
        prefs.getString('mqtt_broker') ?? 'l18802f6.ala.eu-central-1.emqxsl.com';
    final port = prefs.getInt('mqtt_port') ?? 8883;
    final username = prefs.getString('mqtt_user');
    final password = prefs.getString('mqtt_password');

    final clientId =
        'SmartGardenApp_${DateTime.now().millisecondsSinceEpoch}';

    final client = MqttServerClient(broker, clientId);
    client.port = port;
    client.keepAlivePeriod = 30;
    client.logging(on: false);
    client.onConnected = () => print('✅ MQTT connected');
    client.onDisconnected = () {
      print('❌ MQTT disconnected');
      _client = null;
    };

    if (port == 8883) {
      final context = await _getSecurityContext();
      client.secure = true;
      client.securityContext = context;
    }

    client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillTopic('iot/plant/status')
        .withWillMessage('{"is_online":false}')
        .withWillQos(MqttQos.atLeastOnce);

    try {
      await client.connect(username, password);

      if (client.connectionStatus?.state ==
          MqttConnectionState.connected) {
        _client = client;

        client.subscribe(
          'iot/plant/status',
          MqttQos.atLeastOnce,
        );

        client.updates!.listen((events) {
          final rec = events.first.payload as MqttPublishMessage;
          final payload =
              String.fromCharCodes(rec.payload.message);

          try {
            final data = jsonDecode(payload);
            if (data is Map<String, dynamic>) {
              _statusStreamController.add(data);
            }
          } catch (e) {
            print('❌ JSON parse error: $e');
          }
        });
      }
    } catch (e) {
      print('🔥 MQTT ERROR: $e');
      _client = null;
    }
  }

  Future<void> publishCommand(Map<String, dynamic> command) async {
    if (!isConnected) {
      await connect();
    }

    if (!isConnected) return;

    final builder = MqttClientPayloadBuilder();
    builder.addString(jsonEncode(command));

    _client!.publishMessage(
      'iot/plant/command',
      MqttQos.atLeastOnce,
      builder.payload!,
    );
  }

  Future<SecurityContext> _getSecurityContext() async {
    final buffer =
        await rootBundle.load('assets/certifications/emqxsl-ca.crt');
    final context = SecurityContext.defaultContext;
    context.setClientAuthoritiesBytes(
      buffer.buffer.asUint8List(),
    );
    return context;
  }

  void disconnect() {
    _client?.disconnect();
    _client = null;
  }
}
