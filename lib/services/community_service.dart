// services/community_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:aspire_edge/models/community_model.dart';

class CommunityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User Operations
  Stream<CommunityUser> getUserStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) {
            return CommunityUser(
              userId: userId,
              name: 'Unknown User',
              createdAt: DateTime.now(),
            );
          }
          return CommunityUser.fromDoc(snapshot);
        })
        .handleError((error) {
          debugPrint('User stream error: $error');
          return CommunityUser(
            userId: userId,
            name: 'Error Loading User',
            createdAt: DateTime.now(),
          );
        });
  }

  Future<CommunityUser> getUser(String userId) async {
    try {
      final snapshot = await _firestore.collection('users').doc(userId).get();
      if (!snapshot.exists) {
        return CommunityUser(
          userId: userId,
          name: 'Unknown User',
          createdAt: DateTime.now(),
        );
      }
      return CommunityUser.fromDoc(snapshot);
    } catch (e) {
      debugPrint('Error getting user: $e');
      return CommunityUser(
        userId: userId,
        name: 'Error Loading User',
        createdAt: DateTime.now(),
      );
    }
  }

  // Post Operations - FIXED TYPE CASTING
  Stream<List<CommunityPost>> getCommunityPosts() {
    return _firestore
        .collection('community_posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          try {
            return snapshot.docs.map((doc) {
              try {
                return CommunityPost.fromDoc(doc);
              } catch (e) {
                debugPrint('Error parsing post ${doc.id}: $e');
                // Return a default post instead of crashing
                return CommunityPost(
                  postId: doc.id,
                  userId: 'unknown',
                  userName: 'Unknown User',
                  postContent: 'Error loading post content',
                  timestamp: DateTime.now(),
                );
              }
            }).toList();
          } catch (e) {
            debugPrint('Error processing posts: $e');
            return <CommunityPost>[];
          }
        })
        .handleError((error) {
          debugPrint('Posts stream error: $error');
          return <CommunityPost>[];
        });
  }

  // Get career-specific posts - FIXED TYPE CASTING
  Stream<List<CommunityPost>> getCareerPosts({String? careerField, String? postCategory}) {
    Query query = _firestore
        .collection('community_posts')
        .orderBy('timestamp', descending: true);

    if (careerField != null && careerField.isNotEmpty) {
      query = query.where('careerField', isEqualTo: careerField);
    }
    
    if (postCategory != null && postCategory.isNotEmpty) {
      query = query.where('postCategory', isEqualTo: postCategory);
    }

    return query.snapshots().map((snapshot) {
      try {
        return snapshot.docs.map((doc) => CommunityPost.fromDoc(doc)).toList();
      } catch (e) {
        debugPrint('Error processing career posts: $e');
        return <CommunityPost>[];
      }
    }).handleError((error) {
      debugPrint('Career posts stream error: $error');
      return <CommunityPost>[];
    });
  }

  // User Posts - FIXED TYPE CASTING
  Stream<List<CommunityPost>> getUserPosts(String userId) {
    return _firestore
        .collection('community_posts')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          try {
            return snapshot.docs.map((doc) => CommunityPost.fromDoc(doc)).toList();
          } catch (e) {
            debugPrint('Error processing user posts: $e');
            return <CommunityPost>[];
          }
        })
        .handleError((error) {
          debugPrint('User posts stream error: $error');
          return <CommunityPost>[];
        });
  }

  // Create Post - IMPROVED ERROR HANDLING
  Future<String> createPost(CommunityPost post) async {
    try {
      final docRef = await _firestore.collection('community_posts').add(post.toMap());
      
      // Update the post with its ID
      await docRef.update({'postId': docRef.id});
      
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating post: $e');
      rethrow;
    }
  }

  // Like Operations - FIXED
  Future<void> toggleLike(String postId, String userId) async {
    try {
      final postRef = _firestore.collection('community_posts').doc(postId);
      final postDoc = await postRef.get();

      if (postDoc.exists) {
        final data = postDoc.data() ?? {};
        final likedBy = List<String>.from(data['likedBy'] ?? []);

        if (likedBy.contains(userId)) {
          await postRef.update({
            'likes': FieldValue.increment(-1),
            'likedBy': FieldValue.arrayRemove([userId]),
          });
        } else {
          await postRef.update({
            'likes': FieldValue.increment(1),
            'likedBy': FieldValue.arrayUnion([userId]),
          });
        }
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
      rethrow;
    }
  }

  // Comment Operations - FIXED TYPE CASTING
  Stream<List<Comment>> getComments(String postId) {
    return _firestore
        .collection('community_posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          try {
            return snapshot.docs.map((doc) => Comment.fromDoc(doc)).toList();
          } catch (e) {
            debugPrint('Error processing comments: $e');
            return <Comment>[];
          }
        })
        .handleError((error) {
          debugPrint('Comments stream error: $error');
          return <Comment>[];
        });
  }

  Future<void> addComment(String postId, Comment comment) async {
    try {
      final batch = _firestore.batch();

      final commentRef = _firestore
          .collection('community_posts')
          .doc(postId)
          .collection('comments')
          .doc();
      batch.set(commentRef, comment.toMap());

      final postRef = _firestore.collection('community_posts').doc(postId);
      batch.update(postRef, {'comments': FieldValue.increment(1)});

      await batch.commit();
    } catch (e) {
      debugPrint('Error adding comment: $e');
      rethrow;
    }
  }

  Future<void> deleteComment(String postId, String commentId) async {
    try {
      final batch = _firestore.batch();

      final commentRef = _firestore
          .collection('community_posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId);
      batch.delete(commentRef);

      final postRef = _firestore.collection('community_posts').doc(postId);
      batch.update(postRef, {'comments': FieldValue.increment(-1)});

      await batch.commit();
    } catch (e) {
      debugPrint('Error deleting comment: $e');
      rethrow;
    }
  }

  // Follow Operations - FIXED
  Future<void> toggleFollow(String currentUserId, String targetUserId) async {
    try {
      final currentUserRef = _firestore.collection('users').doc(currentUserId);
      final targetUserRef = _firestore.collection('users').doc(targetUserId);

      final currentUserDoc = await currentUserRef.get();
      final following = List<String>.from(currentUserDoc.data()?['following'] ?? []);

      if (following.contains(targetUserId)) {
        await currentUserRef.update({
          'following': FieldValue.arrayRemove([targetUserId])
        });
        await targetUserRef.update({
          'followers': FieldValue.arrayRemove([currentUserId])
        });
      } else {
        await currentUserRef.update({
          'following': FieldValue.arrayUnion([targetUserId])
        });
        await targetUserRef.update({
          'followers': FieldValue.arrayUnion([currentUserId])
        });
      }
    } catch (e) {
      debugPrint('Error toggling follow: $e');
      rethrow;
    }
  }

  // Check if user is following another user - FIXED
  Future<bool> isFollowing(String currentUserId, String targetUserId) async {
    try {
      if (currentUserId.isEmpty) return false;
      final userDoc = await _firestore.collection('users').doc(currentUserId).get();
      if (userDoc.exists) {
        final followingList = List<String>.from(userDoc.data()?['following'] ?? []);
        return followingList.contains(targetUserId);
      }
      return false;
    } catch (e) {
      debugPrint('Error checking follow status: $e');
      return false;
    }
  }

  // Career Community Methods - FIXED
  Future<List<String>> getCareerFields() async {
    try {
      final snapshot = await _firestore
          .collection('careers')
          .orderBy('title')
          .get();
      
      final fields = snapshot.docs
          .map((doc) => doc['title'] as String? ?? '')
          .where((title) => title.isNotEmpty)
          .toList();

      // If no careers in database, return default list
      if (fields.isEmpty) {
        return [
          'IT & Software',
          'Healthcare',
          'Design & Creative',
          'Business & Management',
          'Engineering',
          'Education',
          'Marketing',
          'Finance'
        ];
      }

      return fields;
    } catch (e) {
      debugPrint('Error fetching career fields: $e');
      return [
        'IT & Software',
        'Healthcare',
        'Design & Creative',
        'Business & Management',
        'Engineering',
        'Education',
        'Marketing',
        'Finance'
      ];
    }
  }

  Future<List<String>> getCommonSkills() async {
    try {
      final snapshot = await _firestore
          .collection('skills')
          .orderBy('name')
          .get();
      
      final skills = snapshot.docs
          .map((doc) => doc['name'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .toList();

      if (skills.isEmpty) {
        return getCommonSkillsFromPosts();
      }

      return skills;
    } catch (e) {
      debugPrint('Error fetching common skills: $e');
      return getCommonSkillsFromPosts();
    }
  }

  Future<List<String>> getCommonSkillsFromPosts() async {
    try {
      final snapshot = await _firestore
          .collection('community_posts')
          .where('relevantSkills', isNotEqualTo: [])
          .limit(100)
          .get();
      
      final allSkills = <String>{};
      
      for (final doc in snapshot.docs) {
        final skills = List<String>.from(doc['relevantSkills'] ?? []);
        allSkills.addAll(skills);
      }
      
      return allSkills.toList()..sort();
    } catch (e) {
      debugPrint('Error fetching skills from posts: $e');
      return [
        'Programming',
        'UI/UX Design',
        'Data Analysis',
        'Project Management',
        'Digital Marketing',
        'Communication',
        'Leadership',
        'Problem Solving'
      ];
    
    
    }
  }

  // Chat Operations - FIXED TYPE CASTING
  String getChatId(String user1, String user2) {
    return user1.compareTo(user2) < 0 ? '${user1}_$user2' : '${user2}_$user1';
  }

  Stream<List<ChatMessage>> getChatMessages(String user1, String user2) {
    final chatId = getChatId(user1, user2);
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          try {
            return snapshot.docs.map((doc) => ChatMessage.fromDoc(doc)).toList();
          } catch (e) {
            debugPrint('Error processing chat messages: $e');
            return <ChatMessage>[];
          }
        })
        .handleError((error) {
          debugPrint('Chat messages stream error: $error');
          return <ChatMessage>[];
        });
  }

  Future<void> sendMessage(ChatMessage message, String receiverId) async {
    try {
      final chatId = getChatId(message.senderId, receiverId);
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message.toMap());
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      final unreadMessages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
      rethrow;
    }
  }

  // Get users by IDs - FIXED
  Future<List<CommunityUser>> getUsersByIds(List<String> userIds) async {
    if (userIds.isEmpty) return [];

    final users = <CommunityUser>[];
    for (final userId in userIds) {
      try {
        final user = await getUser(userId);
        users.add(user);
      } catch (e) {
        debugPrint('Error fetching user $userId: $e');
        users.add(CommunityUser(
          userId: userId,
          name: 'Unknown User',
          createdAt: DateTime.now(),
        ));
      }
    }
    return users;
  }

  // Get career experts
  Future<List<CommunityUser>> getCareerExperts() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('isCareerExpert', isEqualTo: true)
          .get();
      
      return snapshot.docs.map((doc) => CommunityUser.fromDoc(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching career experts: $e');
      return [];
    }
  }

  // Update user career interests
  Future<void> updateUserCareerInterests(String userId, List<String> interests) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'careerInterests': interests,
      });
    } catch (e) {
      debugPrint('Error updating career interests: $e');
      rethrow;
    }
  }

  // Update user skills
  Future<void> updateUserSkills(String userId, List<String> skills) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'skills': skills,
      });
    } catch (e) {
      debugPrint('Error updating skills: $e');
      rethrow;
    }
  }

  // Delete post
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('community_posts').doc(postId).delete();
    } catch (e) {
      debugPrint('Error deleting post: $e');
      rethrow;
    }
  }

  // Update post
  Future<void> updatePost(String postId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('community_posts').doc(postId).update(updates);
    } catch (e) {
      debugPrint('Error updating post: $e');
      rethrow;
    }
  }
}