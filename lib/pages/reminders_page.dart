
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bloom_mama/services/notification_service.dart';
import 'package:bloom_mama/storage/app_storage.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});
  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  List<_Reminder> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final list = AppStorage.getStringList(AppStorage.remindersKey);
    _items = list.map((s) => _Reminder.fromJson(s)).toList();
    setState(() {});
  }

  Future<void> _save() async {
    await AppStorage.setStringList(
      AppStorage.remindersKey,
      _items.map((e) => e.toJson()).toList(),
    );
  }

  Future<void> _addDaily() async {
    final titleController = TextEditingController(text: 'Напоминание');
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Название'),
        content: TextField(controller: titleController),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );

    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final r = _Reminder(
      id: id, title: titleController.text.isEmpty ? 'Напоминание' : titleController.text,
      type: 'daily', hour: time.hour, minute: time.minute, enabled: true,
    );
    _items.add(r);
    await _save();
    await NotificationService().scheduleDaily(id: id, hour: r.hour!, minute: r.minute!, title: r.title, body: 'Пора выполнить!');
    setState(() {});
  }

  Future<void> _addOneTime() async {
    final titleController = TextEditingController(text: 'Разовое напоминание');
    DateTime? picked;
    final now = DateTime.now();
    final date = await showDatePicker(context: context, firstDate: now, lastDate: now.add(const Duration(days: 365)), initialDate: now);
    if (date == null) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;
    picked = DateTime(date.year, date.month, date.day, time.hour, time.minute);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Название'),
        content: TextField(controller: titleController),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );

    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final r = _Reminder(
      id: id, title: titleController.text.isEmpty ? 'Разовое напоминание' : titleController.text,
      type: 'once', dateTime: picked, enabled: true,
    );
    _items.add(r);
    await _save();
    await NotificationService().scheduleOneTime(id: id, dateTime: picked!, title: r.title, body: 'Не забудьте');
    setState(() {});
  }

  Future<void> _toggle(_Reminder r, bool value) async {
    r.enabled = value;
    await _save();
    if (!value) {
      await NotificationService().cancel(r.id);
    } else {
      if (r.type == 'daily') {
        await NotificationService().scheduleDaily(id: r.id, hour: r.hour!, minute: r.minute!, title: r.title, body: 'Пора выполнить!');
      } else {
        await NotificationService().scheduleOneTime(id: r.id, dateTime: r.dateTime!, title: r.title, body: 'Не забудьте');
      }
    }
    setState(() {});
  }

  Future<void> _delete(_Reminder r) async {
    _items.removeWhere((e) => e.id == r.id);
    await NotificationService().cancel(r.id);
    await _save();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Напоминания')),
      floatingActionButton: PopupMenuButton<String>(
        icon: const Icon(Icons.add),
        onSelected: (value) {
          if (value == 'daily') _addDaily();
          if (value == 'once') _addOneTime();
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'daily', child: Text('Добавить ежедневное')),
          PopupMenuItem(value: 'once', child: Text('Добавить разовое')),
        ],
      ),
      body: _items.isEmpty
          ? const Center(child: Text('Нет напоминаний'))
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final r = _items[i];
                return ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text(r.title),
                  subtitle: Text(r.type == 'daily'
                      ? 'Ежедневно в ${_two(r.hour!)}:${_two(r.minute!)}'
                      : 'Разово: ${DateFormat('dd.MM.yyyy HH:mm').format(r.dateTime!)}'),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      Switch(value: r.enabled, onChanged: (v) => _toggle(r, v)),
                      IconButton(onPressed: () => _delete(r), icon: const Icon(Icons.delete_outline)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

String _two(int n) => n.toString().padLeft(2, '0');

class _Reminder {
  final int id;
  final String title;
  final String type; // daily | once
  int? hour;
  int? minute;
  DateTime? dateTime;
  bool enabled;

  _Reminder({
    required this.id,
    required this.title,
    required this.type,
    this.hour,
    this.minute,
    this.dateTime,
    required this.enabled,
  });

  String toJson() {
    final dt = dateTime?.millisecondsSinceEpoch ?? -1;
    return '$id|$title|$type|${hour ?? -1}|${minute ?? -1}|$dt|${enabled ? 1 : 0}';
    // простая сериализация строкой
  }

  static _Reminder fromJson(String s) {
    final parts = s.split('|');
    final id = int.parse(parts[0]);
    final title = parts[1];
    final type = parts[2];
    final hour = int.parse(parts[3]);
    final minute = int.parse(parts[4]);
    final dtMs = int.parse(parts[5]);
    final enabled = parts[6] == '1';
    return _Reminder(
      id: id,
      title: title,
      type: type,
      hour: hour == -1 ? null : hour,
      minute: minute == -1 ? null : minute,
      dateTime: dtMs == -1 ? null : DateTime.fromMillisecondsSinceEpoch(dtMs),
      enabled: enabled,
    );
  }
}
