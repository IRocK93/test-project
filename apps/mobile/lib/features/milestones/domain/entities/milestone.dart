enum MilestoneCategory { SLEEP, FEEDING, DIAPER, PLAY, DEVELOPMENT, HEALTH, FIRSTS }

class Milestone {
  final String id;
  final String babyMonId;
  final String title;
  final String? description;
  final MilestoneCategory category;
  final DateTime date;
  final String? photoUrl;
  final int xpAwarded;
  final DateTime createdAt;

  Milestone({
    required this.id,
    required this.babyMonId,
    required this.title,
    this.description,
    required this.category,
    required this.date,
    this.photoUrl,
    required this.xpAwarded,
    required this.createdAt,
  });

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      id: json['id'],
      babyMonId: json['babyMonId'] ?? json['baby_mon_id'],
      title: json['title'],
      description: json['description'],
      category: MilestoneCategory.values.firstWhere(
        (e) => e.name == (json['category'] ?? '').toString().split('.').last,
        orElse: () => MilestoneCategory.FIRSTS,
      ),
      date: DateTime.parse(json['date']),
      photoUrl: json['photoUrl'] ?? json['photo_url'],
      xpAwarded: json['xpAwarded'] ?? json['xp_awarded'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'babyMonId': babyMonId,
      'title': title,
      'description': description,
      'category': category.name,
      'date': date.toIso8601String(),
      'photoUrl': photoUrl,
      'xpAwarded': xpAwarded,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get categoryEmoji {
    switch (category) {
      case MilestoneCategory.SLEEP:
        return '😴';
      case MilestoneCategory.FEEDING:
        return '🍼';
      case MilestoneCategory.DIAPER:
        return '🧷';
      case MilestoneCategory.PLAY:
        return '🎮';
      case MilestoneCategory.DEVELOPMENT:
        return '🧠';
      case MilestoneCategory.HEALTH:
        return '💊';
      case MilestoneCategory.FIRSTS:
        return '🌟';
    }
  }

  Milestone copyWith({
    String? id,
    String? babyMonId,
    String? title,
    String? description,
    MilestoneCategory? category,
    DateTime? date,
    String? photoUrl,
    int? xpAwarded,
    DateTime? createdAt,
  }) {
    return Milestone(
      id: id ?? this.id,
      babyMonId: babyMonId ?? this.babyMonId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
      photoUrl: photoUrl ?? this.photoUrl,
      xpAwarded: xpAwarded ?? this.xpAwarded,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
