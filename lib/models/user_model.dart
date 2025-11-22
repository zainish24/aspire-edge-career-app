import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String name;
  final String email;
  final String? passwordHash;
  final String role;
  final String? tier;
  final String? phone;
  final String? profilePic;
  final List<String> bookmarks;
  final DateTime createdAt;
  final bool isActive;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    this.passwordHash,
    required this.role,
    this.tier,
    this.phone,
    this.profilePic,
    this.bookmarks = const [],
    required this.createdAt,
    this.isActive = true,
  });

  factory UserModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      userId: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      passwordHash: data['passwordHash'],
      role: data['role'] ?? 'student',
      tier: data['tier'],
      phone: data['phone'],
      profilePic: data['profilePic'],
      bookmarks: List<String>.from(data['bookmarks'] ?? []),
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(data['createdAt']?.toString() ?? '') ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'name': name,
        'email': email,
        'passwordHash': passwordHash,
        'role': role,
        'tier': tier,
        'phone': phone,
        'profilePic': profilePic,
        'bookmarks': bookmarks,
        'createdAt': createdAt,
        'isActive': isActive,
      };
}