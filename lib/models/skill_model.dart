// skill_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SkillModel {
  final String id;
  final String name;
  final String description;
  final String industryId; // Link to industry
  final String industryName;
  final List<String> educationIds; // Multiple educations can share skills
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  SkillModel({
    required this.id,
    required this.name,
    required this.description,
    required this.industryId,
    required this.industryName,
    this.educationIds = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory SkillModel.fromMap(Map<String, dynamic> data, {String? id}) {
    List<String> _parseEducationIds(dynamic value) {
      if (value == null) return [];
      if (value is List) return value.map((e) => e.toString()).toList();
      return [];
    }

    return SkillModel(
      id: id ?? data['id']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      industryId: data['industryId']?.toString() ?? '',
      industryName: data['industryName']?.toString() ?? '',
      educationIds: _parseEducationIds(data['educationIds']),
      createdAt: data['createdAt'] is Timestamp ? data['createdAt'] as Timestamp : null,
      updatedAt: data['updatedAt'] is Timestamp ? data['updatedAt'] as Timestamp : null,
    );
  }

  factory SkillModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return SkillModel.fromMap(data, id: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'industryId': industryId,
      'industryName': industryName,
      'educationIds': educationIds,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
  
  static SkillModel empty() {
    return SkillModel(
      id: '',
      name: '',
      description: '',
      industryId: '',
      industryName: '',
    );
  }
  
  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => !isEmpty;

  // Copy with method
  SkillModel copyWith({
    String? id,
    String? name,
    String? description,
    String? industryId,
    String? industryName,
    List<String>? educationIds,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return SkillModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      industryId: industryId ?? this.industryId,
      industryName: industryName ?? this.industryName,
      educationIds: educationIds ?? this.educationIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}