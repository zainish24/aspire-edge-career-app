import 'package:cloud_firestore/cloud_firestore.dart';

class QuizModel {
  final String quizId;
  final String careerId; // Made required
  final String title;
  final String description;
  final List<QuizQuestion> questions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  QuizModel({
    required this.quizId,
    required this.careerId,
    required this.title,
    required this.description,
    required this.questions,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'quizId': quizId,
      'careerId': careerId, // Ensure this is included
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toMap()).toList(),
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : Timestamp.now(),
      'updatedAt': Timestamp.now(),
    };
  }

  static QuizModel fromMap(Map<String, dynamic> data, String id) {
    final questionsData = data['questions'] as List<dynamic>? ?? [];
    final questions = questionsData.map((qData) {
      return QuizQuestion.fromMap(Map<String, dynamic>.from(qData));
    }).toList();

    Timestamp? createdAt = data['createdAt'] as Timestamp?;
    Timestamp? updatedAt = data['updatedAt'] as Timestamp?;

    return QuizModel(
      quizId: id,
      careerId: data['careerId']?.toString() ?? '', // Ensure careerId is parsed
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      questions: questions,
      createdAt: createdAt?.toDate(),
      updatedAt: updatedAt?.toDate(),
    );
  }
}

class QuizQuestion {
  final String questionId;
  final String questionText;
  final List<String> options;
  final Map<String, int> scoreMap;

  QuizQuestion({
    required this.questionId,
    required this.questionText,
    required this.options,
    required this.scoreMap,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'questionText': questionText,
      'options': options,
      'scoreMap': scoreMap,
    };
  }

  static QuizQuestion fromMap(Map<String, dynamic> data) {
    return QuizQuestion(
      questionId: data['questionId']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      questionText: data['questionText']?.toString() ?? '',
      options: List<String>.from(data['options'] ?? []),
      scoreMap: Map<String, int>.from(data['scoreMap'] ?? {}),
    );
  }
}