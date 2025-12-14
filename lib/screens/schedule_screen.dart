// lib/screens/schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:itech/api/mqtt_service.dart';
import '../providers/sensor_provider.dart';

const Color primaryColor = Color(0xFFA8E6CF);

enum WateringMode { moisture, daily, timer }

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  WateringMode _uiMode = WateringMode.moisture;
  TimeOfDay _dailyTime = TimeOfDay(hour: 8, minute: 0);
  Duration _timerDuration = Duration(hours: 1);

  @override
  void initState() {
    super.initState();
    // Sinkron awal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sensor = Provider.of<SensorProvider>(context, listen: false);
      _syncUiMode(sensor.mode);
    });
  }

  // ✅ Sinkron hanya saat mode berubah, bukan di setiap build
  void _syncUiMode(String modeStr) {
    final newMode = _getModeFromString(modeStr);
    if (_uiMode != newMode) {
      setState(() {
        _uiMode = newMode;
      });
    }
  }

  WateringMode _getModeFromString(String modeStr) {
    switch (modeStr) {
      case 'daily': return WateringMode.daily;
      case 'timer': return WateringMode.timer;
      default: return WateringMode.moisture;
    }
  }

  void _setMode(WateringMode mode) {
    setState(() {
      _uiMode = mode;
    });
    MqttService().publishCommand({
      'action': 'set_mode',
      'mode': mode.toString().split('.').last,
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: primaryColor),
    );
  }

  Future<void> _selectDailyTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dailyTime,
      builder: (context, child) {
        return Theme(
            data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dailyTime = picked;
      });
      MqttService().publishCommand({
        'action': 'set_schedule',
        'type': 'daily',
        'hour': _dailyTime.hour,
        'minute': _dailyTime.minute,
      });
      _showSnackBar('Perintah harian dikirim ke EMQX');
    }
  }

  void _selectTimerDuration() {
    int hours = _timerDuration.inHours;
    int minutes = _timerDuration.inMinutes.remainder(60);
    int seconds = _timerDuration.inSeconds.remainder(60);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Atur Timer'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDropdown('Jam', 0, 23, hours, (v) {
                  if (v != null) hours = v;
                }),
                _buildDropdown('Menit', 0, 59, minutes, (v) {
                  if (v != null) minutes = v;
                }),
                _buildDropdown('Detik', 0, 59, seconds, (v) {
                  if (v != null) seconds = v;
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              onPressed: () {
                final duration = Duration(hours: hours, minutes: minutes, seconds: seconds);
                setState(() {
                  _timerDuration = duration;
                });
                MqttService().publishCommand({
                  'action': 'set_schedule',
                  'type': 'timer',
                  'hours': hours,
                  'minutes': minutes,
                  'seconds': seconds,
                });
                _showSnackBar('Perintah timer dikirim ke EMQX');
                Navigator.of(context).pop();
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDropdown(String label, int min, int max, int value, ValueChanged<int?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: DropdownButtonFormField<int>(
        value: value,
        items: List.generate(max - min + 1, (i) {
          final v = min + i;
          return DropdownMenuItem(value: v, child: Text(v.toString().padLeft(2, '0')));
        }),
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  void _openCalendarForm() {
    String title = '';
    String description = '';
    DateTime selectedDate = DateTime.now().add(Duration(days: 1));
    TimeOfDay selectedTime = TimeOfDay(hour: 8, minute: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return Theme(
            data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: primaryColor),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tambah Jadwal Kalender',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(labelText: 'Judul *'),
                  onChanged: (value) => title = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Deskripsi'),
                  maxLines: 2,
                  onChanged: (value) => description = value,
                ),
                SizedBox(height: 16),
                Text('Tanggal'),
                ListTile(
                  title: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2025),
                      lastDate: DateTime(2030),
                      builder: (context, child) {
                        return Theme(
                            data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(primary: primaryColor),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                ),
                Text('Waktu'),
                ListTile(
                  title: Text(selectedTime.format(context)),
                  trailing: Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                      builder: (context, child) {
                        return Theme(
                            data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(primary: primaryColor),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (time != null) {
                      setState(() => selectedTime = time);
                    }
                  },
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Batal'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                      onPressed: () {
                        if (title.isEmpty) {
                          _showSnackBar('Judul wajib diisi!');
                          return;
                        }
                        final dateTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );

                        MqttService().publishCommand({
                          'action': 'add_calendar_event',
                          'event': {
                            'title': title,
                            'description': description,
                            'datetime': dateTime.toIso8601String(),
                          }
                        });

                        _showSnackBar('Perintah jadwal dikirim ke EMQX');
                        Navigator.of(context).pop();
                      },
                      child: Text('Simpan'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEventOptions(CalendarEvent event, Offset position) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
      items: [
        PopupMenuItem(
          value: 'edit',
          child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')]),
        ),
        PopupMenuItem(
          value: 'pin',
          child: Row(children: [Icon(Icons.push_pin, size: 18), SizedBox(width: 8), Text('Pin')]),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Colors.red))]),
        ),
      ],
    ).then((value) {
      if (value == 'delete') {
        MqttService().publishCommand({
          'action': 'delete_calendar_event',
          'event_id': event.id,
        });
        _showSnackBar('Perintah hapus dikirim ke EMQX');
      } else if (value == 'edit') {
        _showSnackBar('Edit belum diimplementasikan');
      } else if (value == 'pin') {
        MqttService().publishCommand({
          'action': 'update_calendar_event',
          'event': {
            'id': event.id,
            'title': event.title,
            'description': event.description,
            'datetime': event.dateTime.toIso8601String(),
            'pinned': !event.pinned,
          }
        });
        _showSnackBar('Perintah pin dikirim ke EMQX');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Gunakan Selector untuk HANYA rebuild saat mode berubah
    return Selector<SensorProvider, String>(
      selector: (_, provider) => provider.mode,
      builder: (context, mode, child) {
        // Sinkron hanya saat mode berubah
        if (mode != _getModeFromString(mode).toString().split('.').last) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _syncUiMode(mode);
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Penyiraman'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          body: ListView(
            padding: EdgeInsets.all(16),
            children: [
              SwitchListTile.adaptive(
                title: Text('Penyiraman deteksi kelembapan'),
                value: _uiMode == WateringMode.moisture,
                activeColor: primaryColor,
                onChanged: (value) {
                  if (value) _setMode(WateringMode.moisture);
                },
              ),
              SwitchListTile.adaptive(
                title: Text('Penyiraman Harian'),
                value: _uiMode == WateringMode.daily,
                activeColor: primaryColor,
                onChanged: (value) {
                  if (value) _setMode(WateringMode.daily);
                },
              ),
              if (_uiMode == WateringMode.daily)
                Padding(
                  padding: EdgeInsets.only(left: 56, top: 4, bottom: 12),
                  child: OutlinedButton.icon(
                    onPressed: _selectDailyTime,
                    icon: Icon(Icons.access_time, size: 18),
                    label: Text(_dailyTime.format(context)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor),
                    ),
                  ),
                ),
              SwitchListTile.adaptive(
                title: Text('Penyiraman Timer'),
                value: _uiMode == WateringMode.timer,
                activeColor: primaryColor,
                onChanged: (value) {
                  if (value) _setMode(WateringMode.timer);
                },
              ),
              if (_uiMode == WateringMode.timer)
                Padding(
                  padding: EdgeInsets.only(left: 56, top: 4, bottom: 12),
                  child: OutlinedButton.icon(
                    onPressed: _selectTimerDuration,
                    icon: Icon(Icons.timer, size: 18),
                    label: Text('${_timerDuration.inHours}j ${_timerDuration.inMinutes.remainder(60)}m ${_timerDuration.inSeconds.remainder(60)}d'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor),
                    ),
                  ),
                ),
              ListTile(
                title: Text('Penyiraman Kalender'),
                subtitle: Text('Jadwal 1 kali, bisa diatur kapan saja'),
                trailing: IconButton(
                  icon: Icon(Icons.add, color: primaryColor),
                  onPressed: () => _openCalendarForm(),
                ),
              ),
              Consumer<SensorProvider>(
                builder: (context, sensor, child) {
                  return sensor.calendarEvents.isEmpty
                      ? Padding(
                          padding: EdgeInsets.only(left: 16, top: 4, bottom: 16),
                          child: Text('Belum ada jadwal', style: TextStyle(color: Colors.grey)),
                        )
                      : Column(
                          children: sensor.calendarEvents.map((event) => Card(
                            margin: EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: event.pinned ? Icon(Icons.push_pin, color: primaryColor, size: 18) : null,
                              title: Text(event.title),
                              subtitle: Text('${event.dateTime.toLocal()}'.substring(0, 16).replaceAll('T', ' ')),
                              trailing: LayoutBuilder(
                                builder: (context, constraints) {
                                  return IconButton(
                                    icon: Icon(Icons.more_vert, color: primaryColor),
                                    onPressed: () {
                                      final box = context.findRenderObject() as RenderBox;
                                      final position = box.localToGlobal(Offset.zero);
                                      _showEventOptions(event, position);
                                    },
                                  );
                                },
                              ),
                            ),
                          )).toList(),
                        );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}