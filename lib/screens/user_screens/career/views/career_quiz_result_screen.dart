import 'package:flutter/material.dart';
import 'package:aspire_edge/constants.dart';
import 'package:aspire_edge/models/career_model.dart';
import 'career_details_screen.dart';
import 'package:aspire_edge/services/career_service.dart';
import 'package:aspire_edge/routes/screen_export.dart';

class CareerQuizResultScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final String quizTitle;
  final CareerModel career;

  const CareerQuizResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.quizTitle,
    required this.career,
  });

  @override
  State<CareerQuizResultScreen> createState() => _CareerQuizResultScreenState();
}

class _CareerQuizResultScreenState extends State<CareerQuizResultScreen> {
  List<CareerModel> recommendedCareers = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadRecommendedCareers();
  }

  Future<void> _loadRecommendedCareers() async {
    try {
      final careerService = CareerService();
      final careers = await careerService.getAllCareers();

      final maxScore = widget.totalQuestions * 5;
      final scorePercentage =
          maxScore > 0 ? (widget.score / maxScore) * 100 : 0;

      List<CareerModel> filteredCareers = [];

      if (scorePercentage >= 70) {
        filteredCareers = careers
            .where((career) =>
                career.industryId.toLowerCase().contains('tech') ||
                career.industryId.toLowerCase().contains('software') ||
                career.industryId.toLowerCase().contains('it'))
            .toList();
      } else if (scorePercentage >= 40) {
        filteredCareers = careers
            .where((career) =>
                career.industryId.toLowerCase().contains('business') ||
                career.industryId.toLowerCase().contains('management') ||
                career.industryId.toLowerCase().contains('admin'))
            .toList();
      } else {
        filteredCareers = careers
            .where((career) =>
                career.industryId.toLowerCase().contains('creative') ||
                career.industryId.toLowerCase().contains('design') ||
                career.industryId.toLowerCase().contains('art'))
            .toList();
      }

      setState(() {
        recommendedCareers = filteredCareers.take(3).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load career recommendations';
        isLoading = false;
      });
    }
  }

  Widget _buildScoreCard() {
    final maxScore = widget.totalQuestions * 5;
    final percentage = maxScore > 0 ? (widget.score / maxScore) * 100 : 0;

    String getPerformanceText() {
      if (percentage >= 80) return 'Excellent! 🎉';
      if (percentage >= 60) return 'Great job! 👍';
      if (percentage >= 40) return 'Good effort! 💪';
      return 'Keep practicing! 📚';
    }

    String getPerformanceDescription() {
      if (percentage >= 80) return 'You have excellent knowledge in this field!';
      if (percentage >= 60) return 'You have good understanding of this career';
      if (percentage >= 40) return 'You have basic knowledge, keep learning!';
      return 'Continue exploring and learning about this field';
    }

    Color getPerformanceColor() {
      if (percentage >= 80) return AppColors.success;
      if (percentage >= 60) return AppColors.primary;
      if (percentage >= 40) return AppColors.warning;
      return AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            getPerformanceText(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: getPerformanceColor(),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            getPerformanceDescription(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 12,
                  color: getPerformanceColor(),
                  backgroundColor: Colors.grey.withOpacity(0.2),
                ),
              ),
              Column(
                children: [
                  Text(
                    widget.score.toString(),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "/ $maxScore",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black.withOpacity(0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: getPerformanceColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: getPerformanceColor().withOpacity(0.3)),
            ),
            child: Text(
              "${percentage.toStringAsFixed(1)}% Score",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: getPerformanceColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareerCard(CareerModel career) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CareerDetailsScreen(careerId: career.careerId),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Career Image
                    if (career.images.isNotEmpty)
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(career.images.first),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            career.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              career.industryId,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  career.description ?? "No description available",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.6),
                    height: 1.4,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: career.skillIds
                      .take(3)
                      .map((skill) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.3)),
                            ),
                            child: Text(
                              skill,
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Quiz Results",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 20),
                  Text(
                    "Analyzing your results...",
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.6),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: _buildScoreCard(),
                        ),
                        const SizedBox(height: 32),
                        
                        // Recommended Careers Section
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Recommended Careers",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (errorMessage.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.error_outline,
                                          color: AppColors.error),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          errorMessage,
                                          style:
                                              TextStyle(color: AppColors.error),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else if (recommendedCareers.isEmpty)
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.work_outline,
                                        size: 48,
                                        color: Colors.black.withOpacity(0.6),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        "No specific recommendations yet",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black.withOpacity(0.6),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Complete more quizzes to get personalized career suggestions",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.4),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Column(
                                  children: recommendedCareers
                                      .map(_buildCareerCard)
                                      .toList(),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Action Buttons
                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CareerDetailsScreen(
                                        careerId: widget.career.careerId),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.work_outline,
                                        color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text(
                                      "View Career Details",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}