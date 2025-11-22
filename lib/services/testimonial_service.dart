// services/testimonial_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aspire_edge/models/testimonial_model.dart';

class TestimonialService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all testimonials with actual user names AND profile images
  Stream<List<Testimonial>> getTestimonials() {
    return _firestore
        .collection('testimonials')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Testimonial> testimonials = [];
      
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          String userName = data['name'] ?? 'Anonymous User';
          String userImageUrl = data['imageUrl'] ?? '';
          String userId = data['userId'] ?? '';
          
          print('Processing testimonial: $userName | UserID: $userId | Current Image: $userImageUrl');
          
          // Always try to fetch latest user data to get updated profile image
          if (userId.isNotEmpty) {
            final userData = await _fetchUserData(userId);
            userName = userData['name'] ?? userName;
            
            // IMPORTANT: Always use the user's profile image from users collection
            userImageUrl = userData['imageUrl'] ?? userImageUrl;
            
            print('Fetched user data - Name: $userName | Image: $userImageUrl');
          }
          
          final testimonial = Testimonial(
            testimonialId: doc.id,
            userId: userId,
            name: userName,
            imageUrl: userImageUrl, // This should now have the actual profile image
            tier: data['tier'] ?? 'student',
            story: data['story'] ?? '',
            createdAt: (data['createdAt'] as Timestamp).toDate(),
          );
          
          testimonials.add(testimonial);
        } catch (e) {
          print('Error processing testimonial ${doc.id}: $e');
          // Create testimonial with fallback data
          final data = doc.data();
          testimonials.add(Testimonial(
            testimonialId: doc.id,
            userId: data['userId'] ?? '',
            name: data['name'] ?? 'Anonymous User',
            imageUrl: data['imageUrl'] ?? '',
            tier: data['tier'] ?? 'student',
            story: data['story'] ?? '',
            createdAt: (data['createdAt'] as Timestamp).toDate(),
          ));
        }
      }
      
      return testimonials;
    });
  }

  // Enhanced user data fetching with multiple field name checks
  Future<Map<String, dynamic>> _fetchUserData(String userId) async {
    try {
      print('Fetching user data for: $userId');
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        print('Raw user data: $userData');
        
        // Try multiple possible field names for name
        String userName = userData['name'] ?? 
                         userData['displayName'] ?? 
                         userData['fullName'] ??
                         userData['username'] ??
                         'Anonymous User';
        
        // Try multiple possible field names for profile image
        String userImageUrl = userData['imageUrl'] ?? 
                            userData['profileImage'] ?? 
                            userData['photoURL'] ??
                            userData['avatar'] ??
                            userData['profilePicture'] ??
                            userData['image'] ??
                            '';
        
        print('Extracted - Name: $userName | Image: $userImageUrl');
        
        return {
          'name': userName,
          'imageUrl': userImageUrl,
        };
      } else {
        print('User document $userId does not exist');
      }
    } catch (e) {
      print('Error fetching user data for $userId: $e');
    }
    return {'name': 'Anonymous User', 'imageUrl': ''};
  }

  // Debug method to check specific user data
  Future<void> debugUserData(String userId) async {
    print('=== DEBUG USER DATA for $userId ===');
    final userData = await _fetchUserData(userId);
    print('Final user data: $userData');
  }

  // Get user's testimonials
  Stream<List<Testimonial>> getUserTestimonials(String userId) {
    return _firestore
        .collection('testimonials')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Testimonial> testimonials = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final userData = await _fetchUserData(userId);
        
        testimonials.add(Testimonial(
          testimonialId: doc.id,
          userId: userId,
          name: userData['name'],
          imageUrl: userData['imageUrl'],
          tier: data['tier'] ?? 'student',
          story: data['story'] ?? '',
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        ));
      }
      
      return testimonials;
    });
  }

  // Add a new testimonial
  Future<void> addTestimonial(Testimonial testimonial) async {
    await _firestore
        .collection('testimonials')
        .doc(testimonial.testimonialId)
        .set({
          'userId': testimonial.userId,
          'name': testimonial.name,
          'imageUrl': testimonial.imageUrl,
          'tier': testimonial.tier,
          'story': testimonial.story,
          'createdAt': Timestamp.fromDate(testimonial.createdAt),
        });
  }

  // Delete a testimonial
  Future<void> deleteTestimonial(String testimonialId) async {
    await _firestore
        .collection('testimonials')
        .doc(testimonialId)
        .delete();
  }

  // Debug method to check Firestore data structure
  Future<void> debugFirestoreData() async {
    final snapshot = await _firestore.collection('testimonials').get();
    print('=== FIRESTORE TESTIMONIALS DATA ===');
    for (var doc in snapshot.docs) {
      print('Document ID: ${doc.id}');
      print('Data: ${doc.data()}');
      print('---');
    }
    
    // Also check users collection structure
    final usersSnapshot = await _firestore.collection('users').limit(3).get();
    print('=== FIRESTORE USERS DATA (first 3) ===');
    for (var doc in usersSnapshot.docs) {
      print('User ID: ${doc.id}');
      print('User Data: ${doc.data()}');
      print('---');
    }
  }
}





Stream<List<Testimonial>> getFeaturedTestimonialsStream({int limit = 3}) {
  return FirebaseFirestore.instance
      .collection('testimonials')
      .where('isFeatured', isEqualTo: true)
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Testimonial.fromFirestore(doc))
          .toList());
}