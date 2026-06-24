import 'package:baby_mon/core/utils/json_utils.dart';

class BabyMon {
  final String id;
  final String? name;
  final String? middleName;
  final String? lastName;
  final String? gender;
  final List<String> traits;
  final String? specialMove;
  final String? stageStartType;
  final DateTime? conceptionDate;
  final DateTime? lmpDate;
  final DateTime? ideaDate;
  final DateTime? birthDate;
  final String? bloodGroup;
  final String? eyeColor;
  final String? biologicalMother;
  final String? biologicalFather;
  final int currentXp;
  final int currentStage;

  const BabyMon({
    required this.id,
    this.name,
    this.middleName,
    this.lastName,
    this.gender,
    this.traits = const [],
    this.specialMove,
    this.stageStartType,
    this.conceptionDate,
    this.lmpDate,
    this.ideaDate,
    this.birthDate,
    this.bloodGroup,
    this.eyeColor,
    this.biologicalMother,
    this.biologicalFather,
    this.currentXp = 0,
    this.currentStage = 0,
  });

  factory BabyMon.fromJson(Map<String, dynamic> json) {
    return BabyMon(
      id: parseString(json['id']) ?? '',
      name: parseString(json['name']),
      middleName: parseString(json['middleName']),
      lastName: parseString(json['lastName']),
      gender: parseString(json['gender']),
      traits: parseList(json['traits']).whereType<String>().toList(),
      specialMove: parseString(json['specialMove']),
      stageStartType: parseString(json['stageStartType']),
      conceptionDate: _parseDate(json['conceptionDate']),
      lmpDate: _parseDate(json['lmpDate']),
      ideaDate: _parseDate(json['ideaDate']),
      birthDate: _parseDate(json['birthDate']),
      bloodGroup: parseString(json['bloodGroup']),
      eyeColor: parseString(json['eyeColor']),
      biologicalMother: parseString(json['biologicalMother']),
      biologicalFather: parseString(json['biologicalFather']),
      currentXp: parseInt(json['currentXp']) ?? 0,
      currentStage: parseInt(json['currentStage']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'middleName': middleName,
      'lastName': lastName,
      'gender': gender,
      'traits': traits,
      'specialMove': specialMove,
      'stageStartType': stageStartType,
      'conceptionDate': conceptionDate?.toIso8601String(),
      'lmpDate': lmpDate?.toIso8601String(),
      'ideaDate': ideaDate?.toIso8601String(),
      'birthDate': birthDate?.toIso8601String(),
      'bloodGroup': bloodGroup,
      'eyeColor': eyeColor,
      'biologicalMother': biologicalMother,
      'biologicalFather': biologicalFather,
      'currentXp': currentXp,
      'currentStage': currentStage,
    };
  }

  /// Reference date for stage calculation (conception, idea, or birth).
  DateTime? get referenceDate {
    switch (stageStartType) {
      case 'INCUBATING':
        return conceptionDate ?? lmpDate;
      case 'PLAN':
        return ideaDate;
      case 'BORN':
      default:
        return birthDate;
    }
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String) return DateTime.tryParse(value)?.toLocal();
    if (value is DateTime) return value;
    return null;
  }
}
