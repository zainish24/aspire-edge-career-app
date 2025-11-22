import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aspire_edge/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user role
  Future<String> getCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return 'user';
    
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      return (doc.data()?['role'] ?? 'user').toString().toLowerCase();
    }
    return 'user';
  }

  // Update user
  Future<void> updateUser(UserModel user) async {
    await _firestore.collection('users').doc(user.userId).update(user.toMap());
  }

  // Logout user (sign out from Firebase Auth)
  Future<void> logoutUser(String userId) async {
    try {
      // If you want to force logout by revoking tokens, you might need to use Admin SDK
      // For now, we'll just sign out the current user if it matches
      final currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.uid == userId) {
        await _auth.signOut();
      }
    } catch (e) {
      throw Exception('Failed to logout user: $e');
    }
  }

  // Stream all admins
  Stream<List<UserModel>> streamAdmins() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromDoc(doc))
            .toList());
  }

  // Stream all students
  Stream<List<UserModel>> streamStudents() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromDoc(doc))
            .toList());
  }

  // Stream all graduates
  Stream<List<UserModel>> streamGraduates() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'graduate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromDoc(doc))
            .toList());
  }

  // Stream all professionals
  Stream<List<UserModel>> streamProfessionals() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'professional')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromDoc(doc))
            .toList());
  }

  // Stream all customers (non-admins)
  Stream<List<UserModel>> streamCustomers() {
    return _firestore
        .collection('users')
        .where('role', whereIn: ['student', 'graduate', 'professional'])
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromDoc(doc))
            .toList());
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromDoc(doc);
    }
    return null;
  }

  // Delete user (optional - if you need this functionality)
  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
    // Note: You might also want to delete the Firebase Auth user
    // This requires Admin SDK or Cloud Functions
  }

  // Update user status
  Future<void> updateUserStatus(String userId, bool isActive) async {
    await _firestore.collection('users').doc(userId).update({
      'isActive': isActive,
    });
  }

  // Update user tier
  Future<void> updateUserTier(String userId, String? tier) async {
    await _firestore.collection('users').doc(userId).update({
      'tier': tier,
    });
  }

  // Get all users (for admin purposes)
  Stream<List<UserModel>> streamAllUsers() {
    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromDoc(doc))
            .toList());
  }

  // Search users by name or email
  Stream<List<UserModel>> searchUsers(String query) {
    return _firestore
        .collection('users')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: query + 'z')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromDoc(doc))
            .toList());
  }
}