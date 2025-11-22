import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aspire_edge/models/resource_model.dart';

class ResourceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  

  

  Future<List<ResourceModel>> getResourcesByCareerId(String careerId) async {
    try {
      final querySnapshot = await _firestore
          .collection('resources')
          .where('careerId', isEqualTo: careerId)
          // .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map(
              (doc) => ResourceModel.fromMap(doc.data(), doc.id)) // Pass doc.id
          .toList();
    } catch (e) {
      print("Error fetching resources: $e");
      return [];
    }
  }

  Future<void> addResource(ResourceModel resource) async {
    try {
      await _firestore
          .collection('resources')
          .doc(resource.resourceId)
          .set(resource.toMap());
    } catch (e) {
      print("Error adding resource: $e");
      rethrow;
    }
  }

  Future<void> updateResource(ResourceModel resource) async {
    try {
      await _firestore
          .collection('resources')
          .doc(resource.resourceId)
          .update(resource.toMap());
    } catch (e) {
      print("Error updating resource: $e");
      rethrow;
    }
  }

  Future<void> deleteResource(String resourceId) async {
    try {
      await _firestore.collection('resources').doc(resourceId).delete();
    } catch (e) {
      print("Error deleting resource: $e");
      rethrow;
    }
  }

  Stream<List<ResourceModel>> getResourcesStream() {
    return _firestore
        .collection('resources')
        .orderBy('createdAt',
            descending: true) // Optional: order by creation date
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ResourceModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}

// In your ResourceService or DebugService, add null checks
void logDebug(String message) {
  if (message != null && message.isNotEmpty) {
    print("Debug: $message");
  }
}



Stream<List<ResourceModel>> getPopularResourcesStream({int limit = 3}) {
  return FirebaseFirestore.instance
      .collection('resources')
      .orderBy('viewCount', descending: true)
      .limit(limit)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ResourceModel.fromFirestore(doc))
          .toList());
}


