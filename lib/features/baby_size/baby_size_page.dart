import 'package:flutter/material.dart';
import 'baby_size_model.dart'; // Импортируем модель и список babySizes

class BabySizePage extends StatefulWidget {
  final int currentWeek;
  const BabySizePage({super.key, required this.currentWeek});

  @override
  State<BabySizePage> createState() => _BabySizePageState();
}

class _BabySizePageState extends State<BabySizePage> {
  late int week;

  @override
  void initState() {
    super.initState();
    week = widget.currentWeek;
  }

  void _changeWeek(int delta) {
    setState(() {
      week = (week + delta).clamp(1, 40);
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = babySizes.firstWhere(
      (b) => b.week == week,
      orElse: () => babySizes.last,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Размер малыша')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Картинка фрукта
            Image.asset(
              current.imageAsset,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            // Название фрукта и неделя
            Text(
              'Неделя $week — ${current.fruitName}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Длина и вес
            Text(
              'Длина: ${current.length} см, Вес: ${current.weight} г',
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            // Кнопки переключения недели
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _changeWeek(-1),
                  child: const Text('Предыдущая'),
                ),
                ElevatedButton(
                  onPressed: () => _changeWeek(1),
                  child: const Text('Следующая'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
