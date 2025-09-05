class BabySize {
  final int week;
  final String fruitName;
  final String imageAsset;
  final double length; // см
  final double weight; // г

  BabySize({
    required this.week,
    required this.fruitName,
    required this.imageAsset,
    required this.length,
    required this.weight,
  });
}

// Полный список фруктов на 40 недель
final List<BabySize> babySizes = [
  BabySize(week: 4, fruitName: "Маковое зерно", imageAsset: "assets/fruits/poppy_seed.png", length: 0.1, weight: 0.1),
  BabySize(week: 5, fruitName: "Семечко кунжута", imageAsset: "assets/fruits/sesame_seed.png", length: 0.2, weight: 0.2),
  BabySize(week: 6, fruitName: "Горошина", imageAsset: "assets/fruits/pea.png", length: 0.4, weight: 1),
  BabySize(week: 7, fruitName: "Черешня", imageAsset: "assets/fruits/cherry.png", length: 1.3, weight: 2),
  BabySize(week: 8, fruitName: "Лайм", imageAsset: "assets/fruits/lime.png", length: 1.6, weight: 3),
  BabySize(week: 9, fruitName: "Фундук", imageAsset: "assets/fruits/hazelnut.png", length: 2.3, weight: 4),
  BabySize(week: 10, fruitName: "Маракуйя", imageAsset: "assets/fruits/passion_fruit.png", length: 3.1, weight: 5),
  BabySize(week: 11, fruitName: "Инжир", imageAsset: "assets/fruits/fig.png", length: 4, weight: 7),
  BabySize(week: 12, fruitName: "Лимон", imageAsset: "assets/fruits/lemon.png", length: 5, weight: 14),
  BabySize(week: 13, fruitName: "Лайм", imageAsset: "assets/fruits/lime.png", length: 7, weight: 23),
  BabySize(week: 14, fruitName: "Апельсин", imageAsset: "assets/fruits/orange.png", length: 8.5, weight: 43),
  BabySize(week: 15, fruitName: "Грейпфрут", imageAsset: "assets/fruits/grapefruit.png", length: 10.1, weight: 70),
  BabySize(week: 16, fruitName: "Авокадо", imageAsset: "assets/fruits/avocado.png", length: 11.6, weight: 100),
  BabySize(week: 17, fruitName: "Крупный персик", imageAsset: "assets/fruits/peach.png", length: 13, weight: 140),
  BabySize(week: 18, fruitName: "Груша", imageAsset: "assets/fruits/pear.png", length: 14.2, weight: 190),
  BabySize(week: 19, fruitName: "Манго", imageAsset: "assets/fruits/mango.png", length: 15.3, weight: 240),
  BabySize(week: 20, fruitName: "Банан", imageAsset: "assets/fruits/banana.png", length: 25.6, weight: 300),
  BabySize(week: 21, fruitName: "Морковь", imageAsset: "assets/fruits/carrot.png", length: 26.7, weight: 360),
  BabySize(week: 22, fruitName: "Кокос", imageAsset: "assets/fruits/coconut.png", length: 27.8, weight: 430),
  BabySize(week: 23, fruitName: "Папайя", imageAsset: "assets/fruits/papaya.png", length: 28.9, weight: 501),
  BabySize(week: 24, fruitName: "Канталупа", imageAsset: "assets/fruits/cantaloupe.png", length: 30, weight: 600),
  BabySize(week: 25, fruitName: "Помело", imageAsset: "assets/fruits/pomelo.png", length: 34, weight: 660),
  BabySize(week: 26, fruitName: "Кабачок", imageAsset: "assets/fruits/zucchini.png", length: 35.6, weight: 760),
  BabySize(week: 27, fruitName: "Сливы", imageAsset: "assets/fruits/plum.png", length: 36.6, weight: 875),
  BabySize(week: 28, fruitName: "Батат", imageAsset: "assets/fruits/sweet_potato.png", length: 37.6, weight: 1005),
  BabySize(week: 29, fruitName: "Кокос", imageAsset: "assets/fruits/coconut.png", length: 38.6, weight: 1153),
  BabySize(week: 30, fruitName: "Кабачок", imageAsset: "assets/fruits/zucchini.png", length: 39.9, weight: 1319),
  BabySize(week: 31, fruitName: "Сельдерей", imageAsset: "assets/fruits/celery.png", length: 41.1, weight: 1502),
  BabySize(week: 32, fruitName: "Ананас", imageAsset: "assets/fruits/pineapple.png", length: 42.4, weight: 1702),
  BabySize(week: 33, fruitName: "Папайя", imageAsset: "assets/fruits/papaya.png", length: 43.7, weight: 1918),
  BabySize(week: 34, fruitName: "Кабачок", imageAsset: "assets/fruits/zucchini.png", length: 45, weight: 2146),
  BabySize(week: 35, fruitName: "Свинка", imageAsset: "assets/fruits/pumpkin.png", length: 46.2, weight: 2383),
  BabySize(week: 36, fruitName: "Слива", imageAsset: "assets/fruits/plum.png", length: 47.4, weight: 2622),
  BabySize(week: 37, fruitName: "Дыня", imageAsset: "assets/fruits/melon.png", length: 48.6, weight: 2859),
  BabySize(week: 38, fruitName: "Тыква", imageAsset: "assets/fruits/pumpkin.png", length: 49.8, weight: 3083),
  BabySize(week: 39, fruitName: "Большая тыква", imageAsset: "assets/fruits/pumpkin.png", length: 50, weight: 3300),
  BabySize(week: 40, fruitName: "Арбуз", imageAsset: "assets/fruits/watermelon.png", length: 51, weight: 3500),
];
