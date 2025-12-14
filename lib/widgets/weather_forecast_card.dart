// lib/widgets/weather_forecast_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:itech/api/weather_api.dart';

class WeatherForecastCard extends StatelessWidget {
  final List<ForecastDay> forecast;

  const WeatherForecastCard({Key? key, required this.forecast}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uniqueDays = <DateTime, ForecastDay>{};
    for (var day in forecast.take(40)) {
      final date = DateTime(day.dateTime.year, day.dateTime.month, day.dateTime.day);
      if (!uniqueDays.containsKey(date)) {
        uniqueDays[date] = day;
      }
      if (uniqueDays.length >= 7) break;
    }

    final List<DateTime> displayDays = uniqueDays.keys.toList();
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);

    while (displayDays.length < 7) {
      final lastDate = displayDays.isEmpty ? today : displayDays.last;
      displayDays.add(lastDate.add(const Duration(days: 1)));
    }

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
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 130, // ✅ Batas maksimal, bukan tetap
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: finalDays.length,
                itemBuilder: (context, index) {
                  final date = finalDays[index];
                  final isToday = DateTime(date.year, date.month, date.day) == todayKey;
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
                            color: isToday ? Colors.black : null,
                            fontWeight: isToday ? FontWeight.bold : null,
                          ),
                        ),
                        SizedBox(height: 4),
                        if (hasData && entry != null)
                          Column(
                            children: [
                              Image.network(
                                'https://openweathermap.org/img/wn/${entry.icon}@2x.png',
                                width: 32,
                                height: 32,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(height: 2),
                              Text(
                                '${entry.temp.toStringAsFixed(0)}°',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                  color: isToday ? Colors.black : null,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                entry.description.split(' ').map((w) => w.capitalize()).join(' '),
                                style: TextStyle(
                                  fontSize: 9,
                                  color: isToday ? Colors.grey : Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              Icon(Icons.cloud, size: 32, color: Colors.grey),
                              SizedBox(height: 2),
                              Text('-', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              SizedBox(height: 2),
                              Text('Tidak diketahui', style: TextStyle(fontSize: 9, color: Colors.grey)),
                            ],
                          ),
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

extension StringExtension on String {
  String capitalize() {
    return isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
  }
}