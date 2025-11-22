import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aspire_edge/models/feedback_model.dart';

class FeedbackService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==================== ADMIN METHODS ====================

  /// Get all feedback as a stream (Admin)
  Stream<List<FeedbackModel>> getAllFeedback() {
    return _db
        .collection('feedback')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedbackModel.fromFirestore(doc))
            .toList());
  }

  /// Get feedback by career with filters (Admin)
  Stream<List<FeedbackModel>> getCareerFeedbackWithFilters(
    String careerId, {
    String category = 'All',
  }) {
    Query query =
        _db.collection('feedback').where('careerId', isEqualTo: careerId);

    if (category != 'All') {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) {
      List<FeedbackModel> feedbacks = snapshot.docs
          .map((doc) => FeedbackModel.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
      // Sort manually on client side
      feedbacks.sort((a, b) => b.date.compareTo(a.date));
      return feedbacks;
    });
  }

  /// Get feedback statistics with rating information (Admin)
  Stream<Map<String, dynamic>> getFeedbackStats() {
    return getAllFeedback().map((feedbackList) {
      final totalCount = feedbackList.length;

      // Count by category
      final bugCount =
          feedbackList.where((f) => f.category == 'bug report').length;
      final suggestionCount =
          feedbackList.where((f) => f.category == 'suggestion').length;
      final positiveCount =
          feedbackList.where((f) => f.category == 'positive feedback').length;
      final negativeCount =
          feedbackList.where((f) => f.category == 'negative feedback').length;

      // Calculate average rating
      final ratedFeedback = feedbackList.where((f) => f.rating > 0).toList();
      final averageRating = ratedFeedback.isEmpty
          ? 0.0
          : ratedFeedback.map((f) => f.rating).reduce((a, b) => a + b) /
              ratedFeedback.length;

      // Count by rating
      final rating1Count = feedbackList.where((f) => f.rating == 1).length;
      final rating2Count = feedbackList.where((f) => f.rating == 2).length;
      final rating3Count = feedbackList.where((f) => f.rating == 3).length;
      final rating4Count = feedbackList.where((f) => f.rating == 4).length;
      final rating5Count = feedbackList.where((f) => f.rating == 5).length;

      return {
        'totalCount': totalCount,
        'averageRating': averageRating,
        'byCategory': {
          'bug report': bugCount,
          'suggestion': suggestionCount,
          'positive feedback': positiveCount,
          'negative feedback': negativeCount,
        },
        'byRating': {
          '1': rating1Count,
          '2': rating2Count,
          '3': rating3Count,
          '4': rating4Count,
          '5': rating5Count,
        }
      };
    });
  }

  // ==================== USER METHODS ====================

  /// Get feedback for a specific career (User)
  Stream<List<FeedbackModel>> getCareerFeedback(String careerId) {
    return _db
        .collection('feedback')
        .where('careerId', isEqualTo: careerId)
        .snapshots()
        .map((snapshot) {
      List<FeedbackModel> feedbacks =
          snapshot.docs.map((doc) => FeedbackModel.fromFirestore(doc)).toList();
      // Sort manually on client side
      feedbacks.sort((a, b) => b.date.compareTo(a.date));
      return feedbacks;
    });
  }

  /// Get feedback for a specific user (User)
  Stream<List<FeedbackModel>> getUserFeedback(String userId) {
    return _db
        .collection('feedback')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      List<FeedbackModel> feedbacks =
          snapshot.docs.map((doc) => FeedbackModel.fromFirestore(doc)).toList();
      // Sort manually on client side
      feedbacks.sort((a, b) => b.date.compareTo(a.date));
      return feedbacks;
    });
  }

  /// Get feedback for a specific user and career (User)
  Stream<List<FeedbackModel>> getUserCareerFeedback(
      String userId, String careerId) {
    return _db
        .collection('feedback')
        .where('userId', isEqualTo: userId)
        .where('careerId', isEqualTo: careerId)
        .snapshots()
        .map((snapshot) {
      List<FeedbackModel> feedbacks =
          snapshot.docs.map((doc) => FeedbackModel.fromFirestore(doc)).toList();
      // Sort manually on client side
      feedbacks.sort((a, b) => b.date.compareTo(a.date));
      return feedbacks;
    });
  }

  /// Get user's feedback statistics across all careers (User)
  Stream<Map<String, dynamic>> getUserFeedbackStats(String userId) {
    return getUserFeedback(userId).map((feedbackList) {
      final totalCount = feedbackList.length;
      final positiveCount =
          feedbackList.where((f) => f.category == 'positive feedback').length;
      final positiveRatio = totalCount == 0 ? 0.0 : positiveCount / totalCount;

      return {
        'totalCount': totalCount,
        'positiveCount': positiveCount,
        'positiveRatio': positiveRatio,
        'positivePercentage': (positiveRatio * 100).toStringAsFixed(1),
        'careersCount': feedbackList.map((f) => f.careerId).toSet().length,
      };
    });
  }

  // ==================== CRUD OPERATIONS ====================

  /// Add new feedback to Firestore
  Future<void> addFeedback(FeedbackModel feedback) async {
    try {
      final feedbackRef = _db.collection('feedback').doc();

      // Create a new feedback with the generated ID
      final feedbackWithId = feedback.copyWith(feedbackId: feedbackRef.id);

      await feedbackRef.set(feedbackWithId.toMap());
    } catch (e) {
      print('Error adding feedback: $e');
      throw Exception('Failed to add feedback');
    }
  }

  /// Update feedback
  Future<void> updateFeedback(FeedbackModel feedback) async {
    try {
      await _db.collection('feedback').doc(feedback.feedbackId).update({
        'name': feedback.name,
        'email': feedback.email,
        'phone': feedback.phone,
        'message': feedback.message,
        'category': feedback.category,
        'rating': feedback.rating,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating feedback: $e');
      throw Exception('Failed to update feedback');
    }
  }

  /// Delete feedback
  Future<void> deleteFeedback(String feedbackId) async {
    try {
      await _db.collection('feedback').doc(feedbackId).delete();
    } catch (e) {
      print('Error deleting feedback: $e');
      throw Exception('Failed to delete feedback');
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Get feedback by ID
  Future<FeedbackModel?> getFeedbackById(String feedbackId) async {
    try {
      final doc = await _db.collection('feedback').doc(feedbackId).get();
      if (doc.exists) {
        return FeedbackModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting feedback by ID: $e');
      throw Exception('Failed to get feedback by ID');
    }
  }

  /// Check if user has already submitted feedback for a career
  Future<bool> hasUserSubmittedFeedback(String userId, String careerId) async {
    try {
      final query = await _db
          .collection('feedback')
          .where('userId', isEqualTo: userId)
          .where('careerId', isEqualTo: careerId)
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      print('Error checking if user has submitted feedback: $e');
      return false;
    }
  }

  /// Get feedback count for a career
  Future<int?> getCareerFeedbackCount(String careerId) async {
    try {
      final query = await _db
          .collection('feedback')
          .where('careerId', isEqualTo: careerId)
          .count()
          .get();

      return query.count;
    } catch (e) {
      print('Error getting career feedback count: $e');
      return 0;
    }
  }

  /// Get average rating for a career
  Future<double> getCareerAverageRating(String careerId) async {
    try {
      final query = await _db
          .collection('feedback')
          .where('careerId', isEqualTo: careerId)
          .where('rating', isGreaterThan: 0)
          .get();

      if (query.docs.isEmpty) return 0.0;

      final totalRating = query.docs
          .map((doc) => doc.data()['rating'] as int? ?? 0)
          .reduce((a, b) => a + b);

      return totalRating / query.docs.length;
    } catch (e) {
      print('Error getting career average rating: $e');
      return 0.0;
    }
  }

  // ==================== STATUS & CATEGORY MANAGEMENT ====================

  /// Update feedback status
  Future<void> updateFeedbackStatus(String feedbackId, String newStatus) async {
    try {
      await _db.collection('feedback').doc(feedbackId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating feedback status: $e');
      throw Exception('Failed to update feedback status');
    }
  }

  /// Update feedback category
  Future<void> updateFeedbackCategory(
      String feedbackId, String newCategory) async {
    try {
      await _db.collection('feedback').doc(feedbackId).update({
        'category': newCategory,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating feedback category: $e');
      throw Exception('Failed to update feedback category');
    }
  }

  // ==================== ADMIN FEEDBACK METHODS ====================

  /// Get all feedback with status filtering
  Stream<List<FeedbackModel>> getAllFeedbackWithFilters({
    String status = 'All',
    String category = 'All',
  }) {
    Query query = _db.collection('feedback').orderBy('date', descending: true);

    if (status != 'All') {
      query = query.where('status', isEqualTo: status);
    }

    if (category != 'All') {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => FeedbackModel.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList());
  }
}
