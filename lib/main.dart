// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'api/mqtt_service.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/settings_screen.dart';
// ControllerScreen dihapus karena menu pindah ke FAB

// Providers
import 'providers/sensor_provider.dart';

// Warna & tema
const Color primaryColor = Color(0xFFA8E6CF); // hijau pastel
const Color secondaryColor = Color(0xFFFFD3B6); // kuning lembut
const Color accentColor = Color(0xFFDCE775);   // kuning cerah lembut
const Color backgroundColor = Colors.white;

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  primaryColor: primaryColor,
  scaffoldBackgroundColor: backgroundColor,
  appBarTheme: const AppBarTheme(
    backgroundColor: backgroundColor,
    foregroundColor: Colors.black,
    elevation: 0,
    titleTextStyle: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: Colors.black87,
    ),
  ),
  textTheme: GoogleFonts.poppinsTextTheme().copyWith(
    headlineSmall: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
    titleMedium: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
    bodyMedium: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
  ),
  cardTheme: CardThemeData( // ✅ BENAR
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: primaryColor,
    foregroundColor: Colors.black,
    elevation: 4,
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id', null);

  final mqtt = MqttService();
  await mqtt.connect();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SensorProvider()),
      ],
      child: MaterialApp(
        title: 'Smart Garden',
        theme: appTheme,
        home: SplashScreen(),
        routes: {
          '/schedule': (context) => ScheduleScreen(),
          '/settings': (context) => SettingsScreen(),
        },
      ),
    );
  }
}