import 'package:baby_mon/core/utils/json_utils.dart';

class Allergy {
  final String id;
  final String? name;
  final String? triggers;
  final String? severity;
  final String? treatment;
  final String? status;
  final DateTime? happenedAt;
  final List<AllergyEvent> events;

  const Allergy({
    required this.id,
    this.name,
    this.triggers,
    this.severity,
    this.treatment,
    this.status,
    this.happenedAt,
    this.events = const [],
  });

  factory Allergy.fromJson(Map<String, dynamic> json) {
    final rawEvents = parseList(json['events']);
    return Allergy(
      id: parseString(json['id']) ?? '',
      name: parseString(json['name']),
      triggers: parseString(json['triggers']),
      severity: parseString(json['severity']),
      treatment: parseString(json['treatment']),
      status: parseString(json['status']),
      happenedAt: parseString(json['happenedAt']) != null
          ? DateTime.tryParse(parseString(json['happenedAt'])!)?.toLocal()
          : null,
      events: rawEvents
          .whereType<Map<String, dynamic>>()
          .map(AllergyEvent.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'triggers': triggers,
      'severity': severity,
      'treatment': treatment,
      'status': status,
      'happenedAt': happenedAt?.toIso8601String(),
      'events': events.map((e) => e.toJson()).toList(),
    };
  }

  /// Flattens child [AllergyEvent]s into display-ready maps,
  /// merging parent allergy metadata into each event.
  List<Map<String, dynamic>> get flattenedEvents {
    return events.map((evt) => {
      ...evt.toJson(),
      'allergyName': name,
      'allergyId': id,
      'allergyStatus': status ?? 'ACTIVE',
      'severity': severity,
      'triggers': triggers,
      'treatment': treatment,
      'category': 'ALLERGY_EVENT',
      'title': name ?? 'Allergy',
    }).toList();
  }
}

class AllergyEvent {
  final String id;
  final DateTime? happenedAt;
  final String? notes;

  const AllergyEvent({
    required this.id,
    this.happenedAt,
    this.notes,
  });

  factory AllergyEvent.fromJson(Map<String, dynamic> json) {
    return AllergyEvent(
      id: parseString(json['id']) ?? '',
      happenedAt: parseString(json['happenedAt']) != null
          ? DateTime.tryParse(parseString(json['happenedAt'])!)?.toLocal()
          : null,
      notes: parseString(json['notes']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'happenedAt': happenedAt?.toIso8601String(),
      'notes': notes,
    };
  }
}
