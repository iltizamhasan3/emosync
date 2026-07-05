import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);
    await _requestPermissions();
    _initialized = true;
  }

  static Future<void> _requestPermissions() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }
  }

  static Future<void> scheduleDailyReminder({required TimeOfDay time}) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      0,
      'Pengingat Check-in',
      'Jangan lupa catat mood kamu hari ini!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Pengingat Harian',
          channelDescription: 'Pengingat untuk check-in mood setiap hari',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> scheduleWeeklyReport({required int dayOfWeek}) async {
    final now = tz.TZDateTime.now(tz.local);
    var daysUntilTarget = (dayOfWeek - now.weekday + 7) % 7;
    if (daysUntilTarget == 0) daysUntilTarget = 7;
    final scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + daysUntilTarget,
      18,
      0,
    );

    await _plugin.zonedSchedule(
      1,
      'Laporan Mingguan',
      'Lihat ringkasan mood dan aktivitas kamu minggu ini!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_report',
          'Laporan Mingguan',
          channelDescription: 'Ringkasan mood mingguan',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }
}