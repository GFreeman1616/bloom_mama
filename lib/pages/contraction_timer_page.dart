
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bloom_mama/storage/app_storage.dart';

class ContractionTimerPage extends StatefulWidget {
  const ContractionTimerPage({super.key});
  @override
  State<ContractionTimerPage> createState() => _ContractionTimerPageState();
}

class _ContractionTimerPageState extends State<ContractionTimerPage> {
  Timer? _timer;
  DateTime? _start;
  Duration _elapsed = Duration.zero;
  List<_Contraction> _entries = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final list = AppStorage.getStringList(AppStorage.contractionsKey);
    _entries = list.map((s) => _Contraction.fromJson(s)).toList();
    setState(() {});
  }

  Future<void> _save() async {
    final list = _entries.map((e) => e.toJson()).toList();
    await AppStorage.setStringList(AppStorage.contractionsKey, list);
  }

  void _startTimer() {
    if (_timer != null) return;
    _start = DateTime.now();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      setState(() {
        _elapsed = DateTime.now().difference(_start!);
      });
    });
  }

  Future<void> _stopTimer() async {
    if (_timer == null) return;
    _timer?.cancel();
    _timer = null;
    final end = DateTime.now();
    final duration = end.difference(_start!);
    DateTime? prevEnd = _entries.isNotEmpty ? _entries.last.end : null;
    final interval = prevEnd != null ? end.difference(prevEnd) : null;

    _entries.add(_Contraction(start: _start!, end: end, duration: duration, intervalSincePrev: interval));
    await _save();
    setState(() {
      _start = null;
      _elapsed = Duration.zero;
    });
  }

  Future<void> _clear() async {
    _entries.clear();
    await _save();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final running = _timer != null;
    return Scaffold(
      appBar: AppBar(title: const Text('Схватки')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Таймер схватки', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(_formatDuration(_elapsed), style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: running ? null : _startTimer,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Начать'),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.icon(
                          onPressed: running ? _stopTimer : null,
                          icon: const Icon(Icons.stop),
                          label: const Text('Стоп'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: _clear,
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Очистить'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _entries.isEmpty
                  ? const Center(child: Text('Нет записей'))
                  : ListView.builder(
                      itemCount: _entries.size,
                      itemBuilder: (_, i) {
                        final e = _entries[i];
                        return ListTile(
                          leading: const Icon(Icons.timeline),
                          title: Text('${DateFormat('HH:mm').format(e.start)} — ${_formatDuration(e.duration)}'),
                          subtitle: Text(e.intervalSincePrev == null
                              ? 'Первая запись'
                              : 'Интервал с предыдущей: ${_formatDuration(e.intervalSincePrev!)}'),
                          trailing: Text(DateFormat('dd.MM').format(e.start)),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _Contraction {
  final DateTime start;
  final DateTime end;
  final Duration duration;
  final Duration? intervalSincePrev;
  _Contraction({
    required this.start,
    required this.end,
    required this.duration,
    required this.intervalSincePrev,
  });

  String toJson() => '${start.millisecondsSinceEpoch}|${end.millisecondsSinceEpoch}|${duration.inMilliseconds}|${intervalSincePrev?.inMilliseconds ?? -1}';
  static _Contraction fromJson(String s) {
    final parts = s.split('|').map((e) => int.parse(e)).toList();
    final start = DateTime.fromMillisecondsSinceEpoch(parts[0]);
    final end = DateTime.fromMillisecondsSinceEpoch(parts[1]);
    final dur = Duration(milliseconds: parts[2]);
    final interval = parts[3] == -1 ? null : Duration(milliseconds: parts[3]);
    return _Contraction(start: start, end: end, duration: dur, intervalSincePrev: interval);
  }
}

extension on List<_Contraction> {
  int get size => length;
}
