import 'package:cloud_firestore/cloud_firestore.dart';

class ResourceModel {
  final String resourceId;
  final String careerId;
  final String type;
  final String title;
  final String author;
  final List<String> tags;
  final String url;
  final String mediaType;
  final String? displayImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  ResourceModel({
    required this.resourceId,
    required this.careerId,
    required this.type,
    required this.title,
    required this.author,
    required this.tags,
    required this.url,
    required this.mediaType,
    this.displayImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ResourceModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ResourceModel.fromMap(data, doc.id);
  }

  factory ResourceModel.fromMap(Map<String, dynamic> map,
      [String? resourceId]) {
    return ResourceModel(
      resourceId: resourceId ?? map['resourceId'] ?? '',
      careerId: map['careerId'] ?? '',
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      type: map['type'] ?? '',
      url: map['url'] ?? '',
      mediaType: map['mediaType'] ?? 'image',
      displayImageUrl: map['displayImageUrl'], // ADD THIS
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'resourceId': resourceId,
      'careerId': careerId,
      'type': type,
      'title': title,
      'author': author,
      'tags': tags,
      'url': url,
      'mediaType': mediaType,
      'displayImageUrl': displayImageUrl, // ADD THIS
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
