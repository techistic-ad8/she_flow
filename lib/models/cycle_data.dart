import 'dart:convert';

class CycleData {
  final int cycleLength;      // typical cycle length in days (21-45)
  final int periodLength;     // typical period duration in days (2-10)
  final DateTime lastPeriodDate;
  final int missedMonths;     // number of recently missed periods

  CycleData({
    this.cycleLength = 28,
    this.periodLength = 5,
    DateTime? lastPeriodDate,
    this.missedMonths = 0,
  }) : lastPeriodDate = lastPeriodDate ?? DateTime.now();

  CycleData copyWith({
    int? cycleLength,
    int? periodLength,
    DateTime? lastPeriodDate,
    int? missedMonths,
  }) {
    return CycleData(
      cycleLength: cycleLength ?? this.cycleLength,
      periodLength: periodLength ?? this.periodLength,
      lastPeriodDate: lastPeriodDate ?? this.lastPeriodDate,
      missedMonths: missedMonths ?? this.missedMonths,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cycleLength': cycleLength,
      'periodLength': periodLength,
      'lastPeriodDate': lastPeriodDate.toIso8601String(),
      'missedMonths': missedMonths,
    };
  }

  factory CycleData.fromJson(Map<String, dynamic> json) {
    return CycleData(
      cycleLength: json['cycleLength'] ?? 28,
      periodLength: json['periodLength'] ?? 5,
      lastPeriodDate: json['lastPeriodDate'] != null
          ? DateTime.parse(json['lastPeriodDate'])
          : DateTime.now(),
      missedMonths: json['missedMonths'] ?? 0,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory CycleData.fromJsonString(String jsonString) {
    return CycleData.fromJson(jsonDecode(jsonString));
  }
}

enum FlowLevel { light, medium, heavy }

class PeriodEntry {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final FlowLevel flowLevel;
  final String notes;

  PeriodEntry({
    String? id,
    required this.startDate,
    required this.endDate,
    this.flowLevel = FlowLevel.medium,
    this.notes = '',
  }) : id = id ?? '${startDate.millisecondsSinceEpoch}';

  int get durationDays => endDate.difference(startDate).inDays + 1;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'flowLevel': flowLevel.index,
      'notes': notes,
    };
  }

  factory PeriodEntry.fromJson(Map<String, dynamic> json) {
    return PeriodEntry(
      id: json['id'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      flowLevel: FlowLevel.values[json['flowLevel'] ?? 1],
      notes: json['notes'] ?? '',
    );
  }
}

enum CyclePhase {
  menstrual,    // Day 1-5 (period)
  follicular,   // Day 6-13
  ovulation,    // Day 14
  luteal,       // Day 15-28
}

extension CyclePhaseExtension on CyclePhase {
  String get displayName {
    switch (this) {
      case CyclePhase.menstrual:
        return 'Menstrual';
      case CyclePhase.follicular:
        return 'Follicular';
      case CyclePhase.ovulation:
        return 'Ovulation';
      case CyclePhase.luteal:
        return 'Luteal';
    }
  }

  String get emoji {
    switch (this) {
      case CyclePhase.menstrual:
        return '🩸';
      case CyclePhase.follicular:
        return '🌱';
      case CyclePhase.ovulation:
        return '🥚';
      case CyclePhase.luteal:
        return '🌙';
    }
  }

  String get description {
    switch (this) {
      case CyclePhase.menstrual:
        return 'Your period is here. Take it easy and stay hydrated.';
      case CyclePhase.follicular:
        return 'Energy is rising! Great time for new activities.';
      case CyclePhase.ovulation:
        return 'Peak energy & fertility window.';
      case CyclePhase.luteal:
        return 'Winding down. Focus on self-care.';
    }
  }
}
