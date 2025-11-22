import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aspire_edge/constants.dart';
import 'package:aspire_edge/models/feedback_model.dart';
import 'admin_feedback_detail_screen.dart';
import 'package:aspire_edge/services/feedback_service.dart';

class AdminCareerFeedbackScreen extends StatefulWidget {
  final String careerId;
  final String careerTitle;

  const AdminCareerFeedbackScreen({
    super.key,
    required this.careerId,
    required this.careerTitle,
  });

  @override
  State<AdminCareerFeedbackScreen> createState() =>
      _AdminCareerFeedbackScreenState();
}

class _AdminCareerFeedbackScreenState extends State<AdminCareerFeedbackScreen> {
  final FeedbackService _feedbackService = FeedbackService();
  String _filterCategory = 'All';
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.careerTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: AppColors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: "Refresh",
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Banner
          _buildHeaderBanner(),

          const SizedBox(height: 8),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Statistics Section
                  _buildStatisticsSection(isSmallScreen),

                  const SizedBox(height: 20),

                  // Modern Filter Section
                  _buildModernFilterSection(),

                  const SizedBox(height: 20),

                  // Feedback List
                  _buildFeedbackListSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            Color(0xFF6366F1),
          ],
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
      child: StreamBuilder<List<FeedbackModel>>(
        stream: _feedbackService.getCareerFeedback(widget.careerId),
        builder: (context, snapshot) {
          final feedbackList = snapshot.data ?? [];
          final totalFeedback = feedbackList.length;
          
          // Calculate average rating
          final ratedFeedback = feedbackList.where((f) => f.rating > 0).toList();
          final averageRating = ratedFeedback.isEmpty
              ? 0.0
              : ratedFeedback.map((f) => f.rating).reduce((a, b) => a + b) /
                  ratedFeedback.length;

          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Feedback for ${widget.careerTitle}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "$totalFeedback total feedback • Average rating: ${averageRating.toStringAsFixed(1)}/5",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
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
                child: const Icon(
                  Icons.work_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatisticsSection(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: StreamBuilder<List<FeedbackModel>>(
        stream: _feedbackService.getCareerFeedback(widget.careerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingStats();
          }
          if (snapshot.hasError) {
            return _buildErrorStats(snapshot.error.toString());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyStats();
          }
          return _buildStatsContent(snapshot.data!, isSmallScreen);
        },
      ),
    );
  }

  Widget _buildStatsContent(List<FeedbackModel> feedbackList, bool isSmallScreen) {
    // Calculate counts for each category
    final positiveCount =
        feedbackList.where((f) => f.category == 'positive feedback').length;
    final negativeCount =
        feedbackList.where((f) => f.category == 'negative feedback').length;
    final bugCount =
        feedbackList.where((f) => f.category == 'bug report').length;
    final suggestionCount =
        feedbackList.where((f) => f.category == 'suggestion').length;
    final totalCount = feedbackList.length;

    // Calculate average rating
    final ratedFeedback = feedbackList.where((f) => f.rating > 0).toList();
    final averageRating = ratedFeedback.isEmpty
        ? 0.0
        : ratedFeedback.map((f) => f.rating).reduce((a, b) => a + b) /
            ratedFeedback.length;

    return Column(
      children: [
        // Header
        const Row(
          children: [
            Text(
              "Feedback Overview",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),

        // Main Stats Row
        Row(
          children: [
            _buildStatCard(
              'Total Feedback',
              totalCount.toString(),
              Icons.feedback_rounded,
              AppColors.primary,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              'Avg Rating',
              averageRating.toStringAsFixed(1),
              Icons.star_rounded,
              Colors.amber,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Category Breakdown Header
        const Row(
          children: [
            Text(
              'Category Breakdown',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),

        // Responsive Category Breakdown
        _buildResponsiveCategoryGrid(
          bugCount: bugCount,
          suggestionCount: suggestionCount,
          positiveCount: positiveCount,
          negativeCount: negativeCount,
          isSmallScreen: isSmallScreen,
        ),
      ],
    );
  }

  Widget _buildResponsiveCategoryGrid({
    required int bugCount,
    required int suggestionCount,
    required int positiveCount,
    required int negativeCount,
    required bool isSmallScreen,
  }) {
    final categories = [
      _CategoryItem('Bug Reports', bugCount, AppColors.warning, Icons.bug_report_rounded),
      _CategoryItem('Suggestions', suggestionCount, AppColors.primary, Icons.lightbulb_rounded),
      _CategoryItem('Positive', positiveCount, AppColors.success, Icons.thumb_up_rounded),
      _CategoryItem('Negative', negativeCount, AppColors.error, Icons.thumb_down_rounded),
    ];

    if (isSmallScreen) {
      // For small screens, use a vertical list
      return Column(
        children: categories.map((category) => 
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildCategoryListItem(category),
          ),
        ).toList(),
      );
    } else {
      // For larger screens, use a grid
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3.5,
        children: categories.map((category) => 
          _buildCategoryStatItem(
            category.title, 
            category.count, 
            category.color, 
            category.icon
          ),
        ).toList(),
      );
    }
  }

  Widget _buildCategoryListItem(_CategoryItem category) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: category.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: category.color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(category.icon, color: category.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  category.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  '${category.count} feedback',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: category.color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${category.count}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.darkGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryStatItem(String title, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  '$count feedback',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_alt_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Filter by Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              const Spacer(),
              if (_filterCategory != 'All')
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _filterCategory = 'All';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Clear',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.close_rounded, color: AppColors.primary, size: 14),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildModernFilterChip('All', Icons.all_inclusive_rounded),
              _buildModernFilterChip('bug report', Icons.bug_report_rounded),
              _buildModernFilterChip('suggestion', Icons.lightbulb_rounded),
              _buildModernFilterChip('positive feedback', Icons.thumb_up_rounded),
              _buildModernFilterChip('negative feedback', Icons.thumb_down_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernFilterChip(String category, IconData icon) {
    final isSelected = _filterCategory == category;
    final color = _getCategoryColor(category);
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? color : Colors.grey[100],
        boxShadow: isSelected ? [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              _filterCategory = category;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : color,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatCategory(category),
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackListSection() {
    return StreamBuilder<List<FeedbackModel>>(
      stream: _feedbackService.getCareerFeedback(widget.careerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingList();
        }
        if (snapshot.hasError) {
          return _buildErrorList(snapshot.error.toString());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyList();
        }

        final filteredFeedback = _applyFilters(snapshot.data!);
        if (filteredFeedback.isEmpty) {
          return _buildNoMatches();
        }

        return Column(
          children: [
            // List Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "All Feedback",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${filteredFeedback.length} items",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Feedback List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredFeedback.length,
              itemBuilder: (context, index) {
                return _buildFeedbackListItem(filteredFeedback[index]);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeedbackListItem(FeedbackModel feedback) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToDetail(feedback),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with user info and category
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feedback.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (feedback.email.isNotEmpty)
                            const SizedBox(height: 4),
                          if (feedback.email.isNotEmpty)
                            Text(
                              feedback.email,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.darkGrey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(feedback.category).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getCategoryIcon(feedback.category),
                            color: _getCategoryColor(feedback.category),
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatCategory(feedback.category),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getCategoryColor(feedback.category),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Message preview
                Text(
                  feedback.message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.black,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // Footer with rating, date, and view button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          if (feedback.rating > 0) _buildRatingStars(feedback.rating),
                          if (feedback.rating > 0) const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _formatDate(feedback.date),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.darkGrey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View Details',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }

  List<FeedbackModel> _applyFilters(List<FeedbackModel> feedbackList) {
    return feedbackList.where((feedback) {
      bool categoryMatch = _filterCategory == 'All' || feedback.category == _filterCategory;
      return categoryMatch;
    }).toList();
  }

  void _navigateToDetail(FeedbackModel feedback) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminFeedbackDetailScreen(feedback: feedback),
      ),
    );
  }

  // Helper methods for loading states
  Widget _buildLoadingStats() {
    return Column(
      children: [
        const Row(
          children: [
            Text(
              "Feedback Overview",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildLoadingShimmer(height: 100)),
            const SizedBox(width: 12),
            Expanded(child: _buildLoadingShimmer(height: 100)),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorStats(String error) {
    return Column(
      children: [
        const Row(
          children: [
            Text(
              "Feedback Overview",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.lightGrey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              'Error loading statistics: $error',
              style: const TextStyle(color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStats() {
    return Column(
      children: [
        const Row(
          children: [
            Text(
              "Feedback Overview",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.lightGrey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            children: [
              Icon(Icons.feedback_outlined, color: AppColors.grey, size: 40),
              SizedBox(height: 8),
              Text(
                'No feedback data available',
                style: TextStyle(color: AppColors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLoadingShimmer(width: 120, height: 20),
              _buildLoadingShimmer(width: 60, height: 20),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) => _buildLoadingShimmer(height: 120),
        ),
      ],
    );
  }

  Widget _buildErrorList(String error) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Error Loading Feedback",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.darkGrey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              "Try Again",
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyList() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.feedback_outlined,
              color: AppColors.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "No Feedback Available",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "There are no feedback submissions for this career yet",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.darkGrey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMatches() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              color: AppColors.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "No Matching Feedback",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "No feedback found for \"${_formatCategory(_filterCategory)}\" category",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.darkGrey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _filterCategory = 'All';
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              "Clear Filter",
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer({double? width, double height = 60}) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'positive feedback': return AppColors.success;
      case 'negative feedback': return AppColors.error;
      case 'bug report': return AppColors.warning;
      case 'suggestion': return AppColors.primary;
      default: return AppColors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'positive feedback': return Icons.thumb_up_rounded;
      case 'negative feedback': return Icons.thumb_down_rounded;
      case 'bug report': return Icons.bug_report_rounded;
      case 'suggestion': return Icons.lightbulb_rounded;
      default: return Icons.feedback_rounded;
    }
  }

  String _formatCategory(String category) {
    return category.replaceAll('_', ' ').split(' ').map((word) {
      if (word.isEmpty) return '';
      return '${word[0].toUpperCase()}${word.substring(1)}';
    }).join(' ');
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy • HH:mm').format(date);
  }
}

class _CategoryItem {
  final String title;
  final int count;
  final Color color;
  final IconData icon;

  _CategoryItem(this.title, this.count, this.color, this.icon);
}