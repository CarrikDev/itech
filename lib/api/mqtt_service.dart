// lib/api/mqtt_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io'; // Diperlukan untuk SecurityContext
import 'package:flutter/services.dart' show rootBundle; // Diperlukan untuk memuat aset
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MqttService {
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal();

  MqttServerClient? _client;
  final StreamController<Map<String, dynamic>> _sensorStreamController = StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _statusStreamController = StreamController.broadcast();

  Stream<Map<String, dynamic>> get sensorStream => _sensorStreamController.stream;
  Stream<Map<String, dynamic>> get statusStream => _statusStreamController.stream;

  bool get isConnected => _client?.connectionStatus?.state == MqttConnectionState.connected;

  Future<void> connect() async {
    if (isConnected) return;

    final prefs = await SharedPreferences.getInstance();
    // Ganti nilai default ini sesuai dengan broker EMQX Anda jika perlu
    final broker = prefs.getString('mqtt_broker') ?? 'l18802f6.ala.eu-central-1.emqxsl.com'; 
    final port = prefs.getInt('mqtt_port') ?? 8883; // Port 8883 (TLS)
    final username = prefs.getString('mqtt_user');
    final password = prefs.getString('mqtt_password');
    final clientId = 'SmartGardenApp_${DateTime.now().millisecondsSinceEpoch}';

    final client = MqttServerClient(broker, clientId);
    client.port = port;
    client.logging(on: false);
    client.keepAlivePeriod = 30;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;

    // --- START: KONFIGURASI TLS ---
    if (port == 8883 || port == 8884) {
      print('🔒 [MQTT] Menggunakan koneksi aman (TLS) di port $port');
      try {
        final securityContext = await _getSecurityContext();
        client.securityContext = securityContext;
        client.secure = true;
      } catch (e) {
        print('❌ [MQTT] Gagal mengonfigurasi konteks keamanan TLS: $e');
        // Hentikan koneksi jika konfigurasi TLS gagal
        return; 
      }
    }
    // --- END: KONFIGURASI TLS ---


    // Set connectionMessage
    client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillTopic('iot/plant/status')
        .withWillMessage('{"is_online":false}')
        .withWillQos(MqttQos.atLeastOnce);

    try {
      print('🔌 [MQTT] Mencoba koneksi ke broker: $broker');
      print('   Port: $port');
      print('   Client ID: SmartGardenApp_...');
      if (username != null && username.isNotEmpty) {
        print('   Username: $username');
      }

      await client.connect(username, password);

      if (client.connectionStatus?.state == MqttConnectionState.connected) {
        print('✅ [MQTT] Koneksi BERHASIL!');
        _client = client;

        print('📡 [MQTT] Subscribe ke topik: iot/plant/sensor');
        client.subscribe('iot/plant/sensor', MqttQos.atLeastOnce);
        print('📡 [MQTT] Subscribe ke topik: iot/plant/status');
        client.subscribe('iot/plant/status', MqttQos.atLeastOnce);

        client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
          final topic = c[0].topic;
          final recMess = c[0].payload as MqttPublishMessage;
          final payload = String.fromCharCodes(recMess.payload.message);
          print('📥 [MQTT] Diterima dari topik "$topic": $payload');

          try {
            final data = jsonDecode(payload) as Map<String, dynamic>;
            if (topic == 'iot/plant/sensor') {
              _sensorStreamController.add(data);
            } else if (topic == 'iot/plant/status') {
              _statusStreamController.add(data);
            }
          } catch (e) {
            print('❌ [MQTT] Error parse payload: $e');
          }
        });
      } else {
        print('❌ [MQTT] Koneksi GAGAL: status tidak connected');
        print('   Status: ${client.connectionStatus?.state}');
      }
    } catch (e, stack) {
      print('🔥 [MQTT] ERROR KONEKSI:');
      print('   Pesan: $e');
      print('   Stack trace: $stack');
      _client = null;
    }
  }

  // Fungsi baru untuk memuat sertifikat CA dari aset
  Future<SecurityContext> _getSecurityContext() async {
    // Memuat file .crt dari folder assets
    final buffer = await rootBundle.load('assets/certifications/emqxsl-ca.crt'); 
    final List<int> bytes = buffer.buffer.asUint8List();
    
    final securityContext = SecurityContext.defaultContext;
    // Menambahkan sertifikat CA sebagai otoritas yang dipercaya
    securityContext.setClientAuthoritiesBytes(bytes); 
    
    return securityContext;
  }
  
  // ... (onConnected, onDisconnected, onSubscribed, publishCommand, disconnect tetap sama) ...

  void onConnected() {
    print('MQTT connected');
  }

  void onDisconnected() {
    print('MQTT disconnected');
    _client = null;
  }

  void onSubscribed(String? topic) {
    print('Subscribed to $topic');
  }

  void publishCommand(Map<String, dynamic> command) {
    if (isConnected && _client != null) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(jsonEncode(command));
      _client!.publishMessage('iot/plant/command', MqttQos.atLeastOnce, builder.payload!);
    }
  }

  void disconnect() {
    _client?.disconnect();
    _client = null;
  }
}
