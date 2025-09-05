
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:bloom_mama/storage/app_storage.dart';


class Timeline {
  DateTime? lmp;

  Timeline({this.lmp}) {
    if (lmp == null) {
      final s = AppStorage.getString(AppStorage.lmpDateKey, defaultValue: '');
      if (s.isNotEmpty) {
        lmp = DateTime.tryParse(s);
      }
    }
  }

  int get currentWeek {
    if (lmp == null) return 1;
    final days = DateTime.now().difference(lmp!).inDays;
    return (days ~/ 7 + 1).clamp(1, 40);
  }

  DateTime? get pregnancyStartDate => lmp; 

  Future<void> setLmp(DateTime date) async {
    lmp = date;
    await AppStorage.setString(AppStorage.lmpDateKey, DateFormat('yyyy-MM-dd').format(date));
  }
}



class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});
  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  List<_WeekInfo> _weeks = [];
  DateTime? _lmp; // последняя менструация
  int _currentWeek = 1;

  @override
  void initState() {
    super.initState();
    _loadWeeks();
    _loadLmp();
  }

  Future<void> _loadWeeks() async {
    final raw = await rootBundle.loadString('assets/pregnancy_weeks.json');
    final data = (jsonDecode(raw) as List).map((e) => _WeekInfo.fromMap(Map<String, dynamic>.from(e))).toList();
    setState(() => _weeks = data);
  }

  void _loadLmp() {
    final s = AppStorage.getString(AppStorage.lmpDateKey, defaultValue: '');
    if (s.isNotEmpty) {
      _lmp = DateTime.parse(s);
      _currentWeek = _calcWeekFromLmp(_lmp!);
    }
    setState(() {});
  }

  int _calcWeekFromLmp(DateTime lmp) {
    final days = DateTime.now().difference(lmp).inDays;
    final w = (days ~/ 7) + 1;
    return w.clamp(1, 40);
  }

  Future<void> _setLmp() async {
    final now = DateTime.now();
    final picked = await showDatePicker(context: context, initialDate: now, firstDate: now.subtract(const Duration(days: 300)), lastDate: now);
    if (picked == null) return;
    _lmp = picked;
    await AppStorage.setString(AppStorage.lmpDateKey, DateFormat('yyyy-MM-dd').format(picked));
    setState(() {
      _currentWeek = _calcWeekFromLmp(picked);
    });
  }

  @override
  Widget build(BuildContext context) {
    final info = _weeks.firstWhere(
      (w) => w.week == _currentWeek,
      orElse: () => _WeekInfo(week: _currentWeek, title: 'Неделя $_currentWeek', body: 'Добавьте данные для этой недели.'),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Таймлайн беременности')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_lmp == null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: const Text('Укажите первый день последней менструации'),
                  subtitle: const Text('Мы рассчитаем текущую неделю'),
                  trailing: ElevatedButton(onPressed: _setLmp, child: const Text('Выбрать')),
                ),
              )
            else
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: Text('LMP: ${DateFormat('dd.MM.yyyy').format(_lmp!)}'),
                  subtitle: Text('Текущая неделя: $_currentWeek'),
                  trailing: TextButton(onPressed: _setLmp, child: const Text('Изменить')),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(onPressed: () => setState(() => _currentWeek = (_currentWeek - 1).clamp(1, 40)), icon: const Icon(Icons.chevron_left)),
                Expanded(
                  child: Slider(
                    value: _currentWeek.toDouble(), min: 1, max: 40, divisions: 39,
                    label: '$_currentWeek',
                    onChanged: (v) => setState(() => _currentWeek = v.toInt()),
                  ),
                ),
                IconButton(onPressed: () => setState(() => _currentWeek = (_currentWeek + 1).clamp(1, 40)), icon: const Icon(Icons.chevron_right)),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(info.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(info.body, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    const Text('Важно:', style: TextStyle(fontWeight: FontWeight.w600)),
                    const Text('Это не медицинская рекомендация. При вопросах — обращайтесь к врачу.'),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _WeekInfo {
  final int week;
  final String title;
  final String body;
  _WeekInfo({required this.week, required this.title, required this.body});

  factory _WeekInfo.fromMap(Map<String, dynamic> map) =>
      _WeekInfo(week: map['week'], title: map['title'], body: map['body']);
}
