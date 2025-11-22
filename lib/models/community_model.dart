// models/community_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommunityUser {
  final String userId;
  final String name;
  final String? profilePic;
  final String? bio;
  final List<String> followers;
  final List<String> following;
  final DateTime createdAt;
  final bool isActive;

  // Career-specific fields
  final List<String>? careerInterests;
  final List<String>? skills;
  final String? careerLevel;
  final bool? isCareerExpert;
  final bool? mentorshipAvailability;

  CommunityUser({
    required this.userId,
    required this.name,
    this.profilePic,
    this.bio,
    this.followers = const [],
    this.following = const [],
    required this.createdAt,
    this.isActive = true,
    this.careerInterests,
    this.skills,
    this.careerLevel,
    this.isCareerExpert = false,
    this.mentorshipAvailability = false,
  });

  factory CommunityUser.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Safe profile picture extraction
    String? profilePic;
    final possibleFields = ['profilePic', 'photoUrl', 'avatar', 'image', 'profileImage'];
    
    for (final field in possibleFields) {
      if (data[field] != null && 
          data[field].toString().isNotEmpty && 
          data[field] != 'null') {
        profilePic = data[field].toString();
        break;
      }
    }

    // Safe list extraction
    List<String> safeList(List<dynamic>? list) {
      if (list == null) return [];
      try {
        return list.whereType<String>().where((item) => item.isNotEmpty).toList();
      } catch (e) {
        debugPrint('Error parsing list: $e');
        return [];
      }
    }

    return CommunityUser(
      userId: doc.id,
      name: data['name']?.toString() ?? 'Anonymous User',
      profilePic: profilePic,
      bio: data['bio']?.toString(),
      followers: safeList(data['followers']),
      following: safeList(data['following']),
      createdAt: _safeParseTimestamp(data['createdAt']),
      isActive: data['isActive'] ?? true,
      careerInterests: safeList(data['careerInterests']),
      skills: safeList(data['skills']),
      careerLevel: data['careerLevel']?.toString(),
      isCareerExpert: data['isCareerExpert'] ?? false,
      mentorshipAvailability: data['mentorshipAvailability'] ?? false,
    );
  }

  static DateTime _safeParseTimestamp(dynamic timestamp) {
    try {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      } else if (timestamp is String) {
        return DateTime.parse(timestamp);
      } else {
        return DateTime.now();
      }
    } catch (e) {
      debugPrint('Error parsing timestamp: $e');
      return DateTime.now();
    }
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'name': name,
        'profilePic': profilePic,
        'bio': bio,
        'followers': followers,
        'following': following,
        'createdAt': Timestamp.fromDate(createdAt),
        'isActive': isActive,
        'careerInterests': careerInterests ?? [],
        'skills': skills ?? [],
        'careerLevel': careerLevel,
        'isCareerExpert': isCareerExpert,
        'mentorshipAvailability': mentorshipAvailability,
      };
}

class CommunityPost {
  final String postId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String postContent;
  final String? mediaUrl;
  final String? mediaType;
  final int likes;
  final int comments;
  final List<String> likedBy;
  final DateTime timestamp;
  
  // Career-specific fields
  final String? careerField;
  final String? postType;
  final List<String> relevantSkills;
  final bool isExpertPost;
  final List<String> careerTags;
  final String? postCategory;

  CommunityPost({
    required this.postId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.postContent,
    this.mediaUrl,
    this.mediaType,
    this.likes = 0,
    this.comments = 0,
    this.likedBy = const [],
    required this.timestamp,
    this.careerField,
    this.postType = 'question',
    this.relevantSkills = const [],
    this.isExpertPost = false,
    this.careerTags = const [],
    this.postCategory,
  });

  factory CommunityPost.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Safe user avatar extraction
    String? userAvatar;
    final possibleFields = ['userAvatar', 'profilePic', 'avatar', 'image'];
    
    for (final field in possibleFields) {
      if (data[field] != null && 
          data[field].toString().isNotEmpty && 
          data[field] != 'null') {
        userAvatar = data[field].toString();
        break;
      }
    }

    // Safe list extraction
    List<String> safeList(List<dynamic>? list) {
      if (list == null) return [];
      try {
        return list.whereType<String>().where((item) => item.isNotEmpty).toList();
      } catch (e) {
        debugPrint('Error parsing list: $e');
        return [];
      }
    }

    // Safe number parsing
    int safeInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return CommunityPost(
      postId: doc.id,
      userId: data['userId']?.toString() ?? 'unknown',
      userName: data['userName']?.toString() ?? 'Guest User',
      userAvatar: userAvatar,
      postContent: data['postContent']?.toString() ?? 'No content available',
      mediaUrl: data['mediaUrl']?.toString(),
      mediaType: data['mediaType']?.toString(),
      likes: safeInt(data['likes']),
      comments: safeInt(data['comments']),
      likedBy: safeList(data['likedBy']),
      timestamp: CommunityUser._safeParseTimestamp(data['timestamp']),
      careerField: data['careerField']?.toString(),
      postType: data['postType']?.toString() ?? 'question',
      relevantSkills: safeList(data['relevantSkills']),
      isExpertPost: data['isExpertPost'] ?? false,
      careerTags: safeList(data['careerTags']),
      postCategory: data['postCategory']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'postId': postId,
        'userId': userId,
        'userName': userName,
        'userAvatar': userAvatar,
        'postContent': postContent,
        'mediaUrl': mediaUrl,
        'mediaType': mediaType,
        'likes': likes,
        'comments': comments,
        'likedBy': likedBy,
        'timestamp': Timestamp.fromDate(timestamp),
        'careerField': careerField,
        'postType': postType,
        'relevantSkills': relevantSkills,
        'isExpertPost': isExpertPost,
        'careerTags': careerTags,
        'postCategory': postCategory,
      };

  // Helper methods
  bool get isCareerRelated => careerField != null && careerField!.isNotEmpty;
  bool get hasMedia => mediaUrl != null && mediaUrl!.isNotEmpty;
  bool get isImage => hasMedia && (mediaType == 'image' || mediaType == 'photo');
  bool get isVideo => hasMedia && mediaType == 'video';
  bool get isAudio => hasMedia && mediaType == 'audio';
}

class Comment {
  final String commentId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String commentContent;
  final DateTime timestamp;

  Comment({
    required this.commentId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.commentContent,
    required this.timestamp,
  });

  factory Comment.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    String? userAvatar;
    final possibleFields = ['userAvatar', 'profilePic', 'avatar'];
    
    for (final field in possibleFields) {
      if (data[field] != null && 
          data[field].toString().isNotEmpty && 
          data[field] != 'null') {
        userAvatar = data[field].toString();
        break;
      }
    }

    return Comment(
      commentId: doc.id,
      userId: data['userId']?.toString() ?? 'unknown',
      userName: data['userName']?.toString() ?? 'Guest User',
      userAvatar: userAvatar,
      commentContent: data['commentContent']?.toString() ?? 'No comment content',
      timestamp: CommunityUser._safeParseTimestamp(data['timestamp']),
    );
  }

  Map<String, dynamic> toMap() => {
        'commentId': commentId,
        'userId': userId,
        'userName': userName,
        'userAvatar': userAvatar,
        'commentContent': commentContent,
        'timestamp': Timestamp.fromDate(timestamp),
      };
}

class ChatMessage {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String message;
  final String? mediaUrl;
  final String? mediaType;
  final DateTime timestamp;
  final bool isRead;
  final bool delivered;

  ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.mediaUrl,
    this.mediaType,
    required this.timestamp,
    this.isRead = false,
    this.delivered = false,
  });

  factory ChatMessage.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ChatMessage(
      messageId: doc.id,
      senderId: data['senderId']?.toString() ?? 'unknown',
      receiverId: data['receiverId']?.toString() ?? 'unknown',
      message: data['message']?.toString() ?? '',
      mediaUrl: data['mediaUrl']?.toString(),
      mediaType: data['mediaType']?.toString(),
      timestamp: CommunityUser._safeParseTimestamp(data['timestamp']),
      isRead: data['isRead'] ?? false,
      delivered: data['delivered'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'messageId': messageId,
        'senderId': senderId,
        'receiverId': receiverId,
        'message': message,
        'mediaUrl': mediaUrl,
        'mediaType': mediaType,
        'timestamp': Timestamp.fromDate(timestamp),
        'isRead': isRead,
        'delivered': delivered,
      };
}