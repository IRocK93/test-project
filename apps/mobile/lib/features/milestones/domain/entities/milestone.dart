import 'package:baby_mon/core/utils/json_utils.dart';

class Milestone {
  final String id;
  final String title;
  final String? notes;
  final DateTime? happenedAt;
  final String? syncStatus;

  const Milestone({
    required this.id,
    required this.title,
    this.notes,
    this.happenedAt,
    this.syncStatus,
  });

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      id: parseString(json['id']) ?? '',
      title: parseString(json['title']) ?? '',
      notes: parseString(json['notes']),
      happenedAt: parseString(json['happenedAt']) != null
          ? DateTime.tryParse(parseString(json['happenedAt'])!)?.toLocal()
          : null,
      syncStatus: parseString(json['syncStatus']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'happenedAt': happenedAt?.toIso8601String(),
      'syncStatus': syncStatus,
    };
  }
}
