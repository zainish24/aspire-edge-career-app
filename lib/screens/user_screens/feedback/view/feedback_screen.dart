import 'package:flutter/material.dart';
import 'package:aspire_edge/models/feedback_model.dart';
import 'package:aspire_edge/routes/screen_export.dart';
import 'package:aspire_edge/services/feedback_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:aspire_edge/theme/app_theme.dart';

class UserCareerFeedbackScreen extends StatefulWidget {
  final String careerId;
  final String careerTitle;

  const UserCareerFeedbackScreen({
    super.key,
    required this.careerId,
    required this.careerTitle,
  });

  @override
  State<UserCareerFeedbackScreen> createState() =>
      _UserCareerFeedbackScreenState();
}

class _UserCareerFeedbackScreenState extends State<UserCareerFeedbackScreen> {
  final FeedbackService _feedbackService = FeedbackService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _userId = '';
  String _filterCategory = 'All';

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isVerySmallScreen = screenSize.width < 400;
    final isLargeScreen = screenSize.width > 1200;
    final isTablet = screenSize.width >= 600 && screenSize.width <= 1200;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded, 
            color: AppColors.black,
            size: isSmallScreen ? 20 : 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.careerTitle,
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.w700,
            fontSize: isSmallScreen ? 18 : (isTablet ? 20 : 22),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: Icon(
              Icons.refresh_rounded, 
              color: AppColors.primary,
              size: isSmallScreen ? 20 : 24,
            ),
            tooltip: "Refresh",
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Banner
            _buildHeaderBanner(isSmallScreen, isTablet, isLargeScreen),

            const SizedBox(height: 8),

            // Main Content
            Expanded(
              child: Container(
                constraints: isLargeScreen 
                  ? BoxConstraints(maxWidth: 1200)
                  : null,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: _getHorizontalPadding(isVerySmallScreen, isSmallScreen, isTablet, isLargeScreen),
                  ),
                  child: Column(
                    children: [
                      // Add Feedback Button
                      _buildAddFeedbackButton(isSmallScreen, isTablet, isLargeScreen),
                      
                      SizedBox(height: isSmallScreen ? 16 : 20),

                      // Statistics Section
                      _buildStatisticsSection(isSmallScreen, isVerySmallScreen, isTablet, isLargeScreen),

                      SizedBox(height: isSmallScreen ? 20 : 24),

                      // Modern Filter Section
                      _buildModernFilterSection(isSmallScreen, isVerySmallScreen, isTablet, isLargeScreen),

                      SizedBox(height: isSmallScreen ? 20 : 24),

                      // Feedback List
                      _buildFeedbackListSection(isSmallScreen, isTablet, isLargeScreen),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getHorizontalPadding(bool isVerySmallScreen, bool isSmallScreen, bool isTablet, bool isLargeScreen) {
    if (isVerySmallScreen) return 12;
    if (isSmallScreen) return 16;
    if (isTablet) return 24;
    if (isLargeScreen) return 32;
    return 16;
  }

  Widget _buildAddFeedbackButton(bool isSmallScreen, bool isTablet, bool isLargeScreen) {
    final padding = isSmallScreen ? 12.0 : (isTablet ? 16.0 : 20.0);
    final innerPadding = isSmallScreen ? 16.0 : (isTablet ? 20.0 : 24.0);
    final iconSize = isSmallScreen ? 24.0 : (isTablet ? 28.0 : 32.0);
    final fontSize = isSmallScreen ? 16.0 : (isTablet ? 18.0 : 20.0);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _navigateToAddFeedback,
                borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                child: Container(
                  padding: EdgeInsets.all(innerPadding),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        Color(0xFF6366F1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add, 
                          color: Colors.white, 
                          size: iconSize * 0.7,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 12 : 16),
                      Text(
                        "Add Feedback",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBanner(bool isSmallScreen, bool isTablet, bool isLargeScreen) {
    final margin = isSmallScreen ? 12.0 : (isTablet ? 16.0 : 20.0);
    final padding = isSmallScreen ? 16.0 : (isTablet ? 20.0 : 24.0);
    final titleSize = isSmallScreen ? 18.0 : (isTablet ? 20.0 : 24.0);
    final subtitleSize = isSmallScreen ? 12.0 : (isTablet ? 14.0 : 16.0);
    final iconSize = isSmallScreen ? 50.0 : (isTablet ? 60.0 : 70.0);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(margin),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            Color(0xFF6366F1),
          ],
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
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
                      "Community Feedback",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: titleSize,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 8 : 12),
                    Text(
                      "$totalFeedback total feedback • Average rating: ${averageRating.toStringAsFixed(1)}/5",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: subtitleSize,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: isSmallScreen ? 20 : 24),
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.feedback_rounded,
                  color: Colors.white,
                  size: iconSize * 0.5,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatisticsSection(bool isSmallScreen, bool isVerySmallScreen, bool isTablet, bool isLargeScreen) {
    final padding = isSmallScreen ? 12.0 : (isTablet ? 16.0 : 20.0);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
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
            return _buildLoadingStats(isSmallScreen, isTablet);
          }
          if (snapshot.hasError) {
            return _buildErrorStats(snapshot.error.toString(), isSmallScreen, isTablet);
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyStats(isSmallScreen, isTablet);
          }
          return _buildStatsContent(snapshot.data!, isSmallScreen, isVerySmallScreen, isTablet, isLargeScreen);
        },
      ),
    );
  }

  Widget _buildStatsContent(List<FeedbackModel> feedbackList, bool isSmallScreen, bool isVerySmallScreen, bool isTablet, bool isLargeScreen) {
    final positiveCount = feedbackList.where((f) => f.category == 'positive feedback').length;
    final negativeCount = feedbackList.where((f) => f.category == 'negative feedback').length;
    final bugCount = feedbackList.where((f) => f.category == 'bug report').length;
    final suggestionCount = feedbackList.where((f) => f.category == 'suggestion').length;
    final totalCount = feedbackList.length;

    final ratedFeedback = feedbackList.where((f) => f.rating > 0).toList();
    final averageRating = ratedFeedback.isEmpty
        ? 0.0
        : ratedFeedback.map((f) => f.rating).reduce((a, b) => a + b) /
            ratedFeedback.length;

    return Column(
      children: [
        // Header
        Row(
          children: [
            Text(
              "Feedback Overview",
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : (isTablet ? 18 : 20),
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        
        SizedBox(height: isSmallScreen ? 16 : 20),

        // Main Stats Row
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Feedback',
                totalCount.toString(),
                Icons.feedback_rounded,
                AppColors.primary,
                isSmallScreen,
                isTablet,
              ),
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Expanded(
              child: _buildStatCard(
                'Avg Rating',
                averageRating.toStringAsFixed(1),
                Icons.star_rounded,
                Colors.amber,
                isSmallScreen,
                isTablet,
              ),
            ),
          ],
        ),

        SizedBox(height: isSmallScreen ? 16 : 20),

        // Category Breakdown Header
        Row(
          children: [
            Text(
              'Category Breakdown',
              style: TextStyle(
                fontSize: isSmallScreen ? 13 : (isTablet ? 14 : 15),
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
              ),
            ),
          ],
        ),
        
        SizedBox(height: isSmallScreen ? 12 : 16),

        // Responsive Category Breakdown Grid
        LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            int crossAxisCount;
            
            if (maxWidth < 400) {
              crossAxisCount = 1;
            } else if (maxWidth < 600) {
              crossAxisCount = 2;
            } else if (maxWidth < 900) {
              crossAxisCount = 2;
            } else {
              crossAxisCount = 4;
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: isSmallScreen ? 8 : 12,
                mainAxisSpacing: isSmallScreen ? 8 : 12,
                childAspectRatio: _getCategoryAspectRatio(maxWidth),
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return _buildCategoryStatItem('Bug Reports', bugCount, AppColors.warning, Icons.bug_report_rounded, isSmallScreen, isTablet);
                  case 1:
                    return _buildCategoryStatItem('Suggestions', suggestionCount, AppColors.primary, Icons.lightbulb_rounded, isSmallScreen, isTablet);
                  case 2:
                    return _buildCategoryStatItem('Positive', positiveCount, AppColors.success, Icons.thumb_up_rounded, isSmallScreen, isTablet);
                  case 3:
                    return _buildCategoryStatItem('Negative', negativeCount, AppColors.error, Icons.thumb_down_rounded, isSmallScreen, isTablet);
                  default:
                    return Container();
                }
              },
            );
          },
        ),
      ],
    );
  }

  double _getCategoryAspectRatio(double maxWidth) {
    if (maxWidth < 400) return 4.0;
    if (maxWidth < 600) return 3.5;
    if (maxWidth < 900) return 3.0;
    return 2.5;
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isSmallScreen, bool isTablet) {
    final padding = isSmallScreen ? 12.0 : (isTablet ? 16.0 : 20.0);
    final iconSize = isSmallScreen ? 32.0 : (isTablet ? 40.0 : 48.0);
    final valueSize = isSmallScreen ? 16.0 : (isTablet ? 18.0 : 20.0);
    final titleSize = isSmallScreen ? 11.0 : (isTablet ? 12.0 : 13.0);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon, 
              color: color, 
              size: iconSize * 0.5,
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            value,
            style: TextStyle(
              fontSize: valueSize,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: titleSize,
              color: AppColors.darkGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryStatItem(String title, int count, Color color, IconData icon, bool isSmallScreen, bool isTablet) {
    final padding = isSmallScreen ? 10.0 : (isTablet ? 12.0 : 14.0);
    final iconSize = isSmallScreen ? 32.0 : (isTablet ? 36.0 : 40.0);
    final titleSize = isSmallScreen ? 11.0 : (isTablet ? 12.0 : 13.0);
    final countSize = isSmallScreen ? 10.0 : (isTablet ? 11.0 : 12.0);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon, 
              color: color, 
              size: iconSize * 0.45,
            ),
          ),
          SizedBox(width: isSmallScreen ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  '$count feedback',
                  style: TextStyle(
                    fontSize: countSize,
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 6 : 8,
              vertical: isSmallScreen ? 3 : 4,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: Colors.white,
                fontSize: countSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernFilterSection(bool isSmallScreen, bool isVerySmallScreen, bool isTablet, bool isLargeScreen) {
    final padding = isSmallScreen ? 12.0 : (isTablet ? 16.0 : 20.0);
    final iconSize = isSmallScreen ? 18.0 : (isTablet ? 20.0 : 22.0);
    final titleSize = isSmallScreen ? 15.0 : (isTablet ? 16.0 : 18.0);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
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
              Icon(
                Icons.filter_alt_rounded, 
                color: AppColors.primary, 
                size: iconSize,
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Text(
                'Filter by Category',
                style: TextStyle(
                  fontSize: titleSize,
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
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 10 : 12,
                      vertical: isSmallScreen ? 5 : 6,
                    ),
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
                            fontSize: isSmallScreen ? 11 : 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 2 : 4),
                        Icon(
                          Icons.close_rounded, 
                          color: AppColors.primary, 
                          size: isSmallScreen ? 12 : 14,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          Wrap(
            spacing: isSmallScreen ? 8 : 12,
            runSpacing: isSmallScreen ? 8 : 12,
            children: [
              _buildModernFilterChip('All', Icons.all_inclusive_rounded, isSmallScreen, isTablet),
              _buildModernFilterChip('bug report', Icons.bug_report_rounded, isSmallScreen, isTablet),
              _buildModernFilterChip('suggestion', Icons.lightbulb_rounded, isSmallScreen, isTablet),
              _buildModernFilterChip('positive feedback', Icons.thumb_up_rounded, isSmallScreen, isTablet),
              _buildModernFilterChip('negative feedback', Icons.thumb_down_rounded, isSmallScreen, isTablet),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernFilterChip(String category, IconData icon, bool isSmallScreen, bool isTablet) {
    final isSelected = _filterCategory == category;
    final color = _getCategoryColor(category);
    final padding = EdgeInsets.symmetric(
      horizontal: isSmallScreen ? 12 : (isTablet ? 16 : 20),
      vertical: isSmallScreen ? 10 : (isTablet ? 12 : 14),
    );
    final iconSize = isSmallScreen ? 14.0 : (isTablet ? 16.0 : 18.0);
    final textSize = isSmallScreen ? 11.0 : (isTablet ? 12.0 : 13.0);
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
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
          borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
          onTap: () {
            setState(() {
              _filterCategory = category;
            });
          },
          child: Container(
            padding: padding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : color,
                  size: iconSize,
                ),
                SizedBox(width: isSmallScreen ? 6 : 8),
                Text(
                  _formatCategory(category),
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.black,
                    fontSize: textSize,
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

  Widget _buildFeedbackListSection(bool isSmallScreen, bool isTablet, bool isLargeScreen) {
    return StreamBuilder<List<FeedbackModel>>(
      stream: _feedbackService.getCareerFeedback(widget.careerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingList(isSmallScreen, isTablet);
        }
        if (snapshot.hasError) {
          return _buildErrorList(snapshot.error.toString(), isSmallScreen, isTablet);
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyList(isSmallScreen, isTablet);
        }

        final filteredFeedback = _applyFilters(snapshot.data!);
        if (filteredFeedback.isEmpty) {
          return _buildNoMatches(isSmallScreen, isTablet);
        }

        return Column(
          children: [
            // List Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 4 : 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Community Feedback",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : (isTablet ? 18 : 20),
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 10 : 12,
                      vertical: isSmallScreen ? 5 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${filteredFeedback.length} items",
                      style: TextStyle(
                        fontSize: isSmallScreen ? 11 : 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: isSmallScreen ? 16 : 20),

            // Feedback List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredFeedback.length,
              itemBuilder: (context, index) {
                return _buildFeedbackListItem(filteredFeedback[index], isSmallScreen, isTablet, isLargeScreen);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeedbackListItem(FeedbackModel feedback, bool isSmallScreen, bool isTablet, bool isLargeScreen) {
    final isCurrentUser = feedback.userId == _userId;
    final padding = isSmallScreen ? 12.0 : (isTablet ? 16.0 : 20.0);
    final avatarSize = isSmallScreen ? 36.0 : (isTablet ? 40.0 : 44.0);
    final nameSize = isSmallScreen ? 15.0 : (isTablet ? 16.0 : 17.0);
    final dateSize = isSmallScreen ? 11.0 : (isTablet ? 12.0 : 13.0);
    final messageSize = isSmallScreen ? 13.0 : (isTablet ? 14.0 : 15.0);

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
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
          borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
          onTap: isCurrentUser ? () => _navigateToEditFeedback(feedback) : null,
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with user info and category
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          // User avatar
                          Container(
                            width: avatarSize,
                            height: avatarSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.7),
                                  AppColors.primary,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              backgroundImage: const NetworkImage(
                                "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150"
                              ),
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 8 : 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  feedback.name,
                                  style: TextStyle(
                                    fontSize: nameSize,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: isSmallScreen ? 4 : 6),
                                Text(
                                  _formatDate(feedback.date),
                                  style: TextStyle(
                                    fontSize: dateSize,
                                    color: AppColors.darkGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 10 : 12,
                        vertical: isSmallScreen ? 5 : 6,
                      ),
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
                            size: isSmallScreen ? 12 : 14,
                          ),
                          SizedBox(width: isSmallScreen ? 4 : 6),
                          Text(
                            _formatCategory(feedback.category),
                            style: TextStyle(
                              fontSize: isSmallScreen ? 11 : 12,
                              color: _getCategoryColor(feedback.category),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: isSmallScreen ? 12 : 16),

                // Message preview
                Text(
                  feedback.message,
                  style: TextStyle(
                    fontSize: messageSize,
                    color: AppColors.black,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: isSmallScreen ? 12 : 16),

                // Footer with rating, date, and actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          if (feedback.rating > 0) _buildRatingStars(feedback.rating, isSmallScreen, isTablet),
                          if (feedback.rating > 0) SizedBox(width: isSmallScreen ? 6 : 8),
                          if (feedback.updatedAt != null)
                            Text(
                              "Edited • ${_formatDate(feedback.updatedAt!)}",
                              style: TextStyle(
                                fontSize: isSmallScreen ? 10 : 11,
                                color: AppColors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (isCurrentUser) _buildUserActions(feedback, isSmallScreen, isTablet),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserActions(FeedbackModel feedback, bool isSmallScreen, bool isTablet) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded, 
        color: Colors.grey.shade500, 
        size: isSmallScreen ? 18 : (isTablet ? 20 : 22),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
      ),
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(
                Icons.edit_rounded, 
                color: AppColors.primary, 
                size: isSmallScreen ? 16 : 18,
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Text(
                'Edit', 
                style: TextStyle(fontSize: isSmallScreen ? 12 : 13),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete_rounded, 
                color: Colors.red, 
                size: isSmallScreen ? 16 : 18,
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Text(
                'Delete', 
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 13, 
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'edit') {
          _navigateToEditFeedback(feedback);
        } else if (value == 'delete') {
          _showDeleteConfirmation(feedback, isSmallScreen, isTablet);
        }
      },
    );
  }

  Widget _buildRatingStars(int rating, bool isSmallScreen, bool isTablet) {
    final starSize = isSmallScreen ? 14.0 : (isTablet ? 16.0 : 18.0);
    
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          color: Colors.amber,
          size: starSize,
        );
      }),
    );
  }

  // Loading, Error, and Empty State Widgets with responsive improvements
  Widget _buildLoadingStats(bool isSmallScreen, bool isTablet) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              "Feedback Overview",
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : (isTablet ? 18 : 20),
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: isSmallScreen ? 16 : 20),
        Row(
          children: [
            Expanded(child: _buildLoadingShimmer(height: isSmallScreen ? 80 : (isTablet ? 100 : 120))),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Expanded(child: _buildLoadingShimmer(height: isSmallScreen ? 80 : (isTablet ? 100 : 120))),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorStats(String error, bool isSmallScreen, bool isTablet) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              "Feedback Overview",
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : (isTablet ? 18 : 20),
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: isSmallScreen ? 16 : 20),
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 16 : (isTablet ? 20 : 24)),
          decoration: BoxDecoration(
            color: AppColors.lightGrey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
          ),
          child: Center(
            child: Text(
              'Error loading statistics: $error',
              style: TextStyle(
                color: AppColors.grey,
                fontSize: isSmallScreen ? 13 : 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStats(bool isSmallScreen, bool isTablet) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              "Feedback Overview",
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : (isTablet ? 18 : 20),
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: isSmallScreen ? 16 : 20),
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 16 : (isTablet ? 20 : 24)),
          decoration: BoxDecoration(
            color: AppColors.lightGrey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
          ),
          child: Column(
            children: [
              Icon(
                Icons.feedback_outlined, 
                color: AppColors.grey, 
                size: isSmallScreen ? 32 : (isTablet ? 40 : 48),
              ),
              SizedBox(height: isSmallScreen ? 8 : 12),
              Text(
                'No feedback data available',
                style: TextStyle(
                  color: AppColors.grey,
                  fontSize: isSmallScreen ? 13 : 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingList(bool isSmallScreen, bool isTablet) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 4 : 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLoadingShimmer(
                width: isSmallScreen ? 100 : (isTablet ? 120 : 140), 
                height: isSmallScreen ? 18 : (isTablet ? 20 : 22),
              ),
              _buildLoadingShimmer(
                width: isSmallScreen ? 50 : (isTablet ? 60 : 70), 
                height: isSmallScreen ? 18 : (isTablet ? 20 : 22),
              ),
            ],
          ),
        ),
        SizedBox(height: isSmallScreen ? 16 : 20),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) => _buildLoadingShimmer(
            height: isSmallScreen ? 100 : (isTablet ? 120 : 140),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorList(String error, bool isSmallScreen, bool isTablet) {
    final iconSize = isSmallScreen ? 60.0 : (isTablet ? 80.0 : 100.0);
    final titleSize = isSmallScreen ? 16.0 : (isTablet ? 18.0 : 20.0);
    final textSize = isSmallScreen ? 13.0 : (isTablet ? 14.0 : 15.0);
    final buttonPadding = isSmallScreen ? 20.0 : (isTablet ? 24.0 : 28.0);

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 24 : (isTablet ? 40 : 48)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: iconSize * 0.5,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          Text(
            "Error Loading Feedback",
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.darkGrey,
              fontSize: textSize,
            ),
          ),
          SizedBox(height: isSmallScreen ? 20 : 24),
          ElevatedButton(
            onPressed: () {
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: buttonPadding,
                vertical: isSmallScreen ? 10 : 12,
              ),
            ),
            child: Text(
              "Try Again",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyList(bool isSmallScreen, bool isTablet) {
    final iconSize = isSmallScreen ? 60.0 : (isTablet ? 80.0 : 100.0);
    final titleSize = isSmallScreen ? 16.0 : (isTablet ? 18.0 : 20.0);
    final textSize = isSmallScreen ? 13.0 : (isTablet ? 14.0 : 15.0);
    final buttonPadding = isSmallScreen ? 20.0 : (isTablet ? 24.0 : 28.0);

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 24 : (isTablet ? 40 : 48)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.feedback_outlined,
              color: AppColors.primary,
              size: iconSize * 0.5,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          Text(
            "No Feedback Available",
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Text(
            "There are no feedback submissions for this career yet",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.darkGrey,
              fontSize: textSize,
            ),
          ),
          SizedBox(height: isSmallScreen ? 20 : 24),
          ElevatedButton(
            onPressed: _navigateToAddFeedback,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: buttonPadding,
                vertical: isSmallScreen ? 10 : 12,
              ),
            ),
            child: Text(
              "Add First Feedback",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMatches(bool isSmallScreen, bool isTablet) {
    final iconSize = isSmallScreen ? 60.0 : (isTablet ? 80.0 : 100.0);
    final titleSize = isSmallScreen ? 16.0 : (isTablet ? 18.0 : 20.0);
    final textSize = isSmallScreen ? 13.0 : (isTablet ? 14.0 : 15.0);
    final buttonPadding = isSmallScreen ? 20.0 : (isTablet ? 24.0 : 28.0);

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 24 : (isTablet ? 40 : 48)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              color: AppColors.primary,
              size: iconSize * 0.5,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          Text(
            "No Matching Feedback",
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Text(
            "No feedback found for \"${_formatCategory(_filterCategory)}\" category",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.darkGrey,
              fontSize: textSize,
            ),
          ),
          SizedBox(height: isSmallScreen ? 20 : 24),
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
                borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: buttonPadding,
                vertical: isSmallScreen ? 10 : 12,
              ),
            ),
            child: Text(
              "Clear Filter",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isSmallScreen ? 14 : 16,
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

  void _showDeleteConfirmation(FeedbackModel feedback, bool isSmallScreen, bool isTablet) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
          ),
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 24 : 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delete Feedback',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 16 : 20),
                Text(
                  'Are you sure you want to delete your feedback? This action cannot be undone.',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 15,
                    color: AppColors.grey,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 24 : 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.darkGrey,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 16 : 20,
                          vertical: isSmallScreen ? 10 : 12,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(fontSize: isSmallScreen ? 14 : 15),
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 8 : 12),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        try {
                          await _feedbackService.deleteFeedback(feedback.feedbackId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Feedback deleted successfully'),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error deleting feedback: $e'),
                              backgroundColor: AppColors.error,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 16 : 20,
                          vertical: isSmallScreen ? 10 : 12,
                        ),
                      ),
                      child: Text(
                        'Delete',
                        style: TextStyle(fontSize: isSmallScreen ? 14 : 15),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<FeedbackModel> _applyFilters(List<FeedbackModel> feedbackList) {
    return feedbackList.where((feedback) {
      bool categoryMatch = _filterCategory == 'All' || feedback.category == _filterCategory;
      return categoryMatch;
    }).toList();
  }

  void _navigateToAddFeedback() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFeedbackScreen(
          careerId: widget.careerId,
          careerTitle: widget.careerTitle,
        ),
      ),
    );
  }

  void _navigateToEditFeedback(FeedbackModel feedback) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFeedbackScreen(
          feedback: feedback,
        ),
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