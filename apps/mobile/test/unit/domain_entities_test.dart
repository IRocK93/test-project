import 'package:flutter_test/flutter_test.dart';
import 'package:baby_mon/features/feeding/domain/entities/feed_log.dart';
import 'package:baby_mon/features/health/domain/entities/sleep_log.dart';
import 'package:baby_mon/features/health/domain/entities/health_record.dart';
import 'package:baby_mon/features/health/domain/entities/growth_record.dart';
import 'package:baby_mon/features/health/domain/entities/allergy.dart';
import 'package:baby_mon/features/milestones/domain/entities/milestone.dart';
import 'package:baby_mon/features/dashboard/domain/entities/baby_mon.dart';

void main() {
  group('FeedLog', () {
    group('fromJson', () {
      test('parses all fields correctly', () {
        final json = {
          'id': 'fl-1',
          'type': 'BREASTMILK',
          'amount': 120.5,
          'unit': 'ml',
          'notes': 'Good feeding',
          'happenedAt': '2024-06-15T10:30:00.000Z',
          'syncStatus': 'SYNCED',
        };
        final log = FeedLog.fromJson(json);
        expect(log.id, 'fl-1');
        expect(log.type, 'BREASTMILK');
        expect(log.amount, 120.5);
        expect(log.unit, 'ml');
        expect(log.notes, 'Good feeding');
        expect(log.happenedAt, DateTime.parse('2024-06-15T10:30:00.000Z').toLocal());
        expect(log.syncStatus, 'SYNCED');
      });

      test('handles missing optional fields', () {
        final log = FeedLog.fromJson({'id': 'fl-2', 'type': 'FORMULA'});
        expect(log.amount, isNull);
        expect(log.unit, isNull);
        expect(log.notes, isNull);
        expect(log.happenedAt, isNull);
        expect(log.syncStatus, isNull);
      });

      test('defaults type to BREASTMILK when missing', () {
        final log = FeedLog.fromJson({'id': 'fl-3'});
        expect(log.type, 'BREASTMILK');
      });

      test('defaults id to empty string when missing', () {
        final log = FeedLog.fromJson({'type': 'FORMULA'});
        expect(log.id, '');
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final log = FeedLog(
          id: 'fl-1',
          type: 'FORMULA',
          amount: 150.0,
          unit: 'ml',
          notes: 'Night feed',
          happenedAt: DateTime(2024, 6, 15, 10, 30),
          syncStatus: 'PENDING',
        );
        final json = log.toJson();
        expect(json['id'], 'fl-1');
        expect(json['type'], 'FORMULA');
        expect(json['amount'], 150.0);
        expect(json['unit'], 'ml');
        expect(json['notes'], 'Night feed');
        expect(json['happenedAt'], '2024-06-15T10:30:00.000');
        expect(json['syncStatus'], 'PENDING');
      });

      test('serializes nulls as null', () {
        const log = FeedLog(id: 'fl-2', type: 'BREASTMILK');
        final json = log.toJson();
        expect(json['amount'], isNull);
        expect(json['unit'], isNull);
        expect(json['happenedAt'], isNull);
      });
    });

    group('round-trip', () {
      test('fromJson(toJson()) preserves all fields', () {
        final original = FeedLog(
          id: 'rt-fl',
          type: 'SOLIDS',
          amount: 50.0,
          unit: 'g',
          notes: 'Rice cereal',
          happenedAt: DateTime(2024, 3, 15, 8, 0),
          syncStatus: 'SYNCED',
        );
        final restored = FeedLog.fromJson(original.toJson());
        expect(restored.id, original.id);
        expect(restored.type, original.type);
        expect(restored.amount, original.amount);
        expect(restored.unit, original.unit);
        expect(restored.notes, original.notes);
        expect(restored.happenedAt, original.happenedAt);
        expect(restored.syncStatus, original.syncStatus);
      });
    });
  });

  group('SleepLog', () {
    group('fromJson', () {
      test('parses all fields correctly', () {
        final json = {
          'id': 'sl-1',
          'type': 'NIGHT',
          'startTime': '2024-06-15T20:00:00.000Z',
          'endTime': '2024-06-16T06:00:00.000Z',
          'quality': 'GREAT',
          'notes': 'Slept well',
        };
        final log = SleepLog.fromJson(json);
        expect(log.id, 'sl-1');
        expect(log.type, 'NIGHT');
        expect(log.startTime, DateTime.parse('2024-06-15T20:00:00.000Z').toLocal());
        expect(log.endTime, DateTime.parse('2024-06-16T06:00:00.000Z').toLocal());
        expect(log.quality, 'GREAT');
        expect(log.notes, 'Slept well');
      });

      test('handles missing optional fields', () {
        final log = SleepLog.fromJson({'id': 'sl-2'});
        expect(log.type, isNull);
        expect(log.startTime, isNull);
        expect(log.endTime, isNull);
        expect(log.quality, isNull);
        expect(log.notes, isNull);
      });
    });

    group('computed properties', () {
      test('duration computes correctly', () {
        final log = SleepLog(
          id: 'sl-3',
          startTime: DateTime(2024, 6, 15, 20, 0),
          endTime: DateTime(2024, 6, 16, 6, 0),
        );
        expect(log.duration, const Duration(hours: 10));
      });

      test('duration is null when times missing', () {
        const log = SleepLog(id: 'sl-4');
        expect(log.duration, isNull);
      });

      test('isNap returns true for short daytime sleep', () {
        final log = SleepLog(
          id: 'sl-5',
          startTime: DateTime(2024, 6, 16, 10, 0), // 10 AM
          endTime: DateTime(2024, 6, 16, 11, 30), // 1.5 hours
        );
        expect(log.isNap, isTrue);
      });

      test('isNap returns false for long night sleep', () {
        final log = SleepLog(
          id: 'sl-6',
          startTime: DateTime(2024, 6, 15, 20, 0), // 8 PM
          endTime: DateTime(2024, 6, 16, 6, 0), // 6 AM
        );
        expect(log.isNap, isFalse);
      });

      test('isNap returns false when duration missing', () {
        const log = SleepLog(id: 'sl-7');
        expect(log.isNap, isFalse);
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final log = SleepLog(
          id: 'sl-1',
          type: 'NAP',
          startTime: DateTime(2024, 6, 15, 14, 0),
          endTime: DateTime(2024, 6, 15, 15, 30),
          quality: 'GOOD',
          notes: 'Short nap',
        );
        final json = log.toJson();
        expect(json['id'], 'sl-1');
        expect(json['type'], 'NAP');
        expect(json['startTime'], '2024-06-15T14:00:00.000');
        expect(json['endTime'], '2024-06-15T15:30:00.000');
        expect(json['quality'], 'GOOD');
        expect(json['notes'], 'Short nap');
      });
    });

    group('round-trip', () {
      test('fromJson(toJson()) preserves all fields', () {
        final original = SleepLog(
          id: 'rt-sl',
          type: 'NIGHT',
          startTime: DateTime(2024, 3, 15, 22, 0),
          endTime: DateTime(2024, 3, 16, 7, 0),
          quality: 'GREAT',
          notes: 'Full night',
        );
        final restored = SleepLog.fromJson(original.toJson());
        expect(restored.id, original.id);
        expect(restored.type, original.type);
        expect(restored.startTime, original.startTime);
        expect(restored.endTime, original.endTime);
        expect(restored.quality, original.quality);
        expect(restored.notes, original.notes);
      });
    });
  });

  group('HealthRecord', () {
    group('fromJson', () {
      test('parses all fields correctly', () {
        final json = {
          'id': 'hr-1',
          'category': 'WEIGHT',
          'title': 'Morning weigh-in',
          'value': 5.2,
          'unit': 'kg',
          'notes': 'After feeding',
          'happenedAt': '2024-06-15T08:00:00.000Z',
        };
        final record = HealthRecord.fromJson(json);
        expect(record.id, 'hr-1');
        expect(record.category, 'WEIGHT');
        expect(record.title, 'Morning weigh-in');
        expect(record.value, 5.2);
        expect(record.unit, 'kg');
        expect(record.notes, 'After feeding');
        expect(record.happenedAt, DateTime.parse('2024-06-15T08:00:00.000Z').toLocal());
      });

      test('handles missing optional fields', () {
        final record = HealthRecord.fromJson({'id': 'hr-2', 'category': 'TEMPERATURE'});
        expect(record.title, isNull);
        expect(record.value, isNull);
        expect(record.unit, isNull);
        expect(record.notes, isNull);
        expect(record.happenedAt, isNull);
      });

      test('defaults category to empty string when missing', () {
        final record = HealthRecord.fromJson({'id': 'hr-3'});
        expect(record.category, '');
      });
    });

    group('computed properties', () {
      test('numericValue parses double value', () {
        const record = HealthRecord(id: 'hr-4', category: 'WEIGHT', value: 5.5);
        expect(record.numericValue, 5.5);
      });

      test('numericValue parses string value', () {
        const record = HealthRecord(id: 'hr-5', category: 'WEIGHT', value: '3.2');
        expect(record.numericValue, 3.2);
      });

      test('numericValue parses int value', () {
        const record = HealthRecord(id: 'hr-6', category: 'TEMPERATURE', value: 37);
        expect(record.numericValue, 37.0);
      });

      test('numericValue returns null for null value', () {
        const record = HealthRecord(id: 'hr-7', category: 'WEIGHT');
        expect(record.numericValue, isNull);
      });

      test('numericValue returns null for non-numeric string', () {
        const record = HealthRecord(id: 'hr-8', category: 'WEIGHT', value: 'abc');
        expect(record.numericValue, isNull);
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final record = HealthRecord(
          id: 'hr-1',
          category: 'HEIGHT',
          title: 'Growth check',
          value: 60.5,
          unit: 'cm',
          notes: 'Standing',
          happenedAt: DateTime(2024, 6, 15, 8, 0),
        );
        final json = record.toJson();
        expect(json['id'], 'hr-1');
        expect(json['category'], 'HEIGHT');
        expect(json['title'], 'Growth check');
        expect(json['value'], 60.5);
        expect(json['unit'], 'cm');
        expect(json['notes'], 'Standing');
        expect(json['happenedAt'], '2024-06-15T08:00:00.000');
      });
    });

    group('round-trip', () {
      test('fromJson(toJson()) preserves all fields', () {
        final original = HealthRecord(
          id: 'rt-hr',
          category: 'HEAD_CIRCUMFERENCE',
          title: 'Head check',
          value: 42.0,
          unit: 'cm',
          happenedAt: DateTime(2024, 3, 15, 8, 0),
        );
        final restored = HealthRecord.fromJson(original.toJson());
        expect(restored.id, original.id);
        expect(restored.category, original.category);
        expect(restored.title, original.title);
        expect(restored.value, original.value);
        expect(restored.unit, original.unit);
        expect(restored.happenedAt, original.happenedAt);
      });
    });
  });

  group('GrowthRecord', () {
    group('fromJson', () {
      test('parses all fields correctly', () {
        final json = {
          'id': 'gr-1',
          'type': 'WEIGHT',
          'value': 7.5,
          'unit': 'kg',
          'notes': 'Checkup',
          'measuredAt': '2024-06-15T08:00:00.000Z',
        };
        final record = GrowthRecord.fromJson(json);
        expect(record.id, 'gr-1');
        expect(record.type, 'WEIGHT');
        expect(record.value, 7.5);
        expect(record.unit, 'kg');
        expect(record.notes, 'Checkup');
        expect(record.measuredAt, DateTime.parse('2024-06-15T08:00:00.000Z').toLocal());
      });

      test('defaults type to WEIGHT and value to 0.0', () {
        final record = GrowthRecord.fromJson({'id': 'gr-2'});
        expect(record.type, 'WEIGHT');
        expect(record.value, 0.0);
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final record = GrowthRecord(
          id: 'gr-1',
          type: 'HEIGHT',
          value: 65.0,
          unit: 'cm',
          measuredAt: DateTime(2024, 6, 15),
        );
        final json = record.toJson();
        expect(json['id'], 'gr-1');
        expect(json['type'], 'HEIGHT');
        expect(json['value'], 65.0);
        expect(json['unit'], 'cm');
        expect(json['measuredAt'], '2024-06-15T00:00:00.000');
      });
    });

    group('round-trip', () {
      test('fromJson(toJson()) preserves all fields', () {
        final original = GrowthRecord(
          id: 'rt-gr',
          type: 'HEAD_CIRCUMFERENCE',
          value: 44.0,
          unit: 'cm',
          notes: 'Growing well',
          measuredAt: DateTime(2024, 3, 15, 10, 30),
        );
        final restored = GrowthRecord.fromJson(original.toJson());
        expect(restored.id, original.id);
        expect(restored.type, original.type);
        expect(restored.value, original.value);
        expect(restored.unit, original.unit);
        expect(restored.notes, original.notes);
        expect(restored.measuredAt, original.measuredAt);
      });
    });
  });

  group('Milestone', () {
    group('fromJson', () {
      test('parses all fields correctly', () {
        final json = {
          'id': 'ms-1',
          'title': 'First smile',
          'notes': 'Big gummy smile',
          'happenedAt': '2024-06-15T10:30:00.000Z',
          'syncStatus': 'SYNCED',
        };
        final m = Milestone.fromJson(json);
        expect(m.id, 'ms-1');
        expect(m.title, 'First smile');
        expect(m.notes, 'Big gummy smile');
        expect(m.happenedAt, DateTime.parse('2024-06-15T10:30:00.000Z').toLocal());
        expect(m.syncStatus, 'SYNCED');
      });

      test('handles missing optional fields', () {
        final m = Milestone.fromJson({'id': 'ms-2', 'title': 'Crawling'});
        expect(m.notes, isNull);
        expect(m.happenedAt, isNull);
        expect(m.syncStatus, isNull);
      });

      test('defaults title to empty string when missing', () {
        final m = Milestone.fromJson({'id': 'ms-3'});
        expect(m.title, '');
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final m = Milestone(
          id: 'ms-1',
          title: 'First word',
          notes: 'Said mama',
          happenedAt: DateTime(2024, 6, 15),
          syncStatus: 'PENDING',
        );
        final json = m.toJson();
        expect(json['id'], 'ms-1');
        expect(json['title'], 'First word');
        expect(json['notes'], 'Said mama');
        expect(json['happenedAt'], '2024-06-15T00:00:00.000');
        expect(json['syncStatus'], 'PENDING');
      });
    });

    group('round-trip', () {
      test('fromJson(toJson()) preserves all fields', () {
        final original = Milestone(
          id: 'rt-ms',
          title: 'First steps',
          notes: 'Three steps!',
          happenedAt: DateTime(2024, 3, 15, 14, 0),
          syncStatus: 'SYNCED',
        );
        final restored = Milestone.fromJson(original.toJson());
        expect(restored.id, original.id);
        expect(restored.title, original.title);
        expect(restored.notes, original.notes);
        expect(restored.happenedAt, original.happenedAt);
        expect(restored.syncStatus, original.syncStatus);
      });
    });
  });

  group('BabyMon', () {
    group('fromJson', () {
      test('parses all fields correctly', () {
        final json = {
          'id': 'bm-1',
          'name': 'Luna',
          'gender': 'MONIESE',
          'traits': ['curious', 'gentle'],
          'specialMove': 'Moonbeam',
          'stageStartType': 'BORN',
          'conceptionDate': '2024-01-01T00:00:00.000Z',
          'lmpDate': '2024-01-08T00:00:00.000Z',
          'ideaDate': '2023-12-15T00:00:00.000Z',
          'birthDate': '2024-06-15T10:30:00.000Z',
          'bloodGroup': 'O+',
          'biologicalMother': 'Jane',
          'biologicalFather': 'John',
          'currentXp': 500,
          'currentStage': 3,
        };
        final baby = BabyMon.fromJson(json);
        expect(baby.id, 'bm-1');
        expect(baby.name, 'Luna');
        expect(baby.gender, 'MONIESE');
        expect(baby.traits, ['curious', 'gentle']);
        expect(baby.specialMove, 'Moonbeam');
        expect(baby.stageStartType, 'BORN');
        expect(baby.conceptionDate, DateTime.parse('2024-01-01T00:00:00.000Z').toLocal());
        expect(baby.lmpDate, DateTime.parse('2024-01-08T00:00:00.000Z').toLocal());
        expect(baby.ideaDate, DateTime.parse('2023-12-15T00:00:00.000Z').toLocal());
        expect(baby.birthDate, DateTime.parse('2024-06-15T10:30:00.000Z').toLocal());
        expect(baby.bloodGroup, 'O+');
        expect(baby.biologicalMother, 'Jane');
        expect(baby.biologicalFather, 'John');
        expect(baby.currentXp, 500);
        expect(baby.currentStage, 3);
      });

      test('handles missing optional fields', () {
        final baby = BabyMon.fromJson({'id': 'bm-2'});
        expect(baby.name, isNull);
        expect(baby.gender, isNull);
        expect(baby.traits, isEmpty);
        expect(baby.specialMove, isNull);
        expect(baby.stageStartType, isNull);
        expect(baby.conceptionDate, isNull);
        expect(baby.birthDate, isNull);
        expect(baby.currentXp, 0);
        expect(baby.currentStage, 0);
      });

      test('defaults id to empty string when missing', () {
        final baby = BabyMon.fromJson({});
        expect(baby.id, '');
      });

      test('filters non-string traits', () {
        final baby = BabyMon.fromJson({
          'id': 'bm-3',
          'traits': ['happy', 123, null, 'playful'],
        });
        expect(baby.traits, ['happy', 'playful']);
      });
    });

    group('referenceDate', () {
      test('returns birthDate for BORN stage', () {
        final baby = BabyMon(
          id: 'bm-4',
          stageStartType: 'BORN',
          birthDate: DateTime(2024, 6, 15),
          conceptionDate: DateTime(2024, 1, 1),
        );
        expect(baby.referenceDate, DateTime(2024, 6, 15));
      });

      test('returns conceptionDate for INCUBATING stage', () {
        final baby = BabyMon(
          id: 'bm-5',
          stageStartType: 'INCUBATING',
          birthDate: DateTime(2024, 6, 15),
          conceptionDate: DateTime(2024, 1, 1),
        );
        expect(baby.referenceDate, DateTime(2024, 1, 1));
      });

      test('falls back to lmpDate for INCUBATING when no conceptionDate', () {
        final baby = BabyMon(
          id: 'bm-6',
          stageStartType: 'INCUBATING',
          lmpDate: DateTime(2024, 1, 8),
        );
        expect(baby.referenceDate, DateTime(2024, 1, 8));
      });

      test('returns ideaDate for PLAN stage', () {
        final baby = BabyMon(
          id: 'bm-7',
          stageStartType: 'PLAN',
          ideaDate: DateTime(2023, 12, 15),
          birthDate: DateTime(2024, 6, 15),
        );
        expect(baby.referenceDate, DateTime(2023, 12, 15));
      });

      test('returns null when no reference date available', () {
        const baby = BabyMon(id: 'bm-8');
        expect(baby.referenceDate, isNull);
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final baby = BabyMon(
          id: 'bm-1',
          name: 'Sol',
          gender: 'MONIOUS',
          traits: ['brave'],
          specialMove: 'Sunflare',
          stageStartType: 'INCUBATING',
          conceptionDate: DateTime(2024, 1, 1),
          birthDate: DateTime(2024, 6, 15),
          bloodGroup: 'A+',
          biologicalMother: 'Ana',
          biologicalFather: 'Luis',
          currentXp: 250,
          currentStage: 2,
        );
        final json = baby.toJson();
        expect(json['id'], 'bm-1');
        expect(json['name'], 'Sol');
        expect(json['gender'], 'MONIOUS');
        expect(json['traits'], ['brave']);
        expect(json['specialMove'], 'Sunflare');
        expect(json['stageStartType'], 'INCUBATING');
        expect(json['conceptionDate'], '2024-01-01T00:00:00.000');
        expect(json['birthDate'], '2024-06-15T00:00:00.000');
        expect(json['bloodGroup'], 'A+');
        expect(json['currentXp'], 250);
        expect(json['currentStage'], 2);
      });
    });

    group('round-trip', () {
      test('fromJson(toJson()) preserves all fields', () {
        final original = BabyMon(
          id: 'rt-bm',
          name: 'Star',
          gender: 'MO',
          traits: ['playful', 'sleepy'],
          specialMove: 'Twinkle',
          stageStartType: 'BORN',
          conceptionDate: DateTime(2024, 1, 1),
          lmpDate: DateTime(2024, 1, 8),
          ideaDate: DateTime(2023, 12, 15),
          birthDate: DateTime(2024, 6, 15),
          bloodGroup: 'B+',
          biologicalMother: 'Mia',
          biologicalFather: 'Leo',
          currentXp: 1000,
          currentStage: 5,
        );
        final restored = BabyMon.fromJson(original.toJson());
        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.gender, original.gender);
        expect(restored.traits, original.traits);
        expect(restored.specialMove, original.specialMove);
        expect(restored.stageStartType, original.stageStartType);
        expect(restored.conceptionDate, original.conceptionDate);
        expect(restored.lmpDate, original.lmpDate);
        expect(restored.ideaDate, original.ideaDate);
        expect(restored.birthDate, original.birthDate);
        expect(restored.bloodGroup, original.bloodGroup);
        expect(restored.biologicalMother, original.biologicalMother);
        expect(restored.biologicalFather, original.biologicalFather);
        expect(restored.currentXp, original.currentXp);
        expect(restored.currentStage, original.currentStage);
      });
    });
  });

  group('Allergy', () {
    group('fromJson', () {
      test('parses all fields including events', () {
        final json = {
          'id': 'a-1',
          'name': 'Peanuts',
          'triggers': 'Ingestion',
          'severity': 'Severe',
          'treatment': 'EpiPen',
          'status': 'ACTIVE',
          'happenedAt': '2024-06-15T10:00:00.000Z',
          'events': [
            {
              'id': 'evt-1',
              'happenedAt': '2024-06-16T14:00:00.000Z',
              'notes': 'Mild reaction',
            },
            {
              'id': 'evt-2',
              'happenedAt': '2024-06-20T09:00:00.000Z',
              'notes': 'No reaction this time',
            },
          ],
        };
        final allergy = Allergy.fromJson(json);
        expect(allergy.id, 'a-1');
        expect(allergy.name, 'Peanuts');
        expect(allergy.triggers, 'Ingestion');
        expect(allergy.severity, 'Severe');
        expect(allergy.treatment, 'EpiPen');
        expect(allergy.status, 'ACTIVE');
        expect(allergy.happenedAt, DateTime.parse('2024-06-15T10:00:00.000Z').toLocal());
        expect(allergy.events.length, 2);
        expect(allergy.events[0].id, 'evt-1');
        expect(allergy.events[0].notes, 'Mild reaction');
        expect(allergy.events[1].id, 'evt-2');
      });

      test('handles missing optional fields', () {
        final allergy = Allergy.fromJson({'id': 'a-2'});
        expect(allergy.name, isNull);
        expect(allergy.triggers, isNull);
        expect(allergy.severity, isNull);
        expect(allergy.treatment, isNull);
        expect(allergy.status, isNull);
        expect(allergy.happenedAt, isNull);
        expect(allergy.events, isEmpty);
      });

      test('handles empty events list', () {
        final allergy = Allergy.fromJson({
          'id': 'a-3',
          'events': <dynamic>[],
        });
        expect(allergy.events, isEmpty);
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final allergy = Allergy(
          id: 'a-1',
          name: 'Dust',
          triggers: 'Airborne',
          severity: 'Mild',
          treatment: 'Antihistamine',
          status: 'ACTIVE',
          happenedAt: DateTime(2024, 6, 15),
          events: [
            AllergyEvent(
              id: 'evt-1',
              happenedAt: DateTime(2024, 6, 16),
              notes: 'Sneezing',
            ),
          ],
        );
        final json = allergy.toJson();
        expect(json['id'], 'a-1');
        expect(json['name'], 'Dust');
        expect(json['triggers'], 'Airborne');
        expect(json['severity'], 'Mild');
        expect(json['treatment'], 'Antihistamine');
        expect(json['status'], 'ACTIVE');
        expect(json['happenedAt'], '2024-06-15T00:00:00.000');
        expect(json['events'], isA<List>());
        expect((json['events'] as List).length, 1);
      });
    });

    group('flattenedEvents', () {
      test('merges parent allergy metadata into each event', () {
        const allergy = Allergy(
          id: 'a-1',
          name: 'Peanuts',
          triggers: 'Ingestion',
          severity: 'Severe',
          treatment: 'EpiPen',
          status: 'ACTIVE',
          events: [
            AllergyEvent(id: 'evt-1', notes: 'Reaction'),
            AllergyEvent(id: 'evt-2', notes: 'Mild'),
          ],
        );
        final flat = allergy.flattenedEvents;
        expect(flat.length, 2);
        expect(flat[0]['allergyName'], 'Peanuts');
        expect(flat[0]['allergyId'], 'a-1');
        expect(flat[0]['allergyStatus'], 'ACTIVE');
        expect(flat[0]['severity'], 'Severe');
        expect(flat[0]['triggers'], 'Ingestion');
        expect(flat[0]['treatment'], 'EpiPen');
        expect(flat[0]['category'], 'ALLERGY_EVENT');
        expect(flat[0]['title'], 'Peanuts');
        expect(flat[0]['id'], 'evt-1');
        expect(flat[1]['id'], 'evt-2');
      });

      test('defaults status to ACTIVE when null', () {
        const allergy = Allergy(
          id: 'a-2',
          name: 'Dust',
          events: [AllergyEvent(id: 'evt-1')],
        );
        final flat = allergy.flattenedEvents;
        expect(flat[0]['allergyStatus'], 'ACTIVE');
      });

      test('returns empty list when no events', () {
        const allergy = Allergy(id: 'a-3', name: 'Mold');
        expect(allergy.flattenedEvents, isEmpty);
      });
    });

    group('round-trip', () {
      test('fromJson(toJson()) preserves all fields', () {
        final original = Allergy(
          id: 'rt-a',
          name: 'Cats',
          triggers: 'Dander',
          severity: 'Moderate',
          treatment: 'Benadryl',
          status: 'ACTIVE',
          happenedAt: DateTime(2024, 3, 15),
          events: [
            AllergyEvent(
              id: 'rt-evt-1',
              happenedAt: DateTime(2024, 3, 20),
              notes: 'Scratchy eyes',
            ),
          ],
        );
        final restored = Allergy.fromJson(original.toJson());
        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.triggers, original.triggers);
        expect(restored.severity, original.severity);
        expect(restored.treatment, original.treatment);
        expect(restored.status, original.status);
        expect(restored.happenedAt, original.happenedAt);
        expect(restored.events.length, original.events.length);
        expect(restored.events[0].id, original.events[0].id);
        expect(restored.events[0].notes, original.events[0].notes);
      });
    });
  });

  group('HealthCategory', () {
    group('fromApiKey', () {
      test('resolves known API keys', () {
        expect(HealthCategory.fromApiKey('WEIGHT'), HealthCategory.weight);
        expect(HealthCategory.fromApiKey('HEIGHT'), HealthCategory.height);
        expect(HealthCategory.fromApiKey('HEAD_CIRCUMFERENCE'), HealthCategory.headCircumference);
        expect(HealthCategory.fromApiKey('TEMPERATURE'), HealthCategory.temperature);
        expect(HealthCategory.fromApiKey('HOSPITAL'), HealthCategory.hospital);
        expect(HealthCategory.fromApiKey('CLINIC'), HealthCategory.clinic);
        expect(HealthCategory.fromApiKey('INJURY'), HealthCategory.injury);
        expect(HealthCategory.fromApiKey('BOWEL_MOVEMENT'), HealthCategory.bowelMovement);
        expect(HealthCategory.fromApiKey('VACCINATION'), HealthCategory.vaccination);
        expect(HealthCategory.fromApiKey('ALLERGY'), HealthCategory.allergy);
        expect(HealthCategory.fromApiKey('OTHER'), HealthCategory.other);
        expect(HealthCategory.fromApiKey('ALLERGY_EVENT'), HealthCategory.allergyEvent);
      });

      test('returns null for unknown key', () {
        expect(HealthCategory.fromApiKey('UNKNOWN'), isNull);
        expect(HealthCategory.fromApiKey(null), isNull);
        expect(HealthCategory.fromApiKey(''), isNull);
      });
    });

    group('unitFor', () {
      test('returns metric unit for weight', () {
        expect(HealthCategory.weight.unitFor(true), 'kg');
      });

      test('returns imperial unit for weight', () {
        expect(HealthCategory.weight.unitFor(false), 'lbs');
      });

      test('returns metric unit for height', () {
        expect(HealthCategory.height.unitFor(true), 'cm');
      });

      test('returns imperial unit for height', () {
        expect(HealthCategory.height.unitFor(false), 'in');
      });

      test('returns metric unit for temperature', () {
        expect(HealthCategory.temperature.unitFor(true), '\u00b0C');
      });

      test('returns imperial unit for temperature', () {
        expect(HealthCategory.temperature.unitFor(false), '\u00b0F');
      });

      test('returns empty string for event categories', () {
        expect(HealthCategory.hospital.unitFor(true), '');
        expect(HealthCategory.clinic.unitFor(false), '');
      });
    });

    group('computeValue', () {
      test('weight computes major + minor/1000', () {
        expect(HealthCategory.weight.computeValue(5, 250), 5.25);
        expect(HealthCategory.weight.computeValue(0, 500), 0.5);
        expect(HealthCategory.weight.computeValue(3, 0), 3.0);
      });

      test('height computes major + minor/10', () {
        expect(HealthCategory.height.computeValue(60, 5), 60.5);
        expect(HealthCategory.height.computeValue(0, 3), 0.3);
      });

      test('temperature computes major + minor/10', () {
        expect(HealthCategory.temperature.computeValue(37, 2), 37.2);
        expect(HealthCategory.temperature.computeValue(36, 8), 36.8);
      });

      test('head circumference computes major + minor/10', () {
        expect(HealthCategory.headCircumference.computeValue(42, 3), 42.3);
      });
    });

    group('dial properties', () {
      test('temperature has dialMax of 50', () {
        expect(HealthCategory.temperature.dialMax, 50);
      });

      test('non-temperature categories have dialMax of 200', () {
        expect(HealthCategory.weight.dialMax, 200);
        expect(HealthCategory.height.dialMax, 200);
      });

      test('weight has dialMinorMax of 999', () {
        expect(HealthCategory.weight.dialMinorMax, 999);
      });

      test('non-weight categories have dialMinorMax of 9', () {
        expect(HealthCategory.height.dialMinorMax, 9);
        expect(HealthCategory.temperature.dialMinorMax, 9);
      });

      test('weight has dialMinorStep of 5', () {
        expect(HealthCategory.weight.dialMinorStep, 5);
      });

      test('non-weight categories have dialMinorStep of 1', () {
        expect(HealthCategory.height.dialMinorStep, 1);
        expect(HealthCategory.temperature.dialMinorStep, 1);
      });

      test('weight has 3 decimal places', () {
        expect(HealthCategory.weight.decimalPlaces, 3);
      });

      test('non-weight categories have 1 decimal place', () {
        expect(HealthCategory.height.decimalPlaces, 1);
        expect(HealthCategory.temperature.decimalPlaces, 1);
      });
    });

    group('minorUnit', () {
      test('weight returns g', () {
        expect(HealthCategory.weight.minorUnit, 'g');
      });

      test('height returns mm', () {
        expect(HealthCategory.height.minorUnit, 'mm');
      });

      test('temperature returns .0', () {
        expect(HealthCategory.temperature.minorUnit, '.0');
      });

      test('event categories return empty string', () {
        expect(HealthCategory.hospital.minorUnit, '');
      });
    });

    group('isMeasurement / isEvent', () {
      test('measurement categories have isMeasurement true', () {
        expect(HealthCategory.weight.isMeasurement, isTrue);
        expect(HealthCategory.height.isMeasurement, isTrue);
        expect(HealthCategory.headCircumference.isMeasurement, isTrue);
        expect(HealthCategory.temperature.isMeasurement, isTrue);
      });

      test('event categories have isEvent true', () {
        expect(HealthCategory.hospital.isEvent, isTrue);
        expect(HealthCategory.clinic.isEvent, isTrue);
        expect(HealthCategory.injury.isEvent, isTrue);
        expect(HealthCategory.bowelMovement.isEvent, isTrue);
        expect(HealthCategory.vaccination.isEvent, isTrue);
        expect(HealthCategory.allergy.isEvent, isTrue);
        expect(HealthCategory.other.isEvent, isTrue);
      });
    });

    group('label', () {
      test('labels are human-readable', () {
        expect(HealthCategory.weight.label, 'Weight');
        expect(HealthCategory.headCircumference.label, 'Head Circumference');
        expect(HealthCategory.bowelMovement.label, 'Bowel Movement');
        expect(HealthCategory.allergyEvent.label, 'Allergy');
      });
    });
  });

  group('AllergyEvent', () {
    group('fromJson', () {
      test('parses all fields correctly', () {
        final json = {
          'id': 'evt-1',
          'happenedAt': '2024-06-15T14:00:00.000Z',
          'notes': 'Hives on arm',
        };
        final event = AllergyEvent.fromJson(json);
        expect(event.id, 'evt-1');
        expect(event.happenedAt, DateTime.parse('2024-06-15T14:00:00.000Z').toLocal());
        expect(event.notes, 'Hives on arm');
      });

      test('handles missing optional fields', () {
        final event = AllergyEvent.fromJson({'id': 'evt-2'});
        expect(event.happenedAt, isNull);
        expect(event.notes, isNull);
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final event = AllergyEvent(
          id: 'evt-1',
          happenedAt: DateTime(2024, 6, 15),
          notes: 'Mild',
        );
        final json = event.toJson();
        expect(json['id'], 'evt-1');
        expect(json['happenedAt'], '2024-06-15T00:00:00.000');
        expect(json['notes'], 'Mild');
      });

      test('serializes nulls as null', () {
        const event = AllergyEvent(id: 'evt-2');
        final json = event.toJson();
        expect(json['happenedAt'], isNull);
        expect(json['notes'], isNull);
      });
    });

    group('round-trip', () {
      test('fromJson(toJson()) preserves all fields', () {
        final original = AllergyEvent(
          id: 'rt-evt',
          happenedAt: DateTime(2024, 3, 15, 12, 0),
          notes: 'Reaction noted',
        );
        final restored = AllergyEvent.fromJson(original.toJson());
        expect(restored.id, original.id);
        expect(restored.happenedAt, original.happenedAt);
        expect(restored.notes, original.notes);
      });
    });
  });

  group('FeedType', () {
    group('fromApiKey', () {
      test('resolves known API keys', () {
        expect(FeedType.fromApiKey('BREASTMILK'), FeedType.breastmilk);
        expect(FeedType.fromApiKey('FORMULA'), FeedType.formula);
        expect(FeedType.fromApiKey('SOLID'), FeedType.solid);
      });

      test('returns null for unknown key', () {
        expect(FeedType.fromApiKey('UNKNOWN'), isNull);
        expect(FeedType.fromApiKey(null), isNull);
        expect(FeedType.fromApiKey(''), isNull);
      });
    });

    group('properties', () {
      test('labels are human-readable', () {
        expect(FeedType.breastmilk.label, 'Breastmilk');
        expect(FeedType.formula.label, 'Formula');
        expect(FeedType.solid.label, 'Solid');
      });

      test('short labels exist and are shorter than or equal to label', () {
        for (final ft in FeedType.values) {
          expect(ft.shortLabel.isNotEmpty, isTrue);
          expect(ft.shortLabel.length, lessThanOrEqualTo(ft.label.length));
        }
      });

      test('unit returns correct metric units', () {
        expect(FeedType.breastmilk.unit(true), 'ml');
        expect(FeedType.formula.unit(true), 'ml');
        expect(FeedType.solid.unit(true), 'g');
      });

      test('unit returns correct imperial units', () {
        expect(FeedType.breastmilk.unit(false), 'oz');
        expect(FeedType.formula.unit(false), 'oz');
        expect(FeedType.solid.unit(false), 'g');
      });

      test('all values have non-null icon and color', () {
        for (final ft in FeedType.values) {
          expect(ft.icon, isNotNull);
          expect(ft.color, isNotNull);
        }
      });
    });
  });

  group('SleepType', () {
    group('fromApiKey', () {
      test('resolves known API keys', () {
        expect(SleepType.fromApiKey('NIGHT'), SleepType.night);
        expect(SleepType.fromApiKey('NAP'), SleepType.nap);
      });

      test('returns null for unknown key', () {
        expect(SleepType.fromApiKey('UNKNOWN'), isNull);
        expect(SleepType.fromApiKey(null), isNull);
        expect(SleepType.fromApiKey(''), isNull);
      });
    });

    group('properties', () {
      test('labels are human-readable', () {
        expect(SleepType.night.label, 'Night sleep');
        expect(SleepType.nap.label, 'Nap');
      });

      test('isNight returns correct values', () {
        expect(SleepType.night.isNight, isTrue);
        expect(SleepType.nap.isNight, isFalse);
      });

      test('all values have non-null icon', () {
        for (final st in SleepType.values) {
          expect(st.icon, isNotNull);
        }
      });
    });
  });

  group('SleepQuality', () {
    group('fromApiKey', () {
      test('resolves known API keys', () {
        expect(SleepQuality.fromApiKey('GREAT'), SleepQuality.great);
        expect(SleepQuality.fromApiKey('GOOD'), SleepQuality.good);
        expect(SleepQuality.fromApiKey('FAIR'), SleepQuality.fair);
        expect(SleepQuality.fromApiKey('POOR'), SleepQuality.poor);
      });

      test('returns null for unknown key', () {
        expect(SleepQuality.fromApiKey('UNKNOWN'), isNull);
        expect(SleepQuality.fromApiKey(null), isNull);
        expect(SleepQuality.fromApiKey(''), isNull);
      });
    });

    group('fromNumericValue', () {
      test('resolves known numeric values', () {
        expect(SleepQuality.fromNumericValue(5), SleepQuality.great);
        expect(SleepQuality.fromNumericValue(4), SleepQuality.good);
        expect(SleepQuality.fromNumericValue(2), SleepQuality.fair);
        expect(SleepQuality.fromNumericValue(1), SleepQuality.poor);
      });

      test('handles string numeric values', () {
        expect(SleepQuality.fromNumericValue('5'), SleepQuality.great);
        expect(SleepQuality.fromNumericValue('4'), SleepQuality.good);
        expect(SleepQuality.fromNumericValue('2'), SleepQuality.fair);
        expect(SleepQuality.fromNumericValue('1'), SleepQuality.poor);
      });

      test('returns null for unknown numeric values', () {
        expect(SleepQuality.fromNumericValue(99), isNull);
        expect(SleepQuality.fromNumericValue('abc'), isNull);
        expect(SleepQuality.fromNumericValue(null), isNull);
      });
    });

    group('resolve', () {
      test('resolves string keys', () {
        expect(SleepQuality.resolve('GREAT'), SleepQuality.great);
        expect(SleepQuality.resolve('GOOD'), SleepQuality.good);
      });

      test('resolves numeric string keys', () {
        expect(SleepQuality.resolve('5'), SleepQuality.great);
        expect(SleepQuality.resolve('4'), SleepQuality.good);
      });

      test('falls back to good for null/empty', () {
        expect(SleepQuality.resolve(null), SleepQuality.good);
        expect(SleepQuality.resolve(''), SleepQuality.good);
      });

      test('falls back to good for unknown values', () {
        expect(SleepQuality.resolve('UNKNOWN'), SleepQuality.good);
        expect(SleepQuality.resolve('99'), SleepQuality.good);
      });
    });

    group('fromScore', () {
      test('maps high scores to great', () {
        expect(SleepQuality.fromScore(4.0), SleepQuality.great);
        expect(SleepQuality.fromScore(3.5), SleepQuality.great);
      });

      test('maps medium-high scores to good', () {
        expect(SleepQuality.fromScore(3.4), SleepQuality.good);
        expect(SleepQuality.fromScore(2.5), SleepQuality.good);
      });

      test('maps medium-low scores to fair', () {
        expect(SleepQuality.fromScore(2.4), SleepQuality.fair);
        expect(SleepQuality.fromScore(1.5), SleepQuality.fair);
      });

      test('maps low scores to poor', () {
        expect(SleepQuality.fromScore(1.4), SleepQuality.poor);
        expect(SleepQuality.fromScore(0.5), SleepQuality.poor);
      });

      test('falls back to good for very low scores', () {
        expect(SleepQuality.fromScore(0.0), SleepQuality.good);
        expect(SleepQuality.fromScore(-1.0), SleepQuality.good);
      });
    });

    group('properties', () {
      test('labels are human-readable', () {
        expect(SleepQuality.great.label, 'Great');
        expect(SleepQuality.good.label, 'Good');
        expect(SleepQuality.fair.label, 'Fair');
        expect(SleepQuality.poor.label, 'Poor');
      });

      test('apiNumericValue matches backend expectations', () {
        expect(SleepQuality.great.apiNumericValue, 5);
        expect(SleepQuality.good.apiNumericValue, 4);
        expect(SleepQuality.fair.apiNumericValue, 2);
        expect(SleepQuality.poor.apiNumericValue, 1);
      });

      test('avgScoreValue is used for averaging', () {
        expect(SleepQuality.great.avgScoreValue, 4.0);
        expect(SleepQuality.good.avgScoreValue, 3.0);
        expect(SleepQuality.fair.avgScoreValue, 2.0);
        expect(SleepQuality.poor.avgScoreValue, 1.0);
      });

      test('all values have non-null color', () {
        for (final q in SleepQuality.values) {
          expect(q.color, isNotNull);
        }
      });
    });
  });
}
