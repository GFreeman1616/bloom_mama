
import 'package:flutter/material.dart';
import '../core/storage/app_storage.dart';
import '../main.dart';

class WaterPage extends StatefulWidget {
  const WaterPage({super.key});
  @override
  State<WaterPage> createState() => _WaterPageState();
}

class _WaterPageState extends State<WaterPage> {
  int _goal = 2000;
  int _today = 0;
  late String _todayKey;

  @override
  void initState() {
    super.initState();
    _todayKey = ymd(DateTime.now());
    _goal = AppStorage.getInt(AppStorage.waterGoalKey, defaultValue: 2000);
    final savedDate = AppStorage.getString(AppStorage.waterDateKey, defaultValue: _todayKey);
    if (savedDate != _todayKey) {
      AppStorage.setInt(AppStorage.waterTodayKey, 0);
      AppStorage.setString(AppStorage.waterDateKey, _todayKey);
    }
    _today = AppStorage.getInt(AppStorage.waterTodayKey, defaultValue: 0);
  }

  Future<void> _add(int ml) async {
    _today += ml;
    await AppStorage.setInt(AppStorage.waterTodayKey, _today);
    setState(() {});
  }

  Future<void> _setGoal(int ml) async {
    _goal = ml;
    await AppStorage.setInt(AppStorage.waterGoalKey, ml);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_today / _goal).clamp(0.0, 1.0);
    return Scaffold(
      appBar: AppBar(title: const Text('Вода')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Сегодня: $_todayKey', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 6),
            Text('Цель: $_goal мл', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 6),
            Text('Выпито: $_today мл', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(onPressed: () => _add(200), child: const Text('+200 мл')),
                ElevatedButton(onPressed: () => _add(300), child: const Text('+300 мл')),
                ElevatedButton(onPressed: () => _add(500), child: const Text('+500 мл')),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Настроить цель:', style: TextStyle(fontWeight: FontWeight.w600)),
            Wrap(
              spacing: 12, children: [
                OutlinedButton(onPressed: () => _setGoal(1800), child: const Text('1800 мл')),
                OutlinedButton(onPressed: () => _setGoal(2000), child: const Text('2000 мл')),
                OutlinedButton(onPressed: () => _setGoal(2500), child: const Text('2500 мл')),
              ],
            )
          ],
        ),
      ),
    );
  }
}
