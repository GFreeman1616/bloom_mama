
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Init timezone (жёстко ставим Asia/Bishkek для точных ежедневных напоминаний)
    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Bishkek'));
    } catch (_) {
      // если что-то пойдёт не так — останемся на tz.local (UTC), всё равно сработает, только время может сместиться
    }

    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings iosInit = const DarwinInitializationSettings();
    final InitializationSettings settings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(settings);

    // Разрешения на уведомления
    if (Platform.isAndroid) {
      await Permission.notification.request();
    }

    // Создаём канал для Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'bloom_mama_main',
      'Напоминания',
      description: 'Ежедневные и разовые напоминания Bloom Mama',
      importance: Importance.high,
    );
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);
  }

  Future<void> showNow(int id, String title, String body) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails('bloom_mama_main', 'Напоминания', importance: Importance.high),
      iOS: const DarwinNotificationDetails(),
    );
    await _plugin.show(id, title, body, details);
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final scheduled = _nextInstanceOfTime(hour, minute);
    final details = NotificationDetails(
      android: AndroidNotificationDetails('bloom_mama_main', 'Напоминания',
          importance: Importance.high, priority: Priority.high),
      iOS: const DarwinNotificationDetails(),
    );
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // каждый день в это время
    );
  }

  Future<void> scheduleOneTime({
    required int id,
    required DateTime dateTime,
    required String title,
    required String body,
  }) async {
    final scheduled = tz.TZDateTime.from(dateTime, tz.local);
    final details = NotificationDetails(
      android: AndroidNotificationDetails('bloom_mama_main', 'Напоминания',
          importance: Importance.high, priority: Priority.high),
      iOS: const DarwinNotificationDetails(),
    );
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancel(int id) async => _plugin.cancel(id);
  Future<void> cancelAll() async => _plugin.cancelAll();
}
