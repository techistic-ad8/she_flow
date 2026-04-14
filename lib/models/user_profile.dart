import 'dart:convert';

class UserProfile {
  final String name;
  final String email;
  final int age;
  final String activityLevel; // sedentary, light, moderate, active, veryActive
  final String waterIntake;   // <4, 4-6, 6-8, 8+
  final int stressLevel;      // 1-5
  final double sleepHours;
  final List<String> medicalConditions;
  final bool onMedication;
  final String medicationDetails;

  UserProfile({
    required this.name,
    required this.email,
    this.age = 0,
    this.activityLevel = 'moderate',
    this.waterIntake = '6-8',
    this.stressLevel = 2,
    this.sleepHours = 7,
    this.medicalConditions = const [],
    this.onMedication = false,
    this.medicationDetails = '',
  });

  UserProfile copyWith({
    String? name,
    String? email,
    int? age,
    String? activityLevel,
    String? waterIntake,
    int? stressLevel,
    double? sleepHours,
    List<String>? medicalConditions,
    bool? onMedication,
    String? medicationDetails,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      activityLevel: activityLevel ?? this.activityLevel,
      waterIntake: waterIntake ?? this.waterIntake,
      stressLevel: stressLevel ?? this.stressLevel,
      sleepHours: sleepHours ?? this.sleepHours,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      onMedication: onMedication ?? this.onMedication,
      medicationDetails: medicationDetails ?? this.medicationDetails,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'age': age,
      'activityLevel': activityLevel,
      'waterIntake': waterIntake,
      'stressLevel': stressLevel,
      'sleepHours': sleepHours,
      'medicalConditions': medicalConditions,
      'onMedication': onMedication,
      'medicationDetails': medicationDetails,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      age: json['age'] ?? 0,
      activityLevel: json['activityLevel'] ?? 'moderate',
      waterIntake: json['waterIntake'] ?? '6-8',
      stressLevel: json['stressLevel'] ?? 2,
      sleepHours: (json['sleepHours'] ?? 7).toDouble(),
      medicalConditions: List<String>.from(json['medicalConditions'] ?? []),
      onMedication: json['onMedication'] ?? false,
      medicationDetails: json['medicationDetails'] ?? '',
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory UserProfile.fromJsonString(String jsonString) {
    return UserProfile.fromJson(jsonDecode(jsonString));
  }
}
