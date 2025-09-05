
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bloom_mama/storage/app_storage.dart';

class KickCounterPage extends StatefulWidget {
  const KickCounterPage({super.key});
  @override
  State<KickCounterPage> createState() => _KickCounterPageState();
}

class _KickCounterPageState extends State<KickCounterPage> {
  late String _todayKey;
  List<String> _times = [];

  @override
  void initState() {
    super.initState();
    _todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _load();
  }

  void _load() {
    _times = AppStorage.getStringList(AppStorage.kickListKeyForDate(_todayKey), defaultValue: []);
    setState(() {});
  }

  Future<void> _addKick() async {
    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm').format(now);
    _times.add(timeStr);
    await AppStorage.setStringList(AppStorage.kickListKeyForDate(_todayKey), _times);
    setState(() {});
  }

  Future<void> _undo() async {
    if (_times.isNotEmpty) {
      _times.removeLast();
      await AppStorage.setStringList(AppStorage.kickListKeyForDate(_todayKey), _times);
      setState(() {});
    }
  }

  Future<void> _reset() async {
    _times.clear();
    await AppStorage.setStringList(AppStorage.kickListKeyForDate(_todayKey), _times);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final count = _times.length;
    return Scaffold(
      appBar: AppBar(title: const Text('Шевеления')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addKick,
        icon: const Icon(Icons.favorite),
        label: const Text('Отметить'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Сегодня: $_todayKey', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Шевелений: $count', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(onPressed: _undo, icon: const Icon(Icons.undo), label: const Text('Отмена')),
                const SizedBox(width: 12),
                OutlinedButton.icon(onPressed: _reset, icon: const Icon(Icons.refresh), label: const Text('Сброс')),
              ],
            ),
            const SizedBox(height: 18),
            const Text('Время шевелений:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Expanded(
              child: _times.isEmpty
                  ? const Center(child: Text('Пока пусто'))
                  : ListView.builder(
                      itemCount: _times.length,
                      itemBuilder: (_, i) => ListTile(
                        leading: const Icon(Icons.favorite_border),
                        title: Text(_times[i]),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
