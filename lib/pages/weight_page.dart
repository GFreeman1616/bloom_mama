
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bloom_mama/storage/app_storage.dart';

class WeightPage extends StatefulWidget {
  const WeightPage({super.key});
  @override
  State<WeightPage> createState() => _WeightPageState();
}

class _WeightPageState extends State<WeightPage> {
  List<_Entry> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final list = AppStorage.getStringList(AppStorage.weightListKey);
    _items = list.map((s) => _Entry.fromJson(s)).toList();
    setState(() {});
  }

  Future<void> _save() async {
    await AppStorage.setStringList(
      AppStorage.weightListKey,
      _items.map((e) => e.toJson()).toList(),
    );
  }

  Future<void> _add() async {
    final controller = TextEditingController();
    final date = await showDatePicker(
      context: context, initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 300)),
      lastDate: DateTime.now().add(const Duration(days: 300)),
    );
    if (date == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Вес (кг)'),
        content: TextField(controller: controller, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('OK')),
        ],
      ),
    );
    if (ok != true) return;
    final kg = double.tryParse(controller.text.replaceAll(',', '.'));
    if (kg == null) return;
    _items.add(_Entry(date: date, kg: kg));
    _items.sort((a, b) => a.date.compareTo(b.date));
    await _save();
    setState(() {});
  }

  Future<void> _delete(_Entry e) async {
    _items.removeWhere((x) => x.date == e.date && x.kg == e.kg);
    await _save();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Вес')),
      floatingActionButton: FloatingActionButton(onPressed: _add, child: const Icon(Icons.add)),
      body: _items.isEmpty
          ? const Center(child: Text('Нет записей'))
          : ListView.separated(
              itemCount: _items.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (_, i) {
                final e = _items[i];
                return ListTile(
                  leading: const Icon(Icons.monitor_weight_outlined),
                  title: Text('${e.kg.toStringAsFixed(1)} кг'),
                  subtitle: Text(DateFormat('dd.MM.yyyy').format(e.date)),
                  trailing: IconButton(onPressed: () => _delete(e), icon: const Icon(Icons.delete_outline)),
                );
              },
            ),
    );
  }
}

class _Entry {
  final DateTime date;
  final double kg;
  _Entry({required this.date, required this.kg});

  String toJson() => '${date.millisecondsSinceEpoch}|$kg';
  static _Entry fromJson(String s) {
    final p = s.split('|');
    return _Entry(date: DateTime.fromMillisecondsSinceEpoch(int.parse(p[0])), kg: double.parse(p[1]));
  }
}
