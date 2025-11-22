// ignore_for_file: use_build_context_synchronously, collection_methods_unrelated_type

import 'package:flutter/material.dart';
import 'package:aspire_edge/components/career_button.dart';
import 'package:aspire_edge/components/custom_modal_bottom_sheet.dart';
import 'package:aspire_edge/models/quiz_model.dart';
import 'package:aspire_edge/models/resource_model.dart';
import 'package:aspire_edge/models/testimonial_model.dart';
import 'package:aspire_edge/constants.dart' hide AppColors;
import 'package:aspire_edge/theme/app_theme.dart';
import 'package:aspire_edge/routes/screen_export.dart';
import 'package:aspire_edge/services/quiz_service.dart';
import 'package:aspire_edge/services/wishlist_service.dart';
import 'components/career_images.dart';
import 'components/career_list_tile.dart';
import 'package:aspire_edge/models/career_model.dart';
import 'package:aspire_edge/services/career_service.dart';
import 'package:aspire_edge/services/feedback_service.dart';
import 'package:aspire_edge/services/resource_service.dart';
import 'package:aspire_edge/services/testimonial_service.dart';

class CareerDetailsScreen extends StatelessWidget {
  final String careerId;

  const CareerDetailsScreen({
    super.key,
    required this.careerId,
  });

  @override
  Widget build(BuildContext context) {
    final careerService = CareerService();
    final quizService = QuizService();
    final resourceService = ResourceService();
    final testimonialService = TestimonialService();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: StreamBuilder<CareerModel?>(
        stream: careerService.getCareerById(careerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return _buildErrorState(context);
          }

          final career = snapshot.data!;
          return _buildCareerContent(context, career, resourceService, testimonialService, quizService);
        },
      ),
    );
  }

Widget _buildCareerContent(BuildContext context, CareerModel career, 
    ResourceService resourceService, TestimonialService testimonialService, QuizService quizService) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isSmallScreen = screenWidth < 375;
  final isMediumScreen = screenWidth >= 375 && screenWidth < 768;
  final isLargeScreen = screenWidth >= 768;

  return Scaffold(
    backgroundColor: Colors.grey[50],
    bottomNavigationBar: StreamBuilder<QuizModel?>(
      stream: quizService.getQuizByCareerIdStream(career.careerId),
      builder: (context, quizSnapshot) {
        final hasQuiz = quizSnapshot.hasData && quizSnapshot.data != null;

        return hasQuiz
            ? CareerButton(
                career: career,
                press: () async {
                  try {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );

                    // Load quiz by career ID
                    final quiz = await QuizService().getQuizByCareerId(career.careerId);

                    // Dismiss loading
                    Navigator.pop(context);

                    if (quiz != null) {
                      // Navigate directly to the quiz screen instead of using bottom sheet
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CareerQuizScreen(career: career),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("No quiz available for ${career.title}"),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  } catch (e) {
                    // Dismiss loading if still showing
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error loading quiz: $e"),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
              )
            : const SizedBox.shrink(); // Hide button if no quiz
      },
    ),
    body: CustomScrollView(
      slivers: [
        /// Modern App Bar with Responsive Design
        _buildAppBarSection(context, career, isSmallScreen),

        /// Career Overview Section
        _buildOverviewSection(career, isSmallScreen),

        /// Work Environment & Attributes
        if (career.workEnvironment.isNotEmpty || career.experienceLevel != null)
          _buildWorkEnvironmentSection(career, isSmallScreen),

        /// Career Progression
        if (career.entryLevelPositions.isNotEmpty || career.seniorPositions.isNotEmpty)
          _buildCareerProgressionSection(career, isSmallScreen),

        /// Key Responsibilities
        if (career.responsibilities.isNotEmpty)
          _buildResponsibilitiesSection(career, isSmallScreen),

        /// Career Guidance Tools - Responsive
        _buildGuidanceToolsSection(context, career, isSmallScreen, isMediumScreen, isLargeScreen),

        /// Feedback Summary
        _buildFeedbackSummarySection(context, isSmallScreen),

        /// Feedback Button
        _buildFeedbackButtonSection(context, career, isSmallScreen),

        /// Learning Resources Section - Enhanced & Responsive
        _buildResourcesSection(context, resourceService, career, isSmallScreen, isMediumScreen, isLargeScreen),

        /// Success Stories Section - Enhanced & Responsive
        _buildTestimonialsSection(context, testimonialService, career, isSmallScreen, isMediumScreen, isLargeScreen),

        /// Related Careers
        _buildRelatedCareersSection(context, CareerService(), career, isSmallScreen, isMediumScreen, isLargeScreen),

        /// Bottom Padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    ),
  );
}


  // ============ SECTION BUILDERS ============

  SliverAppBar _buildAppBarSection(BuildContext context, CareerModel career, bool isSmallScreen) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      expandedHeight: isSmallScreen ? 240 : 280,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        expandedTitleScale: isSmallScreen ? 1.3 : 1.5,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              bottom: 0,
              child: CareerImages(images: career.images),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    career.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 20 : 24,
                      fontWeight: FontWeight.w800,
                      shadows: const [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black54,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildCareerTags(context, career),
                ],
              ),
            ),
          ],
        ),
      ),
      leading: _buildBackButton(context, isSmallScreen),
      actions: [_buildWishlistButton(career, isSmallScreen)],
    );
  }

  Widget _buildCareerTags(BuildContext context, CareerModel career) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _buildTag(career.industryName, Icons.work_rounded),
        _buildTag(career.experienceLevel, Icons.timeline_rounded),
        StreamBuilder<Map<String, dynamic>>(
          stream: FeedbackService().getFeedbackStats(),
          builder: (context, snap) {
            final totalCount = snap.hasData ? (snap.data!["totalCount"] ?? 0) : 0;
            return _buildTag("$totalCount feedbacks", Icons.feedback_rounded);
          },
        ),
      ],
    );
  }

  Widget _buildTag(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.only(left: isSmallScreen ? 4 : 8, top: 8),
      child: Container(
        width: isSmallScreen ? 36 : 40,
        height: isSmallScreen ? 36 : 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary, size: isSmallScreen ? 18 : 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _buildWishlistButton(CareerModel career, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.only(right: isSmallScreen ? 4 : 8, top: 8),
      child: StreamBuilder<bool>(
        stream: WishlistService().isCareerInWishlist(career.careerId),
        builder: (context, snap) {
          final isInWishlist = snap.data ?? false;
          return Container(
            width: isSmallScreen ? 36 : 40,
            height: isSmallScreen ? 36 : 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => _toggleWishlist(career, isInWishlist),
              icon: Icon(
                isInWishlist ? Icons.bookmark : Icons.bookmark_border,
                color: isInWishlist ? AppColors.primary : AppColors.darkGrey,
                size: isSmallScreen ? 18 : 20,
              ),
            ),
          );
        },
      ),
    );
  }

  SliverToBoxAdapter _buildOverviewSection(CareerModel career, bool isSmallScreen) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: 16),
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Career Overview", isSmallScreen),
            const SizedBox(height: 16),
            if (career.description != null && career.description!.isNotEmpty)
              _buildDetailItem("Description", career.description!, Icons.description_rounded, isSmallScreen),
            if (career.salaryRange != null && career.salaryRange!.isNotEmpty)
              _buildDetailItem("Salary Range", career.salaryRange!, Icons.attach_money_rounded, isSmallScreen),
            _buildDetailItem("Job Outlook", career.jobOutlook, Icons.trending_up_rounded, isSmallScreen),
            _buildDetailItem("Work-Life Balance", career.workLifeBalance, Icons.work_rounded, isSmallScreen),
            _buildDetailItem("Stress Level", career.stressLevel, Icons.psychology_rounded, isSmallScreen),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildWorkEnvironmentSection(CareerModel career, bool isSmallScreen) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: 8),
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Work Environment", isSmallScreen),
            const SizedBox(height: 16),
            if (career.workEnvironment.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: career.workEnvironment
                    .map((env) => Chip(
                          label: Text(env, style: TextStyle(fontSize: isSmallScreen ? 12 : 14)),
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                        ))
                    .toList(),
              ),
            if (career.experienceLevel != null) ...[
              const SizedBox(height: 16),
              _buildDetailItem("Experience Level", career.experienceLevel, Icons.work_history_rounded, isSmallScreen),
            ],
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildCareerProgressionSection(CareerModel career, bool isSmallScreen) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: 8),
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Career Progression", isSmallScreen),
            const SizedBox(height: 16),
            if (career.entryLevelPositions.isNotEmpty)
              _buildPositionsSection("Entry Level Positions", career.entryLevelPositions, Icons.arrow_upward_rounded, isSmallScreen),
            if (career.seniorPositions.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildPositionsSection("Senior Positions", career.seniorPositions, Icons.leaderboard_rounded, isSmallScreen),
            ],
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildResponsibilitiesSection(CareerModel career, bool isSmallScreen) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: 8),
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Key Responsibilities", isSmallScreen),
            const SizedBox(height: 16),
            Column(
              children: career.responsibilities
                  .map((responsibility) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(top: 8, right: 12),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                responsibility,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 13 : 14,
                                  color: AppColors.darkGrey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildGuidanceToolsSection(BuildContext context, CareerModel career, 
      bool isSmallScreen, bool isMediumScreen, bool isLargeScreen) {
    final paddingValue = isSmallScreen ? 12.0 : 16.0;

    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: paddingValue, vertical: 8),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Text(
                    "Career Guidance Tools",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                _buildGuidanceToolTile(
                  context,
                  "assets/icons/CV.svg",
                  "CV Tips & Guidelines",
                  "Professional resume building tips",
                  () => _showCvTips(context, career),
                ),
                _buildGuidanceToolTile(
                  context,
                  "assets/icons/Interview.svg",
                  "Interview Preparation",
                  "Ace your job interviews",
                  () => _showInterviewTips(context, career),
                ),
                if (career.educationPathNames.isNotEmpty)
                  _buildGuidanceToolTile(
                    context,
                    "assets/icons/Education.svg",
                    "Education Paths",
                    "Required educational qualifications",
                    () => _showEducationPaths(context, career),
                  ),
                if (career.skillNames.isNotEmpty)
                  _buildGuidanceToolTile(
                    context,
                    "assets/icons/Skills.svg",
                    "Required Skills",
                    "Essential skills for this career",
                    () => _showSkills(context, career),
                  ),
                if (career.streamSelector != null && 
                    career.streamSelector!['recommendedStreams'] != null && 
                    (career.streamSelector!['recommendedStreams'] as List).isNotEmpty)
                  _buildGuidanceToolTile(
                    context,
                    "assets/icons/Stream.svg",
                    "Recommended Streams",
                    "Best academic streams for this career",
                    () => _showRecommendedStreams(context, career),
                  ),
                _buildGuidanceToolTile(
                  context,
                  "assets/icons/FAQ.svg",
                  "FAQ's",
                  "Frequently asked questions",
                  () => _showFaq(context, career),
                  isLast: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildFeedbackSummarySection(BuildContext context, bool isSmallScreen) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: 16),
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: StreamBuilder<Map<String, dynamic>>(
          stream: FeedbackService().getFeedbackStats(),
          builder: (context, snap) {
            if (!snap.hasData) return _buildLoadingFeedback(isSmallScreen);

            final stats = snap.data!;
            final categoryData = stats["byCategory"] as Map<String, int>? ?? {};
            final positiveCount = categoryData["positive feedback"] ?? 0;
            final totalCount = stats["totalCount"] ?? 0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Feedback Overview", isSmallScreen),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildFeedbackStatCard(
                        'Total Feedback',
                        totalCount.toString(),
                        Icons.feedback_rounded,
                        AppColors.primary,
                        isSmallScreen,
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 8 : 12),
                    Expanded(
                      child: _buildFeedbackStatCard(
                        'Satisfaction Rate',
                        totalCount > 0 ? '${((positiveCount / totalCount) * 100).round()}%' : '0%',
                        Icons.sentiment_satisfied_rounded,
                        AppColors.success,
                        isSmallScreen,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildFeedbackButtonSection(BuildContext context, CareerModel career, bool isSmallScreen) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: 8),
        child: CareerListTile(
          svgSrc: "assets/icons/Feedback.svg",
          title: "Feedback & Reviews",
          subtitle: "Share your experience and read reviews",
          isShowBottomBorder: false,
          press: () {
            Navigator.pushNamed(
              context,
              feedbackScreenRoute,
              arguments: {
                'careerId': career.careerId,
                'careerTitle': career.title,
              },
            );
          },
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildResourcesSection(BuildContext context, ResourceService resourceService, 
      CareerModel career, bool isSmallScreen, bool isMediumScreen, bool isLargeScreen) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeaderBanner(
            "Learning Resources",
            Icons.library_books_rounded,
            resourceService,
            career,
          ),
          StreamBuilder<List<ResourceModel>>(
            stream: resourceService.getResourcesStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return _buildLoadingResources(isSmallScreen);

              final resources = snapshot.data!
                  .where((resource) => resource.careerId == career.careerId)
                  .toList();

              if (resources.isEmpty) return _buildEmptyResources(isSmallScreen);

              return Container(
                margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
                child: Column(
                  children: [
                    _buildResourcesStatistics(resources, isSmallScreen),
                    const SizedBox(height: 16),
                    _buildResourcesGrid(resources, context, isSmallScreen, isMediumScreen, isLargeScreen),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildTestimonialsSection(BuildContext context, TestimonialService testimonialService, 
      CareerModel career, bool isSmallScreen, bool isMediumScreen, bool isLargeScreen) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeaderBanner(
            "Success Stories",
            Icons.people_alt_rounded,
            testimonialService,
            career,
          ),
          StreamBuilder<List<Testimonial>>(
            stream: testimonialService.getTestimonials(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return _buildLoadingTestimonials(isSmallScreen);

              final testimonials = snapshot.data!;
              if (testimonials.isEmpty) return _buildEmptyTestimonials(isSmallScreen);

              return Container(
                margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
                child: Column(
                  children: [
                    _buildTestimonialsStatistics(testimonials, isSmallScreen),
                    const SizedBox(height: 16),
                    _buildTestimonialsGrid(testimonials, context, isSmallScreen, isMediumScreen, isLargeScreen),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildRelatedCareersSection(BuildContext context, CareerService careerService, 
      CareerModel career, bool isSmallScreen, bool isMediumScreen, bool isLargeScreen) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 24, left: isSmallScreen ? 12 : 16, right: isSmallScreen ? 12 : 16, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "You may also like",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                        fontSize: isSmallScreen ? 18 : 20,
                      ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, careerBankScreenRoute),
                  child: Text(
                    "View All",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          StreamBuilder<List<CareerModel>>(
            stream: careerService.getRelatedCareers(
              careerId: career.careerId,
              categories: career.skillIds,
              industryId: career.industryId,
            ),
            builder: (context, relatedSnap) {
              if (!relatedSnap.hasData) return _buildLoadingRelatedCareers(isSmallScreen);
              
              final relatedCareers = relatedSnap.data!;
              if (relatedCareers.isEmpty) return const SizedBox();

              return SizedBox(
                height: isSmallScreen ? 200 : 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: relatedCareers.length,
                  padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
                  itemBuilder: (context, index) {
                    final relatedCareer = relatedCareers[index];
                    return _buildRelatedCareerCard(relatedCareer, context, isSmallScreen, index, relatedCareers.length);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============ RESPONSIVE GRID BUILDERS ============

  Widget _buildResourcesGrid(List<ResourceModel> resources, BuildContext context, 
      bool isSmallScreen, bool isMediumScreen, bool isLargeScreen) {
    final crossAxisCount = _getResourcesCrossAxisCount(isSmallScreen, isMediumScreen, isLargeScreen);
    final childAspectRatio = _getResourcesAspectRatio(isSmallScreen, isMediumScreen, isLargeScreen);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: isSmallScreen ? 8 : 12,
        mainAxisSpacing: isSmallScreen ? 8 : 12,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: resources.length,
      itemBuilder: (context, index) {
        return _buildResourceCard(resources[index], context, isSmallScreen);
      },
    );
  }

  Widget _buildTestimonialsGrid(List<Testimonial> testimonials, BuildContext context, 
      bool isSmallScreen, bool isMediumScreen, bool isLargeScreen) {
    final crossAxisCount = _getTestimonialsCrossAxisCount(isSmallScreen, isMediumScreen, isLargeScreen);
    final childAspectRatio = _getTestimonialsAspectRatio(isSmallScreen, isMediumScreen, isLargeScreen);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: isSmallScreen ? 8 : 12,
        mainAxisSpacing: isSmallScreen ? 8 : 12,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: testimonials.length,
      itemBuilder: (context, index) {
        return _buildTestimonialCard(testimonials[index], context, isSmallScreen);
      },
    );
  }

  // ============ RESPONSIVE LAYOUT CALCULATIONS ============

  int _getResourcesCrossAxisCount(bool isSmallScreen, bool isMediumScreen, bool isLargeScreen) {
    if (isLargeScreen) return 3;
    if (isMediumScreen) return 2;
    return 1; // Small screen
  }

  double _getResourcesAspectRatio(bool isSmallScreen, bool isMediumScreen, bool isLargeScreen) {
    if (isLargeScreen) return 0.75;
    if (isMediumScreen) return 0.8;
    return 0.9; // Small screen
  }

  int _getTestimonialsCrossAxisCount(bool isSmallScreen, bool isMediumScreen, bool isLargeScreen) {
    if (isLargeScreen) return 3;
    if (isMediumScreen) return 2;
    return 1; // Small screen
  }

  double _getTestimonialsAspectRatio(bool isSmallScreen, bool isMediumScreen, bool isLargeScreen) {
    if (isLargeScreen) return 0.85;
    if (isMediumScreen) return 0.9;
    return 1.0; // Small screen
  }

  // ============ ENHANCED RESOURCE CARD ============

  Widget _buildResourceCard(ResourceModel resource, BuildContext context, bool isSmallScreen) {
    final typeColor = _getResourceTypeColor(resource.type);
    final mediaType = _getMediaTypeDisplayName(resource.mediaType);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, resourceScreenRoute, arguments: resource),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: isSmallScreen ? 8 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resource Image with Enhanced Design
            Container(
              height: isSmallScreen ? 100 : 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isSmallScreen ? 12 : 16),
                  topRight: Radius.circular(isSmallScreen ? 12 : 16),
                ),
                image: _getResourceImageDecoration(resource),
                color: _getResourceBackgroundColor(resource.mediaType),
              ),
              child: Stack(
                children: [
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(isSmallScreen ? 12 : 16),
                        topRight: Radius.circular(isSmallScreen ? 12 : 16),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                        ],
                      ),
                    ),
                  ),

                  // Type Badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: typeColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        resource.type.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Media Type Indicator
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getResourceTypeIcon(resource.type), color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            mediaType,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Resource Details
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      resource.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: isSmallScreen ? 13 : 14,
                        color: AppColors.black,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Author and Metadata
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (resource.author.isNotEmpty)
                          Text(
                            "By ${resource.author}",
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: isSmallScreen ? 11 : 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              _getResourceTypeIcon(resource.type),
                              color: typeColor,
                              size: isSmallScreen ? 12 : 14,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                mediaType,
                                style: TextStyle(
                                  color: typeColor,
                                  fontSize: isSmallScreen ? 11 : 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ ENHANCED TESTIMONIAL CARD ============

  Widget _buildTestimonialCard(Testimonial testimonial, BuildContext context, bool isSmallScreen) {
    final tierColor = _getTierColor(testimonial.tier);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, userTestimonialScreenRoute, arguments: testimonial),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: isSmallScreen ? 8 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Section
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    tierColor.withOpacity(0.1),
                    tierColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isSmallScreen ? 12 : 16),
                  topRight: Radius.circular(isSmallScreen ? 12 : 16),
                ),
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: isSmallScreen ? 40 : 50,
                    height: isSmallScreen ? 40 : 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: tierColor.withOpacity(0.3), width: 2),
                      image: testimonial.imageUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(testimonial.imageUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: testimonial.imageUrl.isEmpty
                        ? Icon(Icons.person_rounded, color: tierColor, size: isSmallScreen ? 20 : 24)
                        : null,
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          testimonial.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: isSmallScreen ? 13 : 14,
                            color: AppColors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: tierColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getTierLabel(testimonial.tier).toUpperCase(),
                            style: TextStyle(
                              color: tierColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Story Preview
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      testimonial.story,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 11 : 12,
                        color: AppColors.darkGrey,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Read story →",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: isSmallScreen ? 11 : 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ HELPER WIDGETS ============

  Widget _buildSectionTitle(String title, bool isSmallScreen) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: isSmallScreen ? 8 : 12),
        Text(
          title,
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon, bool isSmallScreen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isSmallScreen ? 28 : 32,
            height: isSmallScreen ? 28 : 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: isSmallScreen ? 14 : 16),
          ),
          SizedBox(width: isSmallScreen ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11 : 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGrey,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 2 : 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionsSection(String title, List<String> positions, IconData icon, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: positions
              .map((position) => Chip(
                    label: Text(position, style: TextStyle(fontSize: isSmallScreen ? 11 : 13)),
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildGuidanceToolTile(BuildContext context, String icon, String title, String subtitle, 
      VoidCallback onTap, {bool isLast = false}) {
    return CareerListTile(
      svgSrc: icon,
      title: title,
      subtitle: subtitle,
      isShowBottomBorder: !isLast,
      press: onTap,
    );
  }

  Widget _buildSectionHeaderBanner(String title, IconData icon, dynamic service, CareerModel career) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                StreamBuilder(
                  stream: service is ResourceService ? service.getResourcesStream() : service.getTestimonials(),
                  builder: (context, snapshot) {
                    final count = snapshot.hasData ? snapshot.data!: 0;
                    return Text(
                      "$count ${title.toLowerCase()} available",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesStatistics(List<ResourceModel> resources, bool isSmallScreen) {
    final blogCount = resources.where((r) => r.type.toLowerCase() == 'blog').length;
    final videoCount = resources.where((r) => r.type.toLowerCase() == 'video').length;
    final ebookCount = resources.where((r) => r.type.toLowerCase() == 'ebook').length;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: isSmallScreen ? 8 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', resources.length, Icons.library_books_rounded, AppColors.primary, isSmallScreen),
          _buildStatItem('Blogs', blogCount, Icons.article_rounded, AppColors.info, isSmallScreen),
          _buildStatItem('Videos', videoCount, Icons.video_library_rounded, AppColors.success, isSmallScreen),
          _buildStatItem('E-Books', ebookCount, Icons.menu_book_rounded, AppColors.secondary, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, IconData icon, Color color, bool isSmallScreen) {
    return Column(
      children: [
        Container(
          width: isSmallScreen ? 32 : 40,
          height: isSmallScreen ? 32 : 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: isSmallScreen ? 16 : 20),
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 9 : 10,
            color: AppColors.darkGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildTestimonialsStatistics(List<Testimonial> testimonials, bool isSmallScreen) {
    final studentCount = testimonials.where((t) => t.tier == 'student').length;
    final graduateCount = testimonials.where((t) => t.tier == 'graduate').length;
    final professionalCount = testimonials.where((t) => t.tier == 'professional').length;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: isSmallScreen ? 8 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', testimonials.length, Icons.people_alt_rounded, AppColors.secondary, isSmallScreen),
          _buildStatItem('Students', studentCount, Icons.school_rounded, AppColors.info, isSmallScreen),
          _buildStatItem('Graduates', graduateCount, Icons.celebration_rounded, AppColors.success, isSmallScreen),
          _buildStatItem('Professionals', professionalCount, Icons.work_rounded, AppColors.primary, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildFeedbackStatCard(String title, String value, IconData icon, Color color, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: isSmallScreen ? 32 : 40,
            height: isSmallScreen ? 32 : 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: isSmallScreen ? 16 : 20),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: isSmallScreen ? 11 : 12,
              color: AppColors.darkGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedCareerCard(CareerModel career, BuildContext context, bool isSmallScreen, int index, int totalCount) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CareerDetailsScreen(careerId: career.careerId),
          ),
        );
      },
      child: Container(
        width: isSmallScreen ? 180 : 220,
        margin: EdgeInsets.only(right: index == totalCount - 1 ? 0 : (isSmallScreen ? 12 : 16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Career image
            Container(
              height: isSmallScreen ? 90 : 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isSmallScreen ? 16 : 20),
                  topRight: Radius.circular(isSmallScreen ? 16 : 20),
                ),
                image: DecorationImage(
                  image: NetworkImage(
                    career.images.isNotEmpty ? career.images[0] : "https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=400",
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Career details
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    career.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isSmallScreen ? 4 : 6),
                  Text(
                    career.industryName,
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  Row(
                    children: [
                      Icon(Icons.trending_up_rounded, color: AppColors.success, size: isSmallScreen ? 16 : 18),
                      SizedBox(width: 4),
                      Text(
                        "High demand",
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: isSmallScreen ? 11 : 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (career.salaryRange != null)
                        Text(
                          career.salaryRange!,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: isSmallScreen ? 12 : 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ LOADING AND EMPTY STATES ============

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Text(
          "Career not found",
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }

  Widget _buildLoadingResources(bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
      height: 200,
      child: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  Widget _buildEmptyResources(bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
      padding: EdgeInsets.all(isSmallScreen ? 24 : 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.library_books_outlined,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "No Resources Available",
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "There are no resources added for this career yet",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.darkGrey,
              fontSize: isSmallScreen ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingTestimonials(bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
      height: 200,
      child: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  Widget _buildEmptyTestimonials(bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
      padding: EdgeInsets.all(isSmallScreen ? 24 : 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_alt_outlined,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "No Success Stories Yet",
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Be the first to share your success story",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.darkGrey,
              fontSize: isSmallScreen ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingFeedback(bool isSmallScreen) {
    return SizedBox(
      height: isSmallScreen ? 150 : 200,
      child: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  Widget _buildLoadingRelatedCareers(bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
      height: isSmallScreen ? 200 : 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) => Container(
          width: isSmallScreen ? 180 : 220,
          margin: EdgeInsets.only(
            left: index == 0 ? 0 : (isSmallScreen ? 12 : 16),
            right: index == 2 ? 0 : (isSmallScreen ? 12 : 16),
          ),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
          ),
        ),
      ),
    );
  }

  // ============ HELPER METHODS ============

  void _toggleWishlist(CareerModel career, bool isInWishlist) {
    if (isInWishlist) {
      WishlistService().removeFromWishlist(career.careerId);
    } else {
      WishlistService().addToWishlist(career);
    }
  }


  // Resource Helper Methods
  DecorationImage? _getResourceImageDecoration(ResourceModel resource) {
    if (resource.displayImageUrl != null && resource.displayImageUrl!.isNotEmpty) {
      return DecorationImage(
        image: NetworkImage(resource.displayImageUrl!),
        fit: BoxFit.cover,
      );
    }
    if (resource.mediaType == 'image' && resource.url.isNotEmpty) {
      return DecorationImage(
        image: NetworkImage(resource.url),
        fit: BoxFit.cover,
      );
    }
    if (resource.url.isNotEmpty && 
        (resource.url.contains('.jpg') || resource.url.contains('.jpeg') || 
         resource.url.contains('.png') || resource.url.contains('.webp'))) {
      return DecorationImage(
        image: NetworkImage(resource.url),
        fit: BoxFit.cover,
      );
    }
    return null;
  }

  Color _getResourceBackgroundColor(String mediaType) {
    switch (mediaType) {
      case 'pdf': return Colors.red.shade500;
      case 'video': return Colors.purple.shade500;
      case 'ebook': return Colors.blue.shade500;
      case 'blog': return Colors.green.shade500;
      default: return Colors.grey.shade300;
    }
  }

  Color _getResourceTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'blog': return AppColors.info;
      case 'video': return AppColors.success;
      case 'ebook': return AppColors.secondary;
      case 'pdf': return AppColors.warning;
      default: return AppColors.primary;
    }
  }

  IconData _getResourceTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'blog': return Icons.article_rounded;
      case 'video': return Icons.video_library_rounded;
      case 'ebook': return Icons.menu_book_rounded;
      case 'pdf': return Icons.picture_as_pdf_rounded;
      default: return Icons.link_rounded;
    }
  }

  String _getMediaTypeDisplayName(String mediaType) {
    switch (mediaType) {
      case 'pdf': return 'PDF Document';
      case 'video': return 'Video Content';
      case 'ebook': return 'E-Book';
      case 'blog': return 'Blog Article';
      case 'image': return 'Image Resource';
      default: return mediaType;
    }
  }

  // Testimonial Helper Methods
  Color _getTierColor(String tier) {
    switch (tier) {
      case 'student': return AppColors.info;
      case 'graduate': return AppColors.success;
      case 'professional': return AppColors.secondary;
      default: return AppColors.primary;
    }
  }

  String _getTierLabel(String tier) {
    switch (tier) {
      case 'student': return 'Student';
      case 'graduate': return 'Graduate';
      case 'professional': return 'Professional';
      default: return 'All Stories';
    }
  }

  // Bottom Sheet Methods
  void _showCvTips(BuildContext context, CareerModel career) {
    customModalBottomSheet(
      context,
      height: MediaQuery.of(context).size.height * 0.8,
      child: _buildCvTipsSheet(career),
    );
  }

  void _showInterviewTips(BuildContext context, CareerModel career) {
    customModalBottomSheet(
      context,
      height: MediaQuery.of(context).size.height * 0.8,
      child: _buildInterviewTipsSheet(career),
    );
  }

  void _showEducationPaths(BuildContext context, CareerModel career) {
    customModalBottomSheet(
      context,
      height: MediaQuery.of(context).size.height * 0.7,
      child: _buildEducationPathsSheet(career),
    );
  }

  void _showSkills(BuildContext context, CareerModel career) {
    customModalBottomSheet(
      context,
      height: MediaQuery.of(context).size.height * 0.7,
      child: _buildSkillsSheet(career),
    );
  }

  void _showRecommendedStreams(BuildContext context, CareerModel career) {
    customModalBottomSheet(
      context,
      height: MediaQuery.of(context).size.height * 0.6,
      child: _buildRecommendedStreamsSheet(career),
    );
  }

  void _showFaq(BuildContext context, CareerModel career) {
    customModalBottomSheet(
      context,
      height: MediaQuery.of(context).size.height * 0.7,
      child: _buildFaqSheet(career),
    );
  }

  // Bottom Sheet Content Builders
  Widget _buildCvTipsSheet(CareerModel career) {
    final cvTips = career.cvTips?['doDonts'] ?? [];
    final hasTips = cvTips.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "CV Tips for ${career.title}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: hasTips
                ? ListView(
                    children: cvTips
                        .map((tip) => ListTile(
                              leading: const Icon(Icons.check_circle, color: Colors.green),
                              title: Text(tip),
                            ))
                        .toList(),
                  )
                : const Center(child: Text("No CV tips available yet", style: TextStyle(color: Colors.grey))),
          ),
        ],
      ),
    );
  }

  Widget _buildInterviewTipsSheet(CareerModel career) {
    final interviewPrep = career.interviewPrep ?? {};
    final commonQuestions = interviewPrep['commonQuestions'] ?? [];
    final bodyLanguageTips = interviewPrep['bodyLanguageTips'] ?? [];
    final mockVideos = interviewPrep['mockVideos'] ?? [];

    return DefaultTabController(
      length: 3,
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Interview Preparation for ${career.title}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TabBar(
              tabs: const [
                Tab(text: 'Questions'),
                Tab(text: 'Body Language'),
                Tab(text: 'Mock Videos'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                children: [
                  commonQuestions.isNotEmpty
                      ? ListView(
                          children: commonQuestions
                              .map((question) => ListTile(
                                    leading: const Icon(Icons.question_answer_rounded, color: Colors.blue),
                                    title: Text(question),
                                  ))
                              .toList(),
                        )
                      : const Center(child: Text("No interview questions available", style: TextStyle(color: Colors.grey))),
                  bodyLanguageTips.isNotEmpty
                      ? ListView(
                          children: bodyLanguageTips
                              .map((tip) => ListTile(
                                    leading: const Icon(Icons.people_rounded, color: Colors.orange),
                                    title: Text(tip),
                                  ))
                              .toList(),
                        )
                      : const Center(child: Text("No body language tips available", style: TextStyle(color: Colors.grey))),
                  mockVideos.isNotEmpty
                      ? ListView(
                          children: mockVideos
                              .map((video) => ListTile(
                                    leading: const Icon(Icons.video_library_rounded, color: Colors.purple),
                                    title: Text(video.contains('http') ? "Watch Video" : video),
                                    onTap: video.contains('http') ? () {} : null,
                                  ))
                              .toList(),
                        )
                      : const Center(child: Text("No mock interview videos available", style: TextStyle(color: Colors.grey))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationPathsSheet(CareerModel career) {
    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Education Paths for ${career.title}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: career.educationPathNames.isNotEmpty
                ? ListView(
                    children: career.educationPathNames.map((path) {
                      return ListTile(
                        leading: const Icon(Icons.school, color: primaryColor),
                        title: Text(path),
                      );
                    }).toList(),
                  )
                : const Center(child: Text("No education paths specified", style: TextStyle(color: Colors.grey))),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSheet(CareerModel career) {
    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Required Skills for ${career.title}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: career.skillNames.isNotEmpty
                ? ListView(
                    children: career.skillNames.map((skill) {
                      final skillLevel = career.skillLevels[career.skillNames.indexOf(skill)] ?? 'Intermediate';
                      return ListTile(
                        leading: const Icon(Icons.star, color: Colors.orange),
                        title: Text(skill),
                        subtitle: Text('Level: $skillLevel'),
                      );
                    }).toList(),
                  )
                : const Center(child: Text("No skills specified", style: TextStyle(color: Colors.grey))),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedStreamsSheet(CareerModel career) {
    final recommendedStreams = career.streamSelector?['recommendedStreams'] as List? ?? [];

    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recommended Streams for ${career.title}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: recommendedStreams.isNotEmpty
                ? ListView(
                    children: recommendedStreams
                        .map((stream) => ListTile(
                              leading: const Icon(Icons.trending_up_rounded, color: Colors.green),
                              title: Text(stream.toString()),
                            ))
                        .toList(),
                  )
                : const Center(child: Text("No recommended streams specified", style: TextStyle(color: Colors.grey))),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqSheet(CareerModel career) {
    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Frequently Asked Questions",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: const [
                ExpansionTile(
                  title: Text("What education is required for this career?"),
                  children: [
                    ListTile(title: Text("Typically requires a bachelor's degree in a related field, though some positions may accept equivalent experience."))
                  ],
                ),
                ExpansionTile(
                  title: Text("What is the average salary range?"),
                  children: [
                    ListTile(title: Text("Salaries vary by experience and location, but typically range from \$50,000 to \$120,000 annually."))
                  ],
                ),
                ExpansionTile(
                  title: Text("What are the growth prospects?"),
                  children: [
                    ListTile(title: Text("This field is expected to grow faster than average over the next decade with many opportunities for advancement."))
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}