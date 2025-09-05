import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  bool _loading = false;

  Future<void> _saveBackup() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> allData = {};

    // Собираем все ключи и значения
    for (String key in prefs.getKeys()) {
      final value = prefs.get(key);
      allData[key] = value;
    }

    final jsonStr = jsonEncode(allData);

    // Сохраняем в файл
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/bloom_mama_backup.json');
    await file.writeAsString(jsonStr);

    setState(() => _loading = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Резервная копия сохранена: ${file.path}')));
  }

  Future<void> _restoreBackup() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() => _loading = true);
      final file = File(result.files.single.path!);
      final jsonStr = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(jsonStr);

      final prefs = await SharedPreferences.getInstance();
      for (String key in data.keys) {
        final value = data[key];
        if (value is int) {
          await prefs.setInt(key, value);
        } else if (value is double) {
          await prefs.setDouble(key, value);
        } else if (value is bool) {
          await prefs.setBool(key, value);
        } else if (value is String) {
          await prefs.setString(key, value);
        } else if (value is List) {
          await prefs.setStringList(
              key, value.map((e) => e.toString()).toList());
        }
      }

      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Данные восстановлены')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Резервное копирование')),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Сохранить резервную копию'),
                    onPressed: _saveBackup,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.restore),
                    label: const Text('Восстановить из файла'),
                    onPressed: _restoreBackup,
                  ),
                ],
              ),
      ),
    );
  }
}
