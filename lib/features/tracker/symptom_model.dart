class Symptom {
  final String name;
  final DateTime dateTime;
  final String status; // "улучшилось", "не изменилось", "ухудшилось"

  Symptom({required this.name, required this.dateTime, required this.status});

  Map<String, dynamic> toJson() => {
        'name': name,
        'dateTime': dateTime.toIso8601String(),
        'status': status,
      };

  factory Symptom.fromJson(Map<String, dynamic> json) => Symptom(
        name: json['name'],
        dateTime: DateTime.parse(json['dateTime']),
        status: json['status'],
      );
}
