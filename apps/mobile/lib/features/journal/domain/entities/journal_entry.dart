enum JournalEventType { MILESTONE, FEEDING, HEALTH_RECORD, FEED_LOG }

class JournalEntry {
  final String id;
  final String babyMonId;
  final JournalEventType eventType;
  final String title;
  final String? description;
  final String emoji;
  final DateTime date;
  final Map<String, dynamic> metadata;

  JournalEntry({
    required this.id,
    required this.babyMonId,
    required this.eventType,
    required this.title,
    this.description,
    required this.emoji,
    required this.date,
    Map<String, dynamic>? metadata,
  }) : metadata = metadata ?? {};

  factory JournalEntry.fromMilestone(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] ?? '',
      babyMonId: json['babyMonId'] ?? json['baby_mon_id'] ?? '',
      eventType: JournalEventType.MILESTONE,
      title: json['title'] ?? '',
      description: json['description'],
      emoji: _getMilestoneEmoji(json['category']),
      date: DateTime.parse(json['date'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      metadata: json,
    );
  }

  factory JournalEntry.fromFeedLog(Map<String, dynamic> json) {
    final type = json['type'] ?? 'BREAST_MILK';
    return JournalEntry(
      id: json['id'] ?? '',
      babyMonId: json['babyMonId'] ?? json['baby_mon_id'] ?? '',
      eventType: JournalEventType.FEED_LOG,
      title: _getFeedTitle(json),
      description: _getFeedDescription(json),
      emoji: _getFeedEmoji(type),
      date: DateTime.parse(json['loggedAt'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      metadata: json,
    );
  }

  factory JournalEntry.fromHealthRecord(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] ?? '',
      babyMonId: json['babyMonId'] ?? json['baby_mon_id'] ?? '',
      eventType: JournalEventType.HEALTH_RECORD,
      title: _getHealthTitle(json),
      description: json['notes'] ?? json['doctorName'] ?? json['location'],
      emoji: _getHealthEmoji(json['type']),
      date: DateTime.parse(json['date'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      metadata: json,
    );
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    final entryType = json['eventType'] ?? json['entryType'] ?? '';
    
    if (entryType.toString().contains('MILESTONE')) {
      return JournalEntry.fromMilestone(json);
    } else if (entryType.toString().contains('FEED_LOG') || entryType.toString().contains('FEEDING')) {
      return JournalEntry.fromFeedLog(json);
    } else if (entryType.toString().contains('HEALTH_RECORD')) {
      return JournalEntry.fromHealthRecord(json);
    }
    
    // Fallback based on source field if present
    if (json['source'] == 'milestone' || json.containsKey('category')) {
      return JournalEntry.fromMilestone(json);
    } else if (json.containsKey('type') && (json['type'] == 'BREAST_MILK' || json['type'] == 'FORMULA' || json['type'] == 'SOLID_FOOD')) {
      return JournalEntry.fromFeedLog(json);
    } else if (json.containsKey('recordType') || json['type'] == 'VACCINATION' || json['type'] == 'CHECKUP') {
      return JournalEntry.fromHealthRecord(json);
    }
    
    throw Exception('Unknown journal entry type: $entryType');
  }

  static String _getMilestoneEmoji(String? category) {
    switch (category?.toString().toUpperCase()) {
      case 'SLEEP':
        return '😴';
      case 'FEEDING':
        return '🍼';
      case 'DIAPER':
        return '🧷';
      case 'PLAY':
        return '🎮';
      case 'DEVELOPMENT':
        return '🧠';
      case 'HEALTH':
        return '💊';
      case 'FIRSTS':
        return '🌟';
      default:
        return '🌟';
    }
  }

  static String _getFeedTitle(Map<String, dynamic> json) {
    final type = json['type'] ?? 'BREAST_MILK';
    final amount = json['amountMl'] ?? json['amount_ml'];
    final duration = json['durationMinutes'] ?? json['duration_minutes'];
    
    if (amount != null) {
      return '${_feedTypeName(type)} - ${amount}ml';
    } else if (duration != null) {
      return '${_feedTypeName(type)} - ${duration}min';
    }
    return '${_feedTypeName(type)} Feeding';
  }

  static String? _getFeedDescription(Map<String, dynamic> json) {
    final notes = json['notes'];
    final method = json['method'];
    if (notes != null && notes.toString().isNotEmpty) return notes;
    if (method != null) return 'Via ${method.toString().split('.').last}';
    return null;
  }

  static String _feedTypeName(String type) {
    switch (type.toString().toUpperCase()) {
      case 'BREAST_MILK':
        return 'Breast Milk';
      case 'FORMULA':
        return 'Formula';
      case 'SOLID_FOOD':
        return 'Solid Food';
      case 'WATER':
        return 'Water';
      default:
        return type;
    }
  }

  static String _getFeedEmoji(String type) {
    switch (type.toString().toUpperCase()) {
      case 'BREAST_MILK':
        return '🤱';
      case 'FORMULA':
        return '🍼';
      case 'SOLID_FOOD':
        return '🥣';
      case 'WATER':
        return '💧';
      default:
        return '🍼';
    }
  }

  static String _getHealthTitle(Map<String, dynamic> json) {
    final type = json['type'] ?? 'CHECKUP';
    return '${_healthTypeName(type)}';
  }

  static String _healthTypeName(String type) {
    switch (type.toString().toUpperCase()) {
      case 'VACCINATION':
        return 'Vaccination';
      case 'CHECKUP':
        return 'Checkup';
      case 'ILLNESS':
        return 'Illness';
      case 'MEDICATION':
        return 'Medication';
      case 'GROWTH_MEASUREMENT':
        return 'Growth Measurement';
      default:
        return type;
    }
  }

  static String _getHealthEmoji(String? type) {
    switch (type?.toString().toUpperCase()) {
      case 'VACCINATION':
        return '💉';
      case 'CHECKUP':
        return '🩺';
      case 'ILLNESS':
        return '🤒';
      case 'MEDICATION':
        return '💊';
      case 'GROWTH_MEASUREMENT':
        return '📏';
      default:
        return '💊';
    }
  }

  String get sourceBadge {
    switch (eventType) {
      case JournalEventType.MILESTONE:
        return 'Milestone';
      case JournalEventType.FEED_LOG:
      case JournalEventType.FEEDING:
        return 'Feeding';
      case JournalEventType.HEALTH_RECORD:
        return 'Health';
    }
  }

  static String getEmojiForEventType(JournalEventType type) {
    switch (type) {
      case JournalEventType.MILESTONE:
        return '🌟';
      case JournalEventType.FEED_LOG:
      case JournalEventType.FEEDING:
        return '🍼';
      case JournalEventType.HEALTH_RECORD:
        return '💊';
    }
  }
}
