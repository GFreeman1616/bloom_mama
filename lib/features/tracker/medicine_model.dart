class Medicine {
  final String name;
  final String dose;
  final DateTime dateTime;

  Medicine({required this.name, required this.dose, required this.dateTime});

  Map<String, dynamic> toJson() => {
        'name': name,
        'dose': dose,
        'dateTime': dateTime.toIso8601String(),
      };

  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine(
        name: json['name'],
        dose: json['dose'],
        dateTime: DateTime.parse(json['dateTime']),
      );
}
