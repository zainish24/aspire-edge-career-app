import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aspire_edge/theme/app_theme.dart';
import 'package:aspire_edge/routes/screen_export.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  Map<String, dynamic> _stats = {
    'totalUsers': 0,
    'totalCareers': 0,
    'totalTestimonials': 0,
    'totalResources': 0,
    'totalQuizzes': 0,
    'totalReviews': 0,
    'pendingFeedback': 0,
    'pendingTestimonials': 0,
    'todayUsers': 0,
  };
  bool _isLoading = true;
  List<Map<String, dynamic>> _recentActivities = [];
  List<Map<String, dynamic>> _pendingReviews = [];
  List<Map<String, dynamic>> _pendingTestimonials = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      print('🔄 Starting to fetch dashboard data...');
      
      setState(() {
        _isLoading = true;
      });

      // Initialize counts
      int totalUsers = 0;
      int totalCareers = 0;
      int totalTestimonials = 0;
      int totalResources = 0;
      int totalQuizzes = 0;
      int totalReviews = 0;
      int pendingFeedback = 0;
      int pendingTestimonials = 0;
      int todayUsers = 0;

      // Fetch each collection separately with error handling
      try {
        final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
        totalUsers = usersSnapshot.docs.length;
        print('✅ Users: $totalUsers');
        
        // Calculate today's users
        todayUsers = usersSnapshot.docs.where((doc) {
          try {
            final date = doc['createdAt']?.toDate();
            return date != null && _isToday(date);
          } catch (e) {
            return false;
          }
        }).length;
      } catch (e) {
        print('❌ Error fetching users: $e');
      }

      try {
        final careersSnapshot = await FirebaseFirestore.instance.collection('careers').get();
        totalCareers = careersSnapshot.docs.length;
        print('✅ Careers: $totalCareers');
      } catch (e) {
        print('❌ Error fetching careers: $e');
      }

      try {
        final testimonialsSnapshot = await FirebaseFirestore.instance.collection('testimonials').get();
        totalTestimonials = testimonialsSnapshot.docs.length;
        print('✅ Testimonials: $totalTestimonials');
        
        // Get pending testimonials
        pendingTestimonials = testimonialsSnapshot.docs.where((doc) {
          try {
            final data = doc.data();
            return !data.containsKey('status') || data['status'] == 'pending';
          } catch (e) {
            return false;
          }
        }).length;

        // Get pending testimonials for display
        _pendingTestimonials = testimonialsSnapshot.docs
            .where((doc) {
              try {
                final data = doc.data();
                return !data.containsKey('status') || data['status'] == 'pending';
              } catch (e) {
                return false;
              }
            })
            .take(3)
            .map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                'userName': data['name'] ?? data['userName'] ?? 'Anonymous User',
                'message': data['testimonial'] ?? data['message'] ?? 'No testimonial provided',
                'rating': data['rating'] ?? 5,
                'time': data['createdAt']?.toDate() ?? DateTime.now(),
                'type': 'testimonial',
              };
            })
            .toList();
      } catch (e) {
        print('❌ Error fetching testimonials: $e');
      }

      try {
        final resourcesSnapshot = await FirebaseFirestore.instance.collection('resources').get();
        totalResources = resourcesSnapshot.docs.length;
        print('✅ Resources: $totalResources');
      } catch (e) {
        print('❌ Error fetching resources: $e');
      }

      try {
        final feedbackSnapshot = await FirebaseFirestore.instance.collection('feedback').get();
        print('✅ Feedback docs found: ${feedbackSnapshot.docs.length}');
        
        // Get total reviews (all feedback)
        totalReviews = feedbackSnapshot.docs.length;
        
        // Get pending feedback
        pendingFeedback = feedbackSnapshot.docs.where((doc) {
          try {
            final data = doc.data();
            return !data.containsKey('status') || data['status'] == 'pending';
          } catch (e) {
            return false;
          }
        }).length;

        // Get pending reviews for display
        _pendingReviews = feedbackSnapshot.docs
            .where((doc) {
              try {
                final data = doc.data();
                return !data.containsKey('status') || data['status'] == 'pending';
              } catch (e) {
                return false;
              }
            })
            .take(3)
            .map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                'userName': data['userName'] ?? data['name'] ?? 'Anonymous User',
                'message': data['message'] ?? data['feedback'] ?? 'No message provided',
                'rating': data['rating'] ?? 5,
                'time': data['createdAt']?.toDate() ?? DateTime.now(),
                'type': 'feedback',
              };
            })
            .toList();
            
        print('✅ Total Reviews: $totalReviews');
        print('✅ Pending feedback: $pendingFeedback');
      } catch (e) {
        print('❌ Error fetching feedback: $e');
      }

      try {
        final quizzesSnapshot = await FirebaseFirestore.instance.collection('quizzes').get();
        totalQuizzes = quizzesSnapshot.docs.length;
        print('✅ Quizzes: $totalQuizzes');
      } catch (e) {
        print('❌ Error fetching quizzes: $e');
      }

      // Update state with all data
      setState(() {
        _stats = {
          'totalUsers': totalUsers,
          'totalCareers': totalCareers,
          'totalTestimonials': totalTestimonials,
          'totalResources': totalResources,
          'totalQuizzes': totalQuizzes,
          'totalReviews': totalReviews,
          'pendingFeedback': pendingFeedback,
          'pendingTestimonials': pendingTestimonials,
          'todayUsers': todayUsers,
        };
        _isLoading = false;
      });

      print('🎉 FINAL STATISTICS:');
      print('👥 Total Users: $totalUsers');
      print('💼 Total Careers: $totalCareers');
      print('⭐ Total Testimonials: $totalTestimonials');
      print('📚 Total Resources: $totalResources');
      print('❓ Total Quizzes: $totalQuizzes');
      print('🌟 Total Reviews: $totalReviews');
      print('📝 Pending Feedback: $pendingFeedback');
      print('🌟 Pending Testimonials: $pendingTestimonials');
      print('📅 Today Users: $todayUsers');

      // Fetch recent activities
      _fetchRecentActivities();

    } catch (e) {
      print('💥 CRITICAL ERROR in dashboard: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchRecentActivities() async {
    try {
      final users = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();

      List<Map<String, dynamic>> activities = [];

      for (var doc in users.docs) {
        activities.add({
          'type': 'user',
          'title': 'New User Registration',
          'subtitle': '${doc['name'] ?? 'Unknown User'} joined the platform',
          'time': doc['createdAt']?.toDate() ?? DateTime.now(),
          'icon': Icons.person_add_rounded,
          'color': AppColors.success,
        });
      }

      setState(() {
        _recentActivities = activities;
      });
    } catch (e) {
      print('Error fetching activities: $e');
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${(difference.inDays / 7).floor()}w ago';
  }

  // Responsive breakpoints
  bool get isDesktop => MediaQuery.of(context).size.width >= 1200;
  bool get isTablet => MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1200;
  bool get isMobile => MediaQuery.of(context).size.width < 768;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: _isLoading ? _buildLoadingState() : _buildContent(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16),
          Text(
            'Loading Dashboard Data...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.darkGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          const SizedBox(height: 24),
          _buildStatsOverview(),
          const SizedBox(height: 24),
          _buildQuickActions(),
          const SizedBox(height: 24),
          _buildPendingItemsSection(),
          const SizedBox(height: 24),
          _buildRecentActivitySection(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back, Admin! 👋",
                  style: TextStyle(
                    color: AppColors.darkGrey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Dashboard Overview",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
                color: AppColors.primary.withOpacity(0.1),
              ),
              child: Icon(Icons.admin_panel_settings_rounded, color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
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
                      "Platform Performance",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${_stats['todayUsers']} new users today • ${_stats['pendingFeedback']} reviews pending • ${_stats['pendingTestimonials']} testimonials pending",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchDashboardData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: const Text(
                        "Refresh Data",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              const Icon(
                Icons.analytics_rounded,
                color: Colors.white,
                size: 60,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsOverview() {
    final stats = [
      {
        'title': 'Total Users',
        'value': _stats['totalUsers'],
        'icon': Icons.people_alt_rounded,
        'color': AppColors.primary,
      },
      {
        'title': 'Career Listings',
        'value': _stats['totalCareers'],
        'icon': Icons.work_rounded,
        'color': AppColors.secondary,
      },
      {
        'title': 'Success Stories',
        'value': _stats['totalTestimonials'],
        'icon': Icons.rate_review_rounded,
        'color': AppColors.success,
      },
      {
        'title': 'Resources',
        'value': _stats['totalResources'],
        'icon': Icons.library_books_rounded,
        'color': AppColors.info,
      },
      {
        'title': 'Quizzes',
        'value': _stats['totalQuizzes'],
        'icon': Icons.quiz_rounded,
        'color': AppColors.warning,
      },
      {
        'title': 'Reviews',
        'value': _stats['totalReviews'],
        'icon': Icons.reviews_rounded,
        'color': AppColors.info,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Platform Statistics",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.black,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 6 : (isTablet ? 3 : 2),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: isDesktop ? 1.1 : 1.2,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) => _buildStatCard(stats[index]),
        ),
      ],
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: stat['color'].withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(stat['icon'], color: stat['color'], size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              '${stat['value']}',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.black,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              stat['title'] as String,
              style: TextStyle(
                color: AppColors.darkGrey,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': Icons.add_chart_rounded,
        'title': "Add Career",
        'subtitle': "Create new career listing",
        'color': AppColors.primary,
        'route': adminCareerListScreenRoute,
      },
      {
        'icon': Icons.quiz_rounded,
        'title': "Manage Quizzes",
        'subtitle': "Edit quiz questions",
        'color': AppColors.secondary,
        'route': adminQuizListScreenRoute,
      },
      {
        'icon': Icons.library_add_rounded,
        'title': "Add Resource",
        'subtitle': "Upload learning material",
        'color': AppColors.info,
        'route': adminResourceListScreenRoute,
      },
      {
        'icon': Icons.feedback_rounded,
        'title': "Review Feedback",
        'subtitle': "${_stats['pendingFeedback']} pending",
        'color': AppColors.warning,
        'route': adminFeedbackListScreenRoute,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Actions",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.black,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 2),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isDesktop ? 1.2 : 1.4,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) => _buildActionButton(
            icon: actions[index]['icon'] as IconData,
            title: actions[index]['title'] as String,
            subtitle: actions[index]['subtitle'] as String,
            color: actions[index]['color'] as Color,
            onTap: () => Navigator.pushNamed(context, actions[index]['route'] as String),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.darkGrey,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Pending Approvals",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.black,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 16),
        if (isDesktop) _buildDesktopPendingLayout(),
        if (isTablet) _buildTabletPendingLayout(),
        if (isMobile) _buildMobilePendingLayout(),
      ],
    );
  }

  Widget _buildDesktopPendingLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildPendingCard(
            title: "Pending Reviews",
            count: _stats['pendingFeedback'],
            items: _pendingReviews,
            color: AppColors.warning,
            icon: Icons.feedback_rounded,
            onViewAll: () => Navigator.pushNamed(context, adminFeedbackListScreenRoute),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPendingCard(
            title: "Pending Testimonials",
            count: _stats['pendingTestimonials'],
            items: _pendingTestimonials,
            color: AppColors.info,
            icon: Icons.rate_review_rounded,
            onViewAll: () => Navigator.pushNamed(context, adminTestimonialListScreenRoute),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletPendingLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildPendingCard(
            title: "Pending Reviews",
            count: _stats['pendingFeedback'],
            items: _pendingReviews,
            color: AppColors.warning,
            icon: Icons.feedback_rounded,
            onViewAll: () => Navigator.pushNamed(context, adminFeedbackListScreenRoute),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPendingCard(
            title: "Pending Testimonials",
            count: _stats['pendingTestimonials'],
            items: _pendingTestimonials,
            color: AppColors.info,
            icon: Icons.rate_review_rounded,
            onViewAll: () => Navigator.pushNamed(context, adminTestimonialListScreenRoute),
          ),
        ),
      ],
    );
  }

  Widget _buildMobilePendingLayout() {
    return Column(
      children: [
        _buildPendingCard(
          title: "Pending Reviews",
          count: _stats['pendingFeedback'],
          items: _pendingReviews,
          color: AppColors.warning,
          icon: Icons.feedback_rounded,
          onViewAll: () => Navigator.pushNamed(context, adminFeedbackListScreenRoute),
        ),
        const SizedBox(height: 16),
        _buildPendingCard(
          title: "Pending Testimonials",
          count: _stats['pendingTestimonials'],
          items: _pendingTestimonials,
          color: AppColors.info,
          icon: Icons.rate_review_rounded,
          onViewAll: () => Navigator.pushNamed(context, adminTestimonialListScreenRoute),
        ),
      ],
    );
  }

  Widget _buildPendingCard({
    required String title,
    required int count,
    required List<Map<String, dynamic>> items,
    required Color color,
    required IconData icon,
    required VoidCallback onViewAll,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Items List
            if (items.isEmpty)
              _buildNoPendingItems("No pending items", icon)
            else
              Column(
                children: items.map((item) => _buildCompactReviewItem(item)).toList(),
              ),
            
            // View All Button
            if (count > 0) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onViewAll,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    "Review All ($count)",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactReviewItem(Map<String, dynamic> review) {
    final isTestimonial = review['type'] == 'testimonial';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTestimonial ? AppColors.info.withOpacity(0.2) : AppColors.warning.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isTestimonial ? AppColors.info.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isTestimonial ? Icons.rate_review_rounded : Icons.feedback_rounded,
              color: isTestimonial ? AppColors.info : AppColors.warning,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review['userName'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  review['message'],
                  style: TextStyle(
                    color: AppColors.darkGrey,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildRatingStars(review['rating']),
                    const Spacer(),
                    Text(
                      _formatTimeAgo(review['time']),
                      style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      children: List.generate(5, (index) => Icon(
        Icons.star_rounded,
        size: 14,
        color: index < rating ? AppColors.warning : Colors.grey[300],
      )),
    );
  }

  Widget _buildNoPendingItems(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.success,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            "All clear!",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.black,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: TextStyle(
              color: AppColors.darkGrey,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent Activity",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                    fontSize: 20,
                  ),
                ),
                IconButton(
                  onPressed: _fetchDashboardData,
                  icon: Icon(Icons.refresh_rounded, color: AppColors.primary),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Latest platform events and user actions",
              style: TextStyle(
                color: AppColors.darkGrey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            _recentActivities.isEmpty
                ? _buildEmptyActivityState()
                : Column(
                    children: _recentActivities
                        .map((activity) => _buildActivityItem(activity))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: activity['color'].withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(activity['icon'], color: activity['color'], size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['subtitle'],
                  style: TextStyle(
                    color: AppColors.darkGrey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatTimeAgo(activity['time']),
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyActivityState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history_toggle_off_rounded,
            color: AppColors.grey,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            "No recent activity",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.black,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Activity will appear here as users interact with the platform",
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
}