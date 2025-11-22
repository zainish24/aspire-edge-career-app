// career_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aspire_edge/models/career_model.dart';
import 'package:aspire_edge/models/education_model.dart';
import 'package:aspire_edge/models/skill_model.dart';
import 'package:aspire_edge/models/feedback_model.dart';
import 'package:aspire_edge/models/industry_model.dart';

class CareerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference<Map<String, dynamic>> get _careersRef =>
      _firestore.collection('careers');
  CollectionReference<Map<String, dynamic>> get _educationsRef =>
      _firestore.collection('educations');
  CollectionReference<Map<String, dynamic>> get _skillsRef =>
      _firestore.collection('skills');
  CollectionReference<Map<String, dynamic>> get _industriesRef =>
      _firestore.collection('industries');
  CollectionReference<Map<String, dynamic>> get _feedbackRef =>
      _firestore.collection('feedback');

  // Converters for type-safe operations
  CollectionReference<CareerModel> get careersRef =>
      _careersRef.withConverter<CareerModel>(
        fromFirestore: (snap, _) => CareerModel.fromFirestore(snap),
        toFirestore: (career, _) => career.toMap(),
      );

  CollectionReference<EducationModel> get educationsRef =>
      _educationsRef.withConverter<EducationModel>(
        fromFirestore: (snap, _) => EducationModel.fromFirestore(snap),
        toFirestore: (education, _) => education.toMap(),
      );

  CollectionReference<SkillModel> get skillsRef =>
      _skillsRef.withConverter<SkillModel>(
        fromFirestore: (snap, _) => SkillModel.fromFirestore(snap),
        toFirestore: (skill, _) => skill.toMap(),
      );

  CollectionReference<FeedbackModel> get feedbackRef =>
      _feedbackRef.withConverter<FeedbackModel>(
        fromFirestore: (snap, _) => FeedbackModel.fromFirestore(snap),
        toFirestore: (feedback, _) => feedback.toMap(),
      );

  CollectionReference<IndustryModel> get industriesRef =>
      _industriesRef.withConverter<IndustryModel>(
        fromFirestore: (snap, _) => IndustryModel.fromFirestore(snap),
        toFirestore: (industry, _) => industry.toMap(),
      );

  // ================== CAREER OPERATIONS ==================

  // ✅ GET ALL CAREERS
  Future<List<CareerModel>> getAllCareers() async {
    try {
      final snap = await careersRef.get();
      return snap.docs.map((d) => d.data()).toList();
    } catch (e) {
      print('Error getting all careers: $e');
      return [];
    }
  }

  // ✅ GET CAREERS BY INDUSTRY
  Stream<List<CareerModel>> getCareersByIndustry(String industryId,
      {int limit = 20}) {
    return careersRef
        .where('industryId', isEqualTo: industryId)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  // ✅ GET CAREER BY ID
  Stream<CareerModel?> getCareerById(String id) {
    return careersRef.doc(id).snapshots().map((snap) => snap.data());
  }

  Future<CareerModel?> fetchCareerOnce(String id) async {
    final snap = await careersRef.doc(id).get();
    return snap.data();
  }

  // ✅ SEARCH CAREERS
  Future<List<CareerModel>> searchCareers(String query,
      {int limit = 30}) async {
    final q = query.trim().toLowerCase();
    if (q.length < 2) return [];

    try {
      QuerySnapshot<CareerModel> snap = await careersRef
          .where('title_lower', isGreaterThanOrEqualTo: q)
          .where('title_lower', isLessThanOrEqualTo: '$q\uf8ff')
          .limit(limit)
          .get();

      if (snap.docs.isEmpty) {
        final snap2 = await careersRef
            .where('skillNames', arrayContains: q)
            .limit(limit)
            .get();
        return snap2.docs.map((d) => d.data()).toList();
      }

      return snap.docs.map((d) => d.data()).toList();
    } catch (e) {
      print('Error searching careers: $e');
      return [];
    }
  }

  // ✅ CRUD OPERATIONS FOR CAREERS
  Future<void> addCareer(CareerModel career) async {
    try {
      await careersRef.doc(career.careerId).set(career);
    } catch (e) {
      print('Error adding career: $e');
      rethrow;
    }
  }

  Future<void> updateCareer(CareerModel career) async {
    try {
      await careersRef.doc(career.careerId).update(career.toMap());
    } catch (e) {
      print('Error updating career: $e');
      rethrow;
    }
  }

  Future<void> deleteCareer(String id) async {
    try {
      await careersRef.doc(id).delete();
    } catch (e) {
      print('Error deleting career: $e');
      rethrow;
    }
  }

  Stream<List<CareerModel>> getAllCareersStream() {
    return careersRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // ================== EDUCATION OPERATIONS ==================

  // ✅ GET ALL EDUCATION PATHS
  Future<List<EducationModel>> getAllEducations() async {
    try {
      final snap = await educationsRef.orderBy('title').get();
      return snap.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting all educations: $e');
      return [];
    }
  }

  // ✅ GET EDUCATION PATHS BY INDUSTRY
  Future<List<EducationModel>> getEducationsByIndustry(
      String industryId) async {
    try {
      final snap =
          await educationsRef.where('industryId', isEqualTo: industryId).get();
      return snap.docs.map((d) => d.data()).toList();
    } catch (e) {
      print('Error getting educations by industry: $e');
      return [];
    }
  }

  // ✅ GET EDUCATIONS BY IDS
  Future<List<EducationModel>> getEducationsByIds(
      List<String> educationIds) async {
    try {
      if (educationIds.isEmpty) return [];

      // Get all educations and filter locally
      final allEducations = await getAllEducations();
      return allEducations
          .where((edu) => educationIds.contains(edu.id))
          .toList();
    } catch (e) {
      print('Error getting educations by IDs: $e');
      return [];
    }
  }

  // ✅ CRUD OPERATIONS FOR EDUCATION
  Future<void> addEducation(EducationModel education) async {
    try {
      await educationsRef.add(education);
    } catch (e) {
      print('Error adding education: $e');
      rethrow;
    }
  }

  Future<void> updateEducation(EducationModel education) async {
    try {
      await educationsRef.doc(education.id).update(education.toMap());
    } catch (e) {
      print('Error updating education: $e');
      rethrow;
    }
  }

  Future<void> deleteEducation(String id) async {
    try {
      await educationsRef.doc(id).delete();
    } catch (e) {
      print('Error deleting education: $e');
      rethrow;
    }
  }

  // ================== SKILL OPERATIONS ==================

  // ✅ GET ALL SKILLS
  Future<List<SkillModel>> getAllSkills({int limit = 100}) async {
    try {
      final snap = await skillsRef.orderBy('name').limit(limit).get();
      return snap.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting all skills: $e');
      return [];
    }
  }

  // ✅ GET SKILLS BY INDUSTRY AND EDUCATION
  Future<List<SkillModel>> getSkillsByIndustryAndEducation({
    required String industryId,
    List<String> educationIds = const [],
  }) async {
    try {
      Query<SkillModel> query = skillsRef.where('industryId', isEqualTo: industryId);

      // If specific educations are selected, filter by them
      if (educationIds.isNotEmpty) {
        query = query.where('educationIds', arrayContainsAny: educationIds);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting skills by industry and education: $e');
      return [];
    }
  }

 



  // ✅ GET SKILLS BY IDS
  Future<List<SkillModel>> getSkillsByIds(List<String> skillIds) async {
    try {
      if (skillIds.isEmpty) return [];

      // Since Firestore doesn't support IN queries with large lists,
      // we'll get all skills and filter locally for now
      final allSkills = await getAllSkills();
      return allSkills.where((skill) => skillIds.contains(skill.id)).toList();
    } catch (e) {
      print('Error getting skills by IDs: $e');
      return [];
    }
  }

  // ✅ CREATE SKILL WITH CATEGORY
  Future<void> createSkillWithCategory({
    required String name,
    required String description,
    required String industryId,
    required String industryName,
    List<String> educationIds = const [],
  }) async {
    try {
      final skill = SkillModel(
        id: 'skill_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        description: description,
        industryId: industryId,
        industryName: industryName,
        educationIds: educationIds,
      );

      await skillsRef.doc(skill.id).set(skill);
    } catch (e) {
      print('Error creating skill: $e');
      rethrow;
    }
  }

  // ✅ UPDATE SKILL
  Future<void> updateSkill(SkillModel skill) async {
    try {
      await skillsRef.doc(skill.id).update(skill.toMap());
    } catch (e) {
      print('Error updating skill: $e');
      rethrow;
    }
  }

  // ✅ DELETE SKILL
  Future<void> deleteSkill(String skillId) async {
    try {
      await skillsRef.doc(skillId).delete();
    } catch (e) {
      print('Error deleting skill: $e');
      rethrow;
    }
  }

  // ✅ GET SKILLS FOR MANAGEMENT (All skills without filters)
  Future<List<SkillModel>> getAllSkillsForManagement() async {
    try {
      final snap = await skillsRef.orderBy('name').get();
      return snap.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting all skills for management: $e');
      return [];
    }
  }

  // ================== INDUSTRY OPERATIONS ==================

  // ✅ GET ALL INDUSTRIES
  Future<List<Map<String, dynamic>>> getAllIndustries() async {
    try {
      final snap = await _industriesRef.orderBy('name').get();
      return snap.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc.data()['name'] ?? '',
                'description': doc.data()['description'] ?? '',
                'imageUrl': doc.data()['imageUrl'],
                'careerCount': (doc.data()['careerCount'] as num?)?.toInt() ?? 0,
                'educationCount': (doc.data()['educationCount'] as num?)?.toInt() ?? 0,
              })
          .toList();
    } catch (e) {
      print('Error getting industries: $e');
      return [];
    }
  }

  // ✅ GET INDUSTRY BY ID
  Future<IndustryModel?> getIndustryById(String id) async {
    try {
      final snap = await industriesRef.doc(id).get();
      return snap.data();
    } catch (e) {
      print('Error getting industry by ID: $e');
      return null;
    }
  }

  // ================== FEEDBACK OPERATIONS ==================

  Future<void> addFeedback(FeedbackModel feedback) async {
    try {
      await feedbackRef.add(feedback);
    } catch (e) {
      print('Error adding feedback: $e');
      rethrow;
    }
  }

  Stream<List<FeedbackModel>> getAllFeedback() {
    return feedbackRef
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  Stream<List<FeedbackModel>> getFeedbackByUser(String userId) {
    return feedbackRef
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  // ================== RELATED CAREERS ==================

  Stream<List<CareerModel>> getRelatedCareers({
    required String careerId,
    required List<String> categories,
    String? industryId,
    int limit = 5,
  }) {
    Query<CareerModel> query =
        careersRef.where('careerId', isNotEqualTo: careerId).limit(limit);



    // Add industry filter if industryId is provided
    if (industryId != null && industryId.isNotEmpty) {
      query = query.where('industryId', isEqualTo: industryId);
    }

    return query
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }
}


Stream<List<CareerModel>> getFeaturedCareersStream({int limit = 3}) {
  return FirebaseFirestore.instance
      .collection('careers')
      .where('isFeatured', isEqualTo: true)
      .limit(limit)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => CareerModel.fromFirestore(doc))
          .toList());
}


