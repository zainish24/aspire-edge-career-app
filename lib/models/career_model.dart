// career_model.dart
// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:cloud_firestore/cloud_firestore.dart';

class CareerModel {
  final String careerId;
  final String title;
  final String industryId;
  final String industryName;
  final String? description;
  final List<String> skillIds;
  final List<String> skillNames;
  final String? salaryRange;
  final List<String> educationPathIds;
  final List<String> educationPathNames;
  final List<String> images;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  // Career attributes
  final String jobOutlook;
  final List<String> workEnvironment;
  final String experienceLevel;
  final List<String> responsibilities;
  final String workLifeBalance;
  final String stressLevel;
  final List<String> entryLevelPositions;
  final List<String> seniorPositions;
  final Map<String, String> skillLevels;

  // Career guidance tools
  final Map<String, dynamic>? streamSelector;
  final Map<String, dynamic>? cvTips;
  final Map<String, dynamic>? interviewPrep;

  // Skill categories
  final Map<String, List<String>> skillCategories;

  CareerModel({
    required this.careerId,
    required this.title,
    required this.industryId,
    required this.industryName,
    this.description,
    this.skillIds = const [],
    this.skillNames = const [],
    this.salaryRange,
    this.educationPathIds = const [],
    this.educationPathNames = const [],
    this.images = const [],
    required this.createdAt,
    required this.updatedAt,
    
    // Career attributes with safe defaults
    this.jobOutlook = 'Medium',
    this.workEnvironment = const [],
    this.experienceLevel = 'Entry-level',
    this.responsibilities = const [],
    this.workLifeBalance = 'Good',
    this.stressLevel = 'Medium',
    this.entryLevelPositions = const [],
    this.seniorPositions = const [],
    this.skillLevels = const {},
    
    // Career guidance
    this.streamSelector,
    this.cvTips,
    this.interviewPrep,
    
    // Skill categories
    this.skillCategories = const {},
  });

  // Helper getters for easy access
  List<String> get recommendedStreams {
    if (streamSelector == null) return [];
    final streams = streamSelector!['recommendedStreams'];
    if (streams is List) {
      return streams.whereType<String>().toList();
    }
    return [];
  }

  List<String> get cvDoDonts {
    if (cvTips == null) return [];
    final doDonts = cvTips!['doDonts'];
    if (doDonts is List) {
      return doDonts.whereType<String>().toList();
    }
    return [];
  }

  List<String> get commonInterviewQuestions {
    if (interviewPrep == null) return [];
    final questions = interviewPrep!['commonQuestions'];
    if (questions is List) {
      return questions.whereType<String>().toList();
    }
    return [];
  }

  List<String> get bodyLanguageTips {
    if (interviewPrep == null) return [];
    final tips = interviewPrep!['bodyLanguageTips'];
    if (tips is List) {
      return tips.whereType<String>().toList();
    }
    return [];
  }

  List<String> get mockInterviewVideos {
    if (interviewPrep == null) return [];
    final videos = interviewPrep!['mockVideos'];
    if (videos is List) {
      return videos.whereType<String>().toList();
    }
    return [];
  }

  // Factory method from Firestore
  factory CareerModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    
    // Helper functions for safe data extraction
    List<String> _parseStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
      }
      return [];
    }

    Map<String, String> _parseStringMap(dynamic value) {
      if (value == null) return {};
      if (value is Map) {
        return value.map((key, value) => MapEntry(key.toString(), value.toString()));
      }
      return {};
    }

    Map<String, dynamic>? _parseMap(dynamic value) {
      if (value == null) return null;
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
      return null;
    }

    Map<String, List<String>> _parseSkillCategories(dynamic value) {
      if (value == null) return {};
      if (value is Map) {
        return value.map((key, value) {
          final category = key.toString();
          final skills = _parseStringList(value);
          return MapEntry(category, skills);
        });
      }
      return {};
    }

    return CareerModel(
      careerId: doc.id,
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
      
      // Career attributes
      jobOutlook: data['jobOutlook']?.toString() ?? 'Medium',
      workEnvironment: _parseStringList(data['workEnvironment']),
      experienceLevel: data['experienceLevel']?.toString() ?? 'Entry-level',
      responsibilities: _parseStringList(data['responsibilities']),
      workLifeBalance: data['workLifeBalance']?.toString() ?? 'Good',
      stressLevel: data['stressLevel']?.toString() ?? 'Medium',
      entryLevelPositions: _parseStringList(data['entryLevelPositions']),
      seniorPositions: _parseStringList(data['seniorPositions']),
      skillLevels: _parseStringMap(data['skillLevels']),
      
      // Career guidance
      streamSelector: _parseMap(data['streamSelector']),
      cvTips: _parseMap(data['cvTips']),
      interviewPrep: _parseMap(data['interviewPrep']),
      
      // Skill categories
      skillCategories: _parseSkillCategories(data['skillCategories']),
    );
  }

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'industryId': industryId,
      'industryName': industryName,
      'description': description,
      'skillIds': skillIds,
      'skillNames': skillNames,
      'salaryRange': salaryRange,
      'educationPathIds': educationPathIds,
      'educationPathNames': educationPathNames,
      'images': images,
      'createdAt': createdAt,
      'updatedAt': FieldValue.serverTimestamp(),
      
      // Career attributes
      'jobOutlook': jobOutlook,
      'workEnvironment': workEnvironment,
      'experienceLevel': experienceLevel,
      'responsibilities': responsibilities,
      'workLifeBalance': workLifeBalance,
      'stressLevel': stressLevel,
      'entryLevelPositions': entryLevelPositions,
      'seniorPositions': seniorPositions,
      'skillLevels': skillLevels,
      
      // Career guidance
      'streamSelector': streamSelector,
      'cvTips': cvTips,
      'interviewPrep': interviewPrep,
      
      // Skill categories
      'skillCategories': skillCategories,
    };
  }

  // Copy with method for updates
  CareerModel copyWith({
    String? careerId,
    String? title,
    String? industryId,
    String? industryName,
    String? description,
    List<String>? skillIds,
    List<String>? skillNames,
    String? salaryRange,
    List<String>? educationPathIds,
    List<String>? educationPathNames,
    List<String>? images,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    String? jobOutlook,
    List<String>? workEnvironment,
    String? experienceLevel,
    List<String>? responsibilities,
    String? workLifeBalance,
    String? stressLevel,
    List<String>? entryLevelPositions,
    List<String>? seniorPositions,
    Map<String, String>? skillLevels,
    Map<String, dynamic>? streamSelector,
    Map<String, dynamic>? cvTips,
    Map<String, dynamic>? interviewPrep,
    Map<String, List<String>>? skillCategories,
  }) {
    return CareerModel(
      careerId: careerId ?? this.careerId,
      title: title ?? this.title,
      industryId: industryId ?? this.industryId,
      industryName: industryName ?? this.industryName,
      description: description ?? this.description,
      skillIds: skillIds ?? this.skillIds,
      skillNames: skillNames ?? this.skillNames,
      salaryRange: salaryRange ?? this.salaryRange,
      educationPathIds: educationPathIds ?? this.educationPathIds,
      educationPathNames: educationPathNames ?? this.educationPathNames,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      jobOutlook: jobOutlook ?? this.jobOutlook,
      workEnvironment: workEnvironment ?? this.workEnvironment,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      responsibilities: responsibilities ?? this.responsibilities,
      workLifeBalance: workLifeBalance ?? this.workLifeBalance,
      stressLevel: stressLevel ?? this.stressLevel,
      entryLevelPositions: entryLevelPositions ?? this.entryLevelPositions,
      seniorPositions: seniorPositions ?? this.seniorPositions,
      skillLevels: skillLevels ?? this.skillLevels,
      streamSelector: streamSelector ?? this.streamSelector,
      cvTips: cvTips ?? this.cvTips,
      interviewPrep: interviewPrep ?? this.interviewPrep,
      skillCategories: skillCategories ?? this.skillCategories,
    );
  }
}