// industry_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class IndustryModel {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final int careerCount;
  final int educationCount;
  final List<String> popularSkills;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  IndustryModel({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    this.careerCount = 0,
    this.educationCount = 0,
    this.popularSkills = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory IndustryModel.fromMap(Map<String, dynamic> data, {String? id}) {
    List<String> _parsePopularSkills(dynamic value) {
      if (value == null) return [];
      if (value is List) return value.map((e) => e.toString()).toList();
      return [];
    }

    return IndustryModel(
      id: id ?? data['id']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      imageUrl: data['imageUrl']?.toString(),
      careerCount: (data['careerCount'] as num?)?.toInt() ?? 0,
      educationCount: (data['educationCount'] as num?)?.toInt() ?? 0,
      popularSkills: _parsePopularSkills(data['popularSkills']),
      createdAt: data['createdAt'] is Timestamp ? data['createdAt'] as Timestamp : Timestamp.now(),
      updatedAt: data['updatedAt'] is Timestamp ? data['updatedAt'] as Timestamp : Timestamp.now(),
    );
  }

  factory IndustryModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return IndustryModel.fromMap(data, id: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'careerCount': careerCount,
      'educationCount': educationCount,
      'popularSkills': popularSkills,
      'createdAt': createdAt,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}