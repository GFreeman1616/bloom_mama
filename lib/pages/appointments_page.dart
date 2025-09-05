
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});
  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  final List<_Visit> _visits = [];

  Future<void> _add() async {
    final doctorCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    DateTime? dt = DateTime.now();

    final date = await showDatePicker(context: context, firstDate: DateTime.now().subtract(const Duration(days: 1)), lastDate: DateTime.now().add(const Duration(days: 400)), initialDate: dt!);
    if (date == null) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;
    dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Врач и заметка'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: doctorCtrl, decoration: const InputDecoration(labelText: 'Врач/клиника')),
            TextField(controller: noteCtrl, decoration: const InputDecoration(labelText: 'Заметка')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('OK')),
        ],
      ),
    );
    if (ok != true) return;

    setState(() {
      _visits.add(_Visit(dt: dt!, doctor: doctorCtrl.text, note: noteCtrl.text));
      _visits.sort((a, b) => a.dt.compareTo(b.dt));
    });
  }

  void _delete(_Visit v) {
    setState(() => _visits.removeWhere((x) => x == v));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Визиты к врачу')),
      floatingActionButton: FloatingActionButton(onPressed: _add, child: const Icon(Icons.add)),
      body: _visits.isEmpty
          ? const Center(child: Text('Нет записей'))
          : ListView.separated(
              itemCount: _visits.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (_, i) {
                final v = _visits[i];
                return ListTile(
                  leading: const Icon(Icons.event_available),
                  title: Text(DateFormat('dd.MM.yyyy HH:mm').format(v.dt)),
                  subtitle: Text([if (v.doctor.isNotEmpty) v.doctor, if (v.note.isNotEmpty) v.note].join(' • ')),
                  trailing: IconButton(onPressed: () => _delete(v), icon: const Icon(Icons.delete_outline)),
                );
              },
            ),
    );
  }
}

class _Visit {
  final DateTime dt;
  final String doctor;
  final String note;
  _Visit({required this.dt, required this.doctor, required this.note});
}
