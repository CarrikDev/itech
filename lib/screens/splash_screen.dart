// lib/screens/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:itech/api/mqtt_service.dart';
import 'package:itech/screens/dashboard_screen.dart';
import 'package:itech/services/notification_service.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    WidgetsFlutterBinding.ensureInitialized();
    await NotificationService.init();
    await MqttService().connect();

    // Tunggu 5 detik (sesuaikan dengan durasi animasi)
    await Future.delayed(const Duration(seconds: 5));

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return Scaffold(
      backgroundColor: Colors.white, // ✅ Latar belakang putih polos
      body: Center(
        child: SizedBox(
          width: 300, // sesuaikan ukuran sesuai animasi Anda
          height: 300,
          child: Lottie.asset(
            'assets/animations/itech_green_drop.json', // ganti nama file sesuai yang Anda konversi
            repeat: false, // jangan loop
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}