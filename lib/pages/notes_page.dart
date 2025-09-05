
import 'package:flutter/material.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});
  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final List<_Note> _notes = [];

  Future<void> _add() async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Новая заметка'),
        content: TextField(controller: controller, maxLines: 5),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Сохранить')),
        ],
      ),
    );
    if (ok == true && controller.text.trim().isNotEmpty) {
      setState(() => _notes.add(_Note(text: controller.text.trim(), created: DateTime.now())));
    }
  }

  void _delete(_Note n) {
    setState(() => _notes.remove(n));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Заметки')),
      floatingActionButton: FloatingActionButton(onPressed: _add, child: const Icon(Icons.add)),
      body: _notes.isEmpty
          ? const Center(child: Text('Нет заметок'))
          : ListView.separated(
              itemCount: _notes.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (_, i) {
                final n = _notes[i];
                return ListTile(
                  leading: const Icon(Icons.notes),
                  title: Text(n.text),
                  subtitle: Text(n.created.toLocal().toString().substring(0, 16)),
                  trailing: IconButton(onPressed: () => _delete(n), icon: const Icon(Icons.delete_outline)),
                );
              },
            ),
    );
  }
}

class _Note {
  final String text;
  final DateTime created;
  _Note({required this.text, required this.created});
}
