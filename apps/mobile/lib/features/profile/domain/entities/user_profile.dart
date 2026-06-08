class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final int totalXp;
  final int level;
  final List<String> badges;
  final Map<String, dynamic> babyInfo;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.totalXp,
    required this.level,
    required this.badges,
    required this.babyInfo,
  });

  factory UserProfile.empty() => UserProfile(
        id: '',
        name: '',
        email: '',
        totalXp: 0,
        level: 1,
        badges: [],
        babyInfo: {},
      );

  factory UserProfile.fromJsonMap(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'],
      totalXp: json['totalXp'] ?? 0,
      level: json['level'] ?? 1,
      badges: List<String>.from(json['badges'] ?? []),
      babyInfo: json['babyInfo'] ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
        'totalXp': totalXp,
        'level': level,
        'badges': badges,
        'babyInfo': babyInfo,
      };

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    int? totalXp,
    int? level,
    List<String>? badges,
    Map<String, dynamic>? babyInfo,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      badges: badges ?? this.badges,
      babyInfo: babyInfo ?? this.babyInfo,
    );
  }
}