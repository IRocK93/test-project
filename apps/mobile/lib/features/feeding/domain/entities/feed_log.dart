enum FeedType {
  BREAST_MILK('BREAST_MILK'),
  FORMULA('FORMULA'),
  SOLID_FOOD('SOLID_FOOD'),
  OTHER('OTHER');

  final String value;
  const FeedType(this.value);

  static FeedType fromString(String value) {
    return FeedType.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => FeedType.OTHER,
    );
  }

  String get typeEmoji {
    switch (this) {
      case FeedType.BREAST_MILK:
        return '🤱';
      case FeedType.FORMULA:
        return '🍼';
      case FeedType.SOLID_FOOD:
        return '🥣';
      case FeedType.OTHER:
        return '🍽️';
    }
  }

  String get displayName {
    switch (this) {
      case FeedType.BREAST_MILK:
        return 'Breast Milk';
      case FeedType.FORMULA:
        return 'Formula';
      case FeedType.SOLID_FOOD:
        return 'Solid Food';
      case FeedType.OTHER:
        return 'Other';
    }
  }
}

enum FeedMethod {
  BOTTLE('BOTTLE'),
  BREAST('BREAST'),
  CUP('CUP'),
  SPOON('SPOON'),
  OTHER('OTHER');

  final String value;
  const FeedMethod(this.value);

  static FeedMethod fromString(String value) {
    return FeedMethod.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => FeedMethod.OTHER,
    );
  }

  String get displayName {
    switch (this) {
      case FeedMethod.BOTTLE:
        return 'Bottle';
      case FeedMethod.BREAST:
        return 'Breast';
      case FeedMethod.CUP:
        return 'Cup';
      case FeedMethod.SPOON:
        return 'Spoon';
      case FeedMethod.OTHER:
        return 'Other';
    }
  }
}

class FeedLog {
  final String id;
  final String babyMonId;
  final FeedType type;
  final FeedMethod? method;
  final double? amountMl;
  final int? durationMinutes;
  final String? side;
  final String? notes;
  final DateTime loggedAt;
  final DateTime createdAt;
  final List<String> localMediaRefs;
  final int xpAwarded;

  FeedLog({
    required this.id,
    required this.babyMonId,
    required this.type,
    this.method,
    this.amountMl,
    this.durationMinutes,
    this.side,
    this.notes,
    required this.loggedAt,
    required this.createdAt,
    this.localMediaRefs = const [],
    this.xpAwarded = 5,
  });

  // Computed properties for UI display
  String get typeEmoji => type.typeEmoji;

  String get summary {
    final amountStr = amountMl != null ? ' ${amountMl!.toStringAsFixed(0)}ml' : '';
    final durationStr = durationMinutes != null ? ' ${durationMinutes}min' : '';
    return '${type.displayName}$amountStr$durationStr';
  }

  factory FeedLog.fromJson(Map<String, dynamic> json) {
    return FeedLog(
      id: json['id'] as String,
      babyMonId: json['babyMonId'] as String,
      type: FeedType.fromString(json['type'] as String),
      method: json['method'] != null 
          ? FeedMethod.fromString(json['method'] as String) 
          : null,
      amountMl: (json['amountMl'] as num?)?.toDouble(),
      durationMinutes: json['durationMinutes'] as int?,
      side: json['side'] as String?,
      notes: json['notes'] as String?,
      loggedAt: DateTime.parse(json['loggedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      localMediaRefs: (json['localMediaRefs'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      xpAwarded: json['xpAwarded'] as int? ?? 5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'babyMonId': babyMonId,
      'type': type.value,
      'method': method?.value,
      'amountMl': amountMl,
      'durationMinutes': durationMinutes,
      'side': side,
      'notes': notes,
      'loggedAt': loggedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'localMediaRefs': localMediaRefs,
      'xpAwarded': xpAwarded,
    };
  }

  FeedLog copyWith({
    String? id,
    String? babyMonId,
    FeedType? type,
    FeedMethod? method,
    double? amountMl,
    int? durationMinutes,
    String? side,
    String? notes,
    DateTime? loggedAt,
    DateTime? createdAt,
    List<String>? localMediaRefs,
    int? xpAwarded,
  }) {
    return FeedLog(
      id: id ?? this.id,
      babyMonId: babyMonId ?? this.babyMonId,
      type: type ?? this.type,
      method: method ?? this.method,
      amountMl: amountMl ?? this.amountMl,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      side: side ?? this.side,
      notes: notes ?? this.notes,
      loggedAt: loggedAt ?? this.loggedAt,
      createdAt: createdAt ?? this.createdAt,
      localMediaRefs: localMediaRefs ?? this.localMediaRefs,
      xpAwarded: xpAwarded ?? this.xpAwarded,
    );
  }
}