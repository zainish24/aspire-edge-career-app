import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aspire_edge/models/quiz_model.dart';

class QuizService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create or update a quiz
  Future<void> saveQuiz(QuizModel quiz) async {
    try {
      await _db.collection('quizzes').doc(quiz.quizId).set(quiz.toMap());
    } catch (e) {
      print('Error saving quiz: $e');
      throw Exception('Failed to save quiz');
    }
  }

  // Delete a quiz
  Future<void> deleteQuiz(String quizId) async {
    try {
      await _db.collection('quizzes').doc(quizId).delete();
    } catch (e) {
      print('Error deleting quiz: $e');
      throw Exception('Failed to delete quiz');
    }
  }

  // Get a single quiz (Future-based)
  Future<QuizModel?> getQuiz(String quizId) async {
    try {
      final doc = await _db.collection('quizzes').doc(quizId).get();
      if (doc.exists) {
        return QuizModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting quiz: $e');
      return null;
    }
  }

  // Get a single quiz (Stream-based)
  Stream<QuizModel?> getQuizById(String quizId) {
    return _db.collection('quizzes').doc(quizId).snapshots().map((doc) {
      if (doc.exists) {
        return QuizModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  // Get all quizzes
  Stream<List<QuizModel>> getAllQuizzes() {
    return _db.collection('quizzes').orderBy('title').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => QuizModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get quizzes by career ID
  Stream<List<QuizModel>> getQuizzesByCareerId(String careerId) {
    return _db
        .collection('quizzes')
        .where('careerId', isEqualTo: careerId)
        .orderBy('title')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => QuizModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Submit quiz results
  Future<void> submitQuizResults(
      String quizId, String userId, Map<String, String> answers) async {
    try {
      // Calculate score
      final quiz = await getQuiz(quizId);
      int totalScore = 0;

      if (quiz != null) {
        answers.forEach((questionId, answer) {
          final question = quiz.questions.firstWhere(
            (q) => q.questionId == questionId,
            orElse: () => QuizQuestion(
              questionId: '',
              questionText: '',
              options: [],
              scoreMap: {},
            ),
          );

          if (question.questionId.isNotEmpty) {
            totalScore += question.scoreMap[answer] ?? 0;
          }
        });
      }

      await _db.collection('quiz_results').add({
        'quizId': quizId,
        'userId': userId,
        'answers': answers,
        'totalScore': totalScore,
        'submittedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error submitting quiz results: $e');
      throw Exception('Failed to submit quiz results');
    }
  }

  // Get user quiz history
  Stream<List<Map<String, dynamic>>> getUserQuizHistory(String userId) {
    return _db
        .collection('quiz_results')
        .where('userId', isEqualTo: userId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                'quizId': data['quizId'],
                'totalScore': data['totalScore'],
                'submittedAt': (data['submittedAt'] as Timestamp).toDate(),
              };
            }).toList());
  }

  // Add to QuizService class
  Future<QuizModel?> getQuizByCareerId(String careerId) async {
    try {
      final query = await _db
          .collection('quizzes')
          .where('careerId', isEqualTo: careerId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return QuizModel.fromMap(query.docs.first.data(), query.docs.first.id);
      }
      return null;
    } catch (e) {
      print('Error getting quiz by career ID: $e');
      return null;
    }
  }

  Stream<QuizModel?> getQuizByCareerIdStream(String careerId) {
  return _db
      .collection('quizzes')
      .where('careerId', isEqualTo: careerId)
      .limit(1)
      .snapshots()
      .map((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          return QuizModel.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
        }
        return null;
      });
}
}
