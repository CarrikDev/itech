// lib/widgets/weather_forecast_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:itech/api/weather_api.dart';

class WeatherForecastCard extends StatelessWidget {
  final List<ForecastDay> forecast;

  const WeatherForecastCard({Key? key, required this.forecast}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Ambil data unik dari forecast (maks 7)
    final uniqueDays = <DateTime, ForecastDay>{};
    for (var day in forecast.take(40)) {
      final date = DateTime(day.dateTime.year, day.dateTime.month, day.dateTime.day);
      if (!uniqueDays.containsKey(date)) {
        uniqueDays[date] = day;
      }
      if (uniqueDays.length >= 7) break;
    }
  
    // 2. Jika kurang dari 7 hari, tambahkan hari fiktif ke depan (opsi 1)
    //    atau ke belakang (opsi 2). Kita pilih ke belakang → hari mendatang.
    final List<DateTime> displayDays = uniqueDays.keys.toList();
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
  
    // 3. Tambahkan hari fiktif jika < 7
    while (displayDays.length < 7) {
      final lastDate = displayDays.isEmpty
          ? today
          : displayDays.last;
      final nextDay = lastDate.add(Duration(days: 1));
      displayDays.add(nextDay);
    }
  
    // Ambil maks 7
    final finalDays = displayDays.take(7).toList();
  
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Prakiraan Cuaca 7 Hari',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: finalDays.length,
                itemBuilder: (context, index) {
                  final date = finalDays[index];
                  final isToday = DateTime(date.year, date.month, date.day) == todayKey;
  
                  // Cek apakah ada data cuaca untuk tanggal ini
                  final hasData = uniqueDays.containsKey(date);
                  final entry = uniqueDays[date];
  
                  final dayName = DateFormat('EEE', 'id').format(date);
                  final dayDate = DateFormat('d').format(date);
  
                  return Container(
                    width: 60,
                    margin: EdgeInsets.only(right: 12),
                    decoration: isToday
                        ? BoxDecoration(
                            color: Color(0xFFA8E6CF).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Color(0xFFA8E6CF), width: 1.5),
                          )
                        : null,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$dayName\n$dayDate',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.2,
                            color: isToday ? Colors.white : null,
                            fontWeight: isToday ? FontWeight.bold : null,
                          ),
                        ),
                        SizedBox(height: 4),
                        if (hasData && entry != null)
                          Image.network(
                            'https://openweathermap.org/img/wn/${entry.icon}@2x.png', // ✅ pastikan TIDAK ADA SPASI
                            width: 32,
                            height: 32,
                            fit: BoxFit.contain,
                          )
                        else
                          Icon(Icons.cloud, size: 32, color: Colors.grey),
                        SizedBox(height: 2),
                        if (hasData && entry != null)
                          Text(
                            '${entry.temp.toStringAsFixed(0)}°',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                              color: isToday ? Colors.white : null,
                            ),
                          )
                        else
                          Text('-', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}