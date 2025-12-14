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

    // Inisialisasi layanan latar belakang
    await NotificationService.init();
    await MqttService().connect();

    // Tunggu minimal 2 detik (agar animasi terlihat), maksimal 5 detik
    await Future.delayed(const Duration(seconds: 5));

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: 240,
          height: 240,
          child: Lottie.asset(
            'assets/animations/itech_green_drop.json',
            repeat: false,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.cloud_off, size: 64, color: Colors.grey);
            },
          ),
        ),
      ),
    );
  }
}