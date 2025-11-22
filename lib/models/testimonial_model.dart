// models/testimonial_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Testimonial {
  final String testimonialId;
  final String userId;
  final String name;
  final String imageUrl;
  final String tier;
  final String story;
  final DateTime createdAt;

  Testimonial({
    required this.testimonialId,
    required this.userId,
    required this.name,
    required this.imageUrl,
    required this.tier,
    required this.story,
    required this.createdAt, 
  });

  factory Testimonial.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data()!;
  return Testimonial(
    testimonialId: doc.id,
    userId: data['userId'] ?? '',
    name: data['name'] ?? 'Anonymous User',
    imageUrl: data['imageUrl'] ?? '',
    tier: data['tier'] ?? 'student',
    story: data['story'] ?? '',
    createdAt: (data['createdAt'] as Timestamp).toDate(),
  );
}

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'imageUrl': imageUrl,
      'tier': tier,
      'story': story,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Simple factory for basic data (if async is not possible)
  factory Testimonial.fromMap(Map<String, dynamic> map, String testimonialId) {
    return Testimonial(
      testimonialId: testimonialId,
      userId: map['userId'] ?? '',
      name: map['name'] ?? 'Anonymous User',
      imageUrl: map['imageUrl'] ?? '',
      tier: map['tier'] ?? 'student',
      story: map['story'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(), 
    );
  }
}