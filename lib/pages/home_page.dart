import 'package:flutter/material.dart';
import 'package:bloom_mama/features/checklists/checklists_page.dart';
import 'package:bloom_mama/features/checklists/backup_page.dart';
import 'package:bloom_mama/features/tracker/tracker_page.dart';
import 'package:bloom_mama/features/baby_size/baby_size_page.dart';
import 'package:bloom_mama/pages/timeline_page.dart';

class HomePage extends StatelessWidget {
  final Timeline timeline; // сюда передаем данные таймлайна

  const HomePage({super.key, required this.timeline});

  @override
  Widget build(BuildContext context) {
    final items = <_HomeItem>[
      _HomeItem('Счётчик шевелений', Icons.favorite, '/kick', 'Отметка каждой шевеления малыша'),
      _HomeItem('Схватки', Icons.timer, '/contractions', 'Таймер длительности и интервалов'),
      _HomeItem('Вода', Icons.local_drink, '/water', 'Дневная цель и прогресс'),
      _HomeItem('Напоминания', Icons.notifications_active, '/reminders', 'Ежедневные и разовые'),
      _HomeItem('Вес', Icons.monitor_weight, '/weight', 'Запись веса по датам'),
      _HomeItem('Таймлайн', Icons.baby_changing_station, '/timeline', 'Неделя за неделей'),
      _HomeItem('Визиты', Icons.event_available, '/appointments', 'Приёмы у врача'),
      _HomeItem('Заметки', Icons.notes, '/notes', 'Мысли, симптомы, вопросы'),
      _HomeItem('Чек-листы', Icons.check_circle_outline, '/checklists', 'Полезные задачи по триместрам'),
      _HomeItem('Резервное копирование', Icons.backup, '/backup', 'Сохранить и восстановить данные'),
      _HomeItem('Трекер симптомов', Icons.local_hospital, '/tracker', 'Записывай свои симптомы и лекарства'),
      _HomeItem('Размер малыша', Icons.cake, '/babysize', 'Смотри на какой фрукт похож малыш сейчас'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Bloom Mama')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) => _FeatureCard(item: items[i], timeline: timeline),
        ),
      ),
    );
  }
}

class _HomeItem {
  final String title;
  final IconData icon;
  final String route;
  final String subtitle;
  _HomeItem(this.title, this.icon, this.route, this.subtitle);
}

class _FeatureCard extends StatelessWidget {
  final _HomeItem item;
  final Timeline timeline;
  const _FeatureCard({required this.item, required this.timeline, super.key});

  int getCurrentWeek(DateTime? startDate) {
    if (startDate == null) return 1; // если дата LMP не задана — неделя 1
    final now = DateTime.now();
    final difference = now.difference(startDate);
    return (difference.inDays / 7).ceil().clamp(1, 40);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (item.title == "Чек-листы") {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ChecklistPage()));
        } else if (item.title == "Резервное копирование") {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupPage()));
        } else if (item.title == "Трекер симптомов") {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackerPage()));
        } else if (item.title == "Размер малыша") {
          if (timeline.pregnancyStartDate != null) {
            final week = getCurrentWeek(timeline.pregnancyStartDate);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BabySizePage(currentWeek: week)),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Сначала укажите дату последней менструации')),
            );
          }
        } else {
          Navigator.pushNamed(context, item.route);
        }
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(radius: 26, child: Icon(item.icon, size: 28)),
              const Spacer(),
              Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(item.subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }
}
