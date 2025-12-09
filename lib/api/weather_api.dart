// lib/api/weather_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WeatherData {
  final String city;
  final double temperature;
  final String description;
  final String icon;
  final List<ForecastDay> forecast;

  WeatherData({
    required this.city,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.forecast,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final city = json['city']['name'] as String;
    // Ambil data cuaca saat ini dari item pertama di "list"
    final firstItem = json['list'][0] as Map<String, dynamic>;
    final main = firstItem['main'] as Map<String, dynamic>;
    final weather = (firstItem['weather'] as List).first as Map<String, dynamic>;

    final temperature = main['temp'] as double;
    final description = weather['description'] as String;
    final icon = weather['icon'] as String;

    // Ambil forecast (7 hari unik)
    final List<ForecastDay> forecast = [];
    final seenDates = <String>{};

    for (var item in json['list'] as List) {
      if (forecast.length >= 7) break;
      final dt = (item as Map<String, dynamic>)['dt'] as int;
      final date = DateTime.fromMillisecondsSinceEpoch(dt * 1000);
      final dateKey = '${date.year}-${date.month}-${date.day}';
      if (!seenDates.contains(dateKey)) {
        seenDates.add(dateKey);
        forecast.add(ForecastDay.fromJson(item));
      }
    }

    return WeatherData(
      city: city,
      temperature: temperature,
      description: description,
      icon: icon,
      forecast: forecast,
    );
  }
}

class ForecastDay {
  final DateTime dateTime;
  final double temp;
  final String description;
  final String icon;

  ForecastDay({
    required this.dateTime,
    required this.temp,
    required this.description,
    required this.icon,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    return ForecastDay(
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temp: main['temp'] as double,
      description: weather['description'] as String,
      icon: weather['icon'] as String,
    );
  }
}

class WeatherApi {
  // lib/api/weather_api.dart
  static Future<WeatherData?> fetchWeather() async {
    print('🔍 Memulai fetch cuaca...');
  
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('weather_api_key')?.trim();
    final lat = prefs.getString('weather_lat') ?? '-3.5952';
    final lon = prefs.getString('weather_lon') ?? '98.6722';
  
    if (apiKey == null || apiKey.isEmpty) {
      print('❌ API key tidak ditemukan di pengaturan!');
      return null;
    }
  
    print('🔑 API key ditemukan (panjang: ${apiKey.length})');
  
    // Pastikan URL benar-benar valid
    final url = 'https://api.openweathermap.org/data/2.5/forecast?'
        'lat=$lat&'
        'lon=$lon&'
        'appid=$apiKey&'
        'units=metric&'
        'lang=id';
  
    print('📡 Mengakses URL: $url');
  
    try {
      final response = await http.get(Uri.parse(url));
      print('✅ Status code: ${response.statusCode}');
  
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Data cuaca diterima, kota: ${data['city']['name']}');
        return WeatherData.fromJson(data);
      } else {
        print('❌ Error dari OpenWeather: ${response.body}');
        return null;
      }
    } catch (e, stack) {
      print('💥 Exception saat fetch cuaca: $e');
      print('StackTrace: $stack');
      return null;
    }
  }
}