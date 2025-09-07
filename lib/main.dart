import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:bloom_mama/services/notification_service.dart';
import 'package:bloom_mama/storage/app_storage.dart';

import 'package:bloom_mama/features/tracker/tracker_page.dart';
import 'package:bloom_mama/pages/kick_counter_page.dart';
import 'package:bloom_mama/pages/contraction_timer_page.dart';
import 'package:bloom_mama/pages/water_page.dart';
import 'package:bloom_mama/pages/reminders_page.dart';
import 'package:bloom_mama/pages/timeline_page.dart';
import 'package:bloom_mama/pages/weight_page.dart';
import 'package:bloom_mama/pages/appointments_page.dart';
import 'package:bloom_mama/pages/notes_page.dart';
import 'package:bloom_mama/pages/home_page.dart';

const String kAppName = 'Bloom Mama';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStorage.init();
  await NotificationService().init();

  final timeline = Timeline(); // создаём Timeline, который хранит LMP и вычисляет текущую неделю

  runApp(BloomMamaApp(timeline: timeline));
}

class BloomMamaApp extends StatelessWidget {
  final Timeline timeline;
  const BloomMamaApp({super.key, required this.timeline});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8E6BFF)),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (ctx) => HomePage(timeline: timeline), // <- передаём timeline
        '/kick': (ctx) => const KickCounterPage(),
        '/contractions': (ctx) => const ContractionTimerPage(),
        '/water': (ctx) => const WaterPage(),
        '/reminders': (ctx) => const RemindersPage(),
        '/timeline': (ctx) => const TimelinePage(),
        '/weight': (ctx) => const WeightPage(),
        '/appointments': (ctx) => const AppointmentsPage(),
        '/notes': (ctx) => const NotesPage(),
      },
    );
  }
}

// вспомогательная функция для форматирования даты
String ymd(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
