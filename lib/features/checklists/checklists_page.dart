import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;

class ChecklistPage extends StatefulWidget {
  const ChecklistPage({super.key});

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, List<String>> _checklists = {};
  Map<String, Set<int>> _checkedItems = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadChecklists();
  }

  Future<void> _loadChecklists() async {
    final prefs = await SharedPreferences.getInstance();

    // Загружаем JSON
    final String jsonString =
        await rootBundle.loadString('assets/checklists.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    setState(() {
      _checklists = {
        "1": List<String>.from(jsonData["first_trimester"]),
        "2": List<String>.from(jsonData["second_trimester"]),
        "3": List<String>.from(jsonData["third_trimester"]),
      };

      // Загружаем состояние чекбоксов
      for (var trimester in ["1", "2", "3"]) {
        _checkedItems[trimester] = (prefs.getStringList("checklist_$trimester") ??
                [])
            .map(int.parse)
            .toSet();
      }
    });
  }

  Future<void> _toggleCheck(String trimester, int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_checkedItems[trimester]!.contains(index)) {
        _checkedItems[trimester]!.remove(index);
      } else {
        _checkedItems[trimester]!.add(index);
      }
    });
    await prefs.setStringList("checklist_$trimester",
        _checkedItems[trimester]!.map((e) => e.toString()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Чек-листы"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "1 триместр"),
            Tab(text: "2 триместр"),
            Tab(text: "3 триместр"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChecklist("1"),
          _buildChecklist("2"),
          _buildChecklist("3"),
        ],
      ),
    );
  }

  Widget _buildChecklist(String trimester) {
    final items = _checklists[trimester] ?? [];
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return CheckboxListTile(
          title: Text(items[index]),
          value: _checkedItems[trimester]?.contains(index) ?? false,
          onChanged: (_) => _toggleCheck(trimester, index),
        );
      },
    );
  }
}
