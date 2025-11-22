// education_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class EducationModel {
  final String id;
  final String title;
  final String description;
  final String duration;
  final String institutionType;
  final String educationLevel;
  final String industryId;
  final String industryName;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  // Additional fields
  final String? costRange;
  final String? learningMode;
  final String? admissionRequirements;
  final String? careerOutcomes;
  final String? averageSalary;
  final String? accreditation;
  final List<String> workEnvironments;
  final List<String> prerequisites;

  EducationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.institutionType,
    required this.educationLevel,
    required this.industryId,
    required this.industryName,
    this.createdAt,
    this.updatedAt,
    
    // New fields
    this.costRange,
    this.learningMode,
    this.admissionRequirements,
    this.careerOutcomes,
    this.averageSalary,
    this.accreditation,
    this.workEnvironments = const [],
    this.prerequisites = const [],
  });

  factory EducationModel.fromMap(Map<String, dynamic> data, {String? id}) {
    List<String> _listOfStrings(dynamic v) {
      if (v == null) return [];
      if (v is List) {
        return v
            .map((e) => e?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toList();
      }
      return [];
    }

    return EducationModel(
      id: id ?? data['id']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      duration: data['duration']?.toString() ?? '',
      institutionType: data['institutionType']?.toString() ?? '',
      educationLevel: data['educationLevel']?.toString() ?? '',
      industryId: data['industryId']?.toString() ?? '',
      industryName: data['industryName']?.toString() ?? '',
      createdAt: data['createdAt'] is Timestamp
          ? data['createdAt'] as Timestamp
          : null,
      updatedAt: data['updatedAt'] is Timestamp
          ? data['updatedAt'] as Timestamp
          : null,
      
      // New fields
      costRange: data['costRange']?.toString(),
      learningMode: data['learningMode']?.toString(),
      admissionRequirements: data['admissionRequirements']?.toString(),
      careerOutcomes: data['careerOutcomes']?.toString(),
      averageSalary: data['averageSalary']?.toString(),
      accreditation: data['accreditation']?.toString(),
      workEnvironments: _listOfStrings(data['workEnvironments']),
      prerequisites: _listOfStrings(data['prerequisites']),
    );
  }

  factory EducationModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return EducationModel.fromMap(data, id: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'duration': duration,
      'institutionType': institutionType,
      'educationLevel': educationLevel,
      'industryId': industryId,
      'industryName': industryName,
      'costRange': costRange,
      'learningMode': learningMode,
      'admissionRequirements': admissionRequirements,
      'careerOutcomes': careerOutcomes,
      'averageSalary': averageSalary,
      'accreditation': accreditation,
      'workEnvironments': workEnvironments,
      'prerequisites': prerequisites,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Copy with method
  EducationModel copyWith({
    String? id,
    String? title,
    String? description,
    String? duration,
    String? institutionType,
    String? educationLevel,
    String? industryId,
    String? industryName,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    String? costRange,
    String? learningMode,
    String? admissionRequirements,
    String? careerOutcomes,
    String? averageSalary,
    String? accreditation,
    List<String>? workEnvironments,
    List<String>? prerequisites,
  }) {
    return EducationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      institutionType: institutionType ?? this.institutionType,
      educationLevel: educationLevel ?? this.educationLevel,
      industryId: industryId ?? this.industryId,
      industryName: industryName ?? this.industryName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      costRange: costRange ?? this.costRange,
      learningMode: learningMode ?? this.learningMode,
      admissionRequirements: admissionRequirements ?? this.admissionRequirements,
      careerOutcomes: careerOutcomes ?? this.careerOutcomes,
      averageSalary: averageSalary ?? this.averageSalary,
      accreditation: accreditation ?? this.accreditation,
      workEnvironments: workEnvironments ?? this.workEnvironments,
      prerequisites: prerequisites ?? this.prerequisites,
    );
  }
}