class BabyMonSummary {
  final String id;
  final String name;
  final DateTime birthDate;
  final String? imageUrl;
  final String stage; // 'egg', 'hatchling', 'juvenile', 'adult'
  final int level;
  final int currentXp;
  final int xpForNextLevel;
  final int totalXp;
  final List<BadgeInfo> recentBadges;

  BabyMonSummary({
    required this.id,
    required this.name,
    required this.birthDate,
    this.imageUrl,
    required this.stage,
    required this.level,
    required this.currentXp,
    required this.xpForNextLevel,
    required this.totalXp,
    required this.recentBadges,
  });

  factory BabyMonSummary.fromJson(Map<String, dynamic> json) {
    return BabyMonSummary(
      id: json['id'] ?? '',
      name: json['name'] ?? 'BabyMon',
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'])
          : DateTime.now(),
      imageUrl: json['imageUrl'],
      stage: json['stage'] ?? 'egg',
      level: json['level'] ?? 1,
      currentXp: json['currentXp'] ?? 0,
      xpForNextLevel: json['xpForNextLevel'] ?? 100,
      totalXp: json['totalXp'] ?? 0,
      recentBadges: (json['recentBadges'] as List<dynamic>?)
              ?.map((b) => BadgeInfo.fromJson(b))
              .toList() ??
          [],
    );
  }
}

class BadgeInfo {
  final String id;
  final String name;
  final String description;
  final String iconEmoji;
  final DateTime earnedAt;

  BadgeInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.iconEmoji,
    required this.earnedAt,
  });

  factory BadgeInfo.fromJson(Map<String, dynamic> json) {
    return BadgeInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Badge',
      description: json['description'] ?? '',
      iconEmoji: json['iconEmoji'] ?? '🏆',
      earnedAt: json['earnedAt'] != null
          ? DateTime.parse(json['earnedAt'])
          : DateTime.now(),
    );
  }
}
