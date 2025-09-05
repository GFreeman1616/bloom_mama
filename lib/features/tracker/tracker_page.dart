import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'symptom_model.dart';
import 'medicine_model.dart';

class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});

  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Symptom> _symptoms = [];
  List<Medicine> _medicines = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final symptomsData = prefs.getStringList('symptoms') ?? [];
    final medicinesData = prefs.getStringList('medicines') ?? [];

    setState(() {
      _symptoms = symptomsData
          .map((e) => Symptom.fromJson(jsonDecode(e)))
          .toList();
      _medicines = medicinesData
          .map((e) => Medicine.fromJson(jsonDecode(e)))
          .toList();
    });
  }

  Future<void> _saveSymptoms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'symptoms', _symptoms.map((e) => jsonEncode(e.toJson())).toList());
  }

  Future<void> _saveMedicines() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'medicines', _medicines.map((e) => jsonEncode(e.toJson())).toList());
  }

  Future<void> _addSymptom() async {
    String name = '';
    String status = 'не изменилось';
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить симптом'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Название'),
              onChanged: (value) => name = value,
            ),
            DropdownButtonFormField<String>(
              value: status,
              items: ['улучшилось', 'не изменилось', 'ухудшилось']
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) status = v;
              },
              decoration: const InputDecoration(labelText: 'Состояние'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              if (name.isNotEmpty) {
                setState(() {
                  _symptoms.add(Symptom(
                      name: name, dateTime: DateTime.now(), status: status));
                  _saveSymptoms();
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  Future<void> _addMedicine() async {
    String name = '';
    String dose = '';
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить лекарство/витамины'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Название'),
              onChanged: (v) => name = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Доза'),
              onChanged: (v) => dose = v,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              if (name.isNotEmpty) {
                setState(() {
                  _medicines.add(Medicine(
                      name: name, dose: dose, dateTime: DateTime.now()));
                  _saveMedicines();
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsTab() {
    if (_symptoms.isEmpty) return const Center(child: Text('Нет записей'));
    return ListView.builder(
      itemCount: _symptoms.length,
      itemBuilder: (context, index) {
        final s = _symptoms[index];
        return ListTile(
          title: Text(s.name),
          subtitle: Text(
              '${s.status} — ${s.dateTime.toLocal().toString().substring(0, 16)}'),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              setState(() {
                _symptoms.removeAt(index);
                _saveSymptoms();
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildMedicinesTab() {
    if (_medicines.isEmpty) return const Center(child: Text('Нет записей'));
    return ListView.builder(
      itemCount: _medicines.length,
      itemBuilder: (context, index) {
        final m = _medicines[index];
        return ListTile(
          title: Text(m.name),
          subtitle:
              Text('${m.dose} — ${m.dateTime.toLocal().toString().substring(0, 16)}'),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              setState(() {
                _medicines.removeAt(index);
                _saveMedicines();
              });
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Трекер симптомов и лекарств'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Симптомы'),
            Tab(text: 'Лекарства'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildSymptomsTab(), _buildMedicinesTab()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _addSymptom();
          } else {
            _addMedicine();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
