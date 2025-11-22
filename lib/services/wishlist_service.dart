import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:aspire_edge/models/career_model.dart';
import 'dart:developer' as developer;

class WishlistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Add career to wishlist
  Future<void> addToWishlist(CareerModel career) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("wishlist")
          .doc(career.careerId)
          .set({
        ...career.toMap(),
        'addedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add to wishlist: $e');
    }
  }

  /// Remove career from wishlist
  Future<void> removeFromWishlist(String careerId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("wishlist")
          .doc(careerId)
          .delete();
    } catch (e) {
      throw Exception('Failed to remove from wishlist: $e');
    }
  }

  /// Get wishlist stream - FIXED with proper type handling
  Stream<List<CareerModel>> getWishlist() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection("users")
        .doc(user.uid)
        .collection("wishlist")
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>? ?? {};
            return _createCareerModelFromData(data, doc.id);
          })
          .toList();
    });
  }

  /// Check if career is in wishlist
  Stream<bool> isCareerInWishlist(String careerId) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(false);

    return _firestore
        .collection("users")
        .doc(user.uid)
        .collection("wishlist")
        .doc(careerId)
        .snapshots()
        .map((doc) => doc.exists)
        .handleError((error) {
      // Use debugPrint instead of print
      debugPrint('Error checking wishlist: $error');
      return false;
    });
  }

  /// Get wishlist count
  Stream<int> getWishlistCount() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(0);

    return _firestore
        .collection("users")
        .doc(user.uid)
        .collection("wishlist")
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Clear entire wishlist
  Future<void> clearWishlist() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final batch = _firestore.batch();
      final docs = await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("wishlist")
          .get();

      for (final doc in docs.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear wishlist: $e');
    }
  }

  /// Get single wishlist item
  Future<CareerModel?> getWishlistItem(String careerId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final doc = await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("wishlist")
          .doc(careerId)
          .get();

      if (doc.exists) {
        final data = doc.data() ?? {};
        return _createCareerModelFromData(data, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get wishlist item: $e');
    }
  }

  /// Move item to different position in wishlist
  Future<void> updateWishlistItemPosition(String careerId, int newPosition) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("wishlist")
          .doc(careerId)
          .update({
        'position': newPosition,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update wishlist position: $e');
    }
  }

  /// Get wishlist with pagination
  Stream<List<CareerModel>> getWishlistPaginated({int limit = 20, DocumentSnapshot? startAfter}) {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    Query query = _firestore
        .collection("users")
        .doc(user.uid)
        .collection("wishlist")
        .orderBy('addedAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>? ?? {};
            return _createCareerModelFromData(data, doc.id);
          })
          .toList();
    });
  }

  /// Check if wishlist contains any items
  Future<bool> hasWishlistItems() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final snapshot = await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("wishlist")
          .limit(1)
          .get();
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking wishlist items: $e');
      return false;
    }
  }

  /// Get wishlist items by industry
  Stream<List<CareerModel>> getWishlistByIndustry(String industryId) {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection("users")
        .doc(user.uid)
        .collection("wishlist")
        .where('industryId', isEqualTo: industryId)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>? ?? {};
            return _createCareerModelFromData(data, doc.id);
          })
          .toList();
    });
  }

  /// Bulk add careers to wishlist
  Future<void> bulkAddToWishlist(List<CareerModel> careers) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final batch = _firestore.batch();
      final timestamp = FieldValue.serverTimestamp();

      for (final career in careers) {
        final docRef = _firestore
            .collection("users")
            .doc(user.uid)
            .collection("wishlist")
            .doc(career.careerId);

        batch.set(docRef, {
          ...career.toMap(),
          'addedAt': timestamp,
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to bulk add to wishlist: $e');
    }
  }

  /// Bulk remove careers from wishlist
  Future<void> bulkRemoveFromWishlist(List<String> careerIds) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final batch = _firestore.batch();

      for (final careerId in careerIds) {
        final docRef = _firestore
            .collection("users")
            .doc(user.uid)
            .collection("wishlist")
            .doc(careerId);

        batch.delete(docRef);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to bulk remove from wishlist: $e');
    }
  }

  /// Export wishlist as list of career IDs
  Future<List<String>> exportWishlistIds() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final snapshot = await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("wishlist")
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      throw Exception('Failed to export wishlist: $e');
    }
  }

  /// Import wishlist from list of career models
  Future<void> importWishlist(List<CareerModel> careers) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Clear existing wishlist first
      await clearWishlist();
      
      // Add new careers
      await bulkAddToWishlist(careers);
    } catch (e) {
      throw Exception('Failed to import wishlist: $e');
    }
  }

  // Helper method to create CareerModel from Firestore data - FIXED with proper null safety
  CareerModel _createCareerModelFromData(Map<String, dynamic> data, String docId) {
    return CareerModel(
      careerId: docId,
      title: data['title']?.toString() ?? 'Untitled Career',
      industryId: data['industryId']?.toString() ?? '',
      industryName: data['industryName']?.toString() ?? '',
      description: data['description']?.toString(),
      skillIds: _parseStringList(data['skillIds']),
      skillNames: _parseStringList(data['skillNames']),
      salaryRange: data['salaryRange']?.toString(),
      educationPathIds: _parseStringList(data['educationPathIds']),
      educationPathNames: _parseStringList(data['educationPathNames']),
      images: _parseStringList(data['images']),
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
      updatedAt: data['updatedAt'] as Timestamp? ?? Timestamp.now(),
      jobOutlook: data['jobOutlook']?.toString() ?? 'Medium',
      workEnvironment: _parseStringList(data['workEnvironment']),
      experienceLevel: data['experienceLevel']?.toString() ?? 'Entry-level',
      responsibilities: _parseStringList(data['responsibilities']),
      workLifeBalance: data['workLifeBalance']?.toString() ?? 'Good',
      stressLevel: data['stressLevel']?.toString() ?? 'Medium',
      entryLevelPositions: _parseStringList(data['entryLevelPositions']),
      seniorPositions: _parseStringList(data['seniorPositions']),
      skillLevels: _parseStringMap(data['skillLevels']),
      streamSelector: _parseMap(data['streamSelector']),
      cvTips: _parseMap(data['cvTips']),
      interviewPrep: _parseMap(data['interviewPrep']),
    );
  }

  // Helper methods for data parsing with proper type safety
  List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.whereType<String>().where((e) => e.isNotEmpty).toList();
    }
    return [];
  }

  Map<String, String> _parseStringMap(dynamic value) {
    if (value == null) return {};
    if (value is Map<String, dynamic>) {
      return value.map((key, value) => MapEntry(key, value?.toString() ?? ''));
    }
    if (value is Map<dynamic, dynamic>) {
      return value.map((key, value) => MapEntry(key.toString(), value?.toString() ?? ''));
    }
    return {};
  }

  Map<String, dynamic>? _parseMap(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map<dynamic, dynamic>) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  // Safe data access helper methods

}

// Add this import at the top of your file if not already present


// Extension for safe logging
extension SafeLog on Object {
  void debugLog(String message) {
    developer.log(message, name: 'WishlistService');
  }
}