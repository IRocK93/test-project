enum ActivityType { feeding, diaper, sleep, growth }

class Activity {
  final String id;
  final ActivityType type;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  final int xpEarned;

  Activity({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.data,
    required this.xpEarned,
  });

  factory Activity.fromJsonMap(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] ?? '',
      type: ActivityType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ActivityType.feeding,
      ),
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      data: json['data'] ?? {},
      xpEarned: json['xpEarned'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'timestamp': timestamp.toIso8601String(),
    'data': data,
    'xpEarned': xpEarned,
  };
}