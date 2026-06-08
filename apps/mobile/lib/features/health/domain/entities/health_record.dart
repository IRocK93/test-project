enum HealthRecordType {
  VACCINATION,
  CHECKUP,
  ILLNESS,
  MEDICATION,
  GROWTH_MEASUREMENT;

  String get typeEmoji {
    switch (this) {
      case HealthRecordType.VACCINATION:
        return '💉';
      case HealthRecordType.CHECKUP:
        return '🩺';
      case HealthRecordType.ILLNESS:
        return '🤒';
      case HealthRecordType.MEDICATION:
        return '💊';
      case HealthRecordType.GROWTH_MEASUREMENT:
        return '📏';
    }
  }
}

enum HealthRecordStatus { COMPLETED, SCHEDULED, CANCELLED }

class HealthRecord {
  final String id;
  final String babyMonId;
  final HealthRecordType type;
  final HealthRecordStatus status;
  final DateTime date;
  final String? notes;
  final String? doctorName;
  final String? location;
  final DateTime createdAt;

  HealthRecord({
    required this.id,
    required this.babyMonId,
    required this.type,
    required this.status,
    required this.date,
    this.notes,
    this.doctorName,
    this.location,
    required this.createdAt,
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'] ?? '',
      babyMonId: json['babyMonId'] ?? json['baby_mon_id'] ?? '',
      type: HealthRecordType.values.firstWhere(
        (e) => e.name == (json['type'] ?? '').toString().split('.').last,
        orElse: () => HealthRecordType.CHECKUP,
      ),
      status: HealthRecordStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? '').toString().split('.').last,
        orElse: () => HealthRecordStatus.COMPLETED,
      ),
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      notes: json['notes'],
      doctorName: json['doctorName'] ?? json['doctor_name'],
      location: json['location'],
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'babyMonId': babyMonId,
      'type': type.name,
      'status': status.name,
      'date': date.toIso8601String(),
      'notes': notes,
      'doctorName': doctorName,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get typeEmoji {
    switch (type) {
      case HealthRecordType.VACCINATION:
        return '💉';
      case HealthRecordType.CHECKUP:
        return '🩺';
      case HealthRecordType.ILLNESS:
        return '🤒';
      case HealthRecordType.MEDICATION:
        return '💊';
      case HealthRecordType.GROWTH_MEASUREMENT:
        return '📏';
    }
  }

  HealthRecord copyWith({
    String? id,
    String? babyMonId,
    HealthRecordType? type,
    HealthRecordStatus? status,
    DateTime? date,
    String? notes,
    String? doctorName,
    String? location,
    DateTime? createdAt,
  }) {
    return HealthRecord(
      id: id ?? this.id,
      babyMonId: babyMonId ?? this.babyMonId,
      type: type ?? this.type,
      status: status ?? this.status,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      doctorName: doctorName ?? this.doctorName,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
