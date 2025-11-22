import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String feedbackId;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String message;
  final String category;
  final DateTime date;
  final DateTime? updatedAt;
  final String careerId;
  final String careerTitle;
  final int rating;

  var status;

  FeedbackModel({
    required this.feedbackId,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.message,
    required this.category,
    required this.date,
    this.updatedAt,
    required this.careerId,
    required this.careerTitle,
    this.rating = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      "feedbackId": feedbackId,
      "userId": userId,
      "name": name,
      "email": email,
      "phone": phone,
      "message": message,
      "category": category,
      "date": Timestamp.fromDate(date),
      "updatedAt": updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      "careerId": careerId,
      "careerTitle": careerTitle,
      "rating": rating,
    };
  }

  factory FeedbackModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return FeedbackModel(
      feedbackId: doc.id,
      userId: data["userId"]?.toString() ?? "",
      name: data["name"] ?? "Anonymous",
      email: data["email"] ?? "",
      phone: data["phone"] ?? "",
      message: data["message"] ?? "",
      category: data["category"] ?? "suggestion",
      date: (data["date"] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data["updatedAt"] as Timestamp?)?.toDate(),
      careerId: data["careerId"] ?? "",
      careerTitle: data["careerTitle"] ?? "Unknown Career",
      rating: data["rating"] ?? 0,
    );
  }

  FeedbackModel copyWith({
    String? feedbackId,
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? message,
    String? category,
    DateTime? date,
    DateTime? updatedAt,
    String? careerId,
    String? careerTitle,
    int? rating,
  }) {
    return FeedbackModel(
      feedbackId: feedbackId ?? this.feedbackId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      message: message ?? this.message,
      category: category ?? this.category,
      date: date ?? this.date,
      updatedAt: updatedAt ?? this.updatedAt,
      careerId: careerId ?? this.careerId,
      careerTitle: careerTitle ?? this.careerTitle,
      rating: rating ?? this.rating,
    );
  }
}