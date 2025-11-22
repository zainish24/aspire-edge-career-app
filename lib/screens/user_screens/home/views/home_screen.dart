// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aspire_edge/constants.dart' show AppFonts;
import 'package:aspire_edge/routes/route_constants.dart';
import 'package:aspire_edge/screens/user_screens/bookmark/views/bookmark_screen.dart';
import 'package:aspire_edge/screens/user_screens/career_bank/views/career_bank_screen.dart';
import 'package:aspire_edge/screens/user_screens/community/views/community_page.dart';
import 'package:aspire_edge/screens/user_screens/resource/views/resource_screen.dart';
import 'package:aspire_edge/screens/user_screens/testimonials/views/user_testimonial_screen.dart';
import 'package:aspire_edge/models/user_model.dart';
import 'package:aspire_edge/services/career_service.dart';
import 'package:aspire_edge/services/resource_service.dart';
import 'package:aspire_edge/services/testimonial_service.dart';
import 'package:aspire_edge/theme/app_theme.dart';
import 'package:aspire_edge/models/career_model.dart';
import 'package:aspire_edge/models/resource_model.dart';
import 'package:aspire_edge/models/testimonial_model.dart';

// Enhanced Responsive Helper Class
class ResponsiveUtils {
  static const double _mobileBreakpoint = 600;
  static const double _tabletBreakpoint = 900;
  static const double _desktopBreakpoint = 1200;
  static const double _largeDesktopBreakpoint = 1600;

  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < _mobileBreakpoint) return ScreenType.mobile;
    if (width < _tabletBreakpoint) return ScreenType.tablet;
    if (width < _desktopBreakpoint) return ScreenType.desktop;
    if (width < _largeDesktopBreakpoint) return ScreenType.largeDesktop;
    return ScreenType.extraLarge;
  }

  static double getResponsiveValue({
    required BuildContext context,
    required double mobile,
    double? tablet,
    double? desktop,
    double? largeDesktop,
    double? extraLarge,
  }) {
    final screenType = getScreenType(context);

    switch (screenType) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet ?? mobile * 1.2;
      case ScreenType.desktop:
        return desktop ?? mobile * 1.5;
      case ScreenType.largeDesktop:
        return largeDesktop ?? mobile * 1.8;
      case ScreenType.extraLarge:
        return extraLarge ?? mobile * 2.0;
    }
  }

  static int getGridCrossAxisCount(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return 2;
      case ScreenType.tablet:
        return 3;
      case ScreenType.desktop:
        return 4;
      case ScreenType.largeDesktop:
        return 5;
      case ScreenType.extraLarge:
        return 6;
    }
  }

  static double getBannerHeight(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return 280;
      case ScreenType.tablet:
        return 320;
      case ScreenType.desktop:
        return 380;
      case ScreenType.largeDesktop:
        return 440;
      case ScreenType.extraLarge:
        return 500;
    }
  }

  static EdgeInsets getSectionPadding(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 24);
      case ScreenType.tablet:
        return const EdgeInsets.symmetric(horizontal: 40, vertical: 32);
      case ScreenType.desktop:
        return const EdgeInsets.symmetric(horizontal: 60, vertical: 40);
      case ScreenType.largeDesktop:
        return const EdgeInsets.symmetric(horizontal: 80, vertical: 48);
      case ScreenType.extraLarge:
        return const EdgeInsets.symmetric(horizontal: 100, vertical: 56);
    }
  }

  static double getSectionSpacing(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return 24;
      case ScreenType.tablet:
        return 32;
      case ScreenType.desktop:
        return 40;
      case ScreenType.largeDesktop:
        return 48;
      case ScreenType.extraLarge:
        return 56;
    }
  }

  static double getChildAspectRatio(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return 1.1;
      case ScreenType.tablet:
        return 1.0;
      case ScreenType.desktop:
        return 0.9;
      case ScreenType.largeDesktop:
        return 0.85;
      case ScreenType.extraLarge:
        return 0.8;
    }
  }
}

enum ScreenType { mobile, tablet, desktop, largeDesktop, extraLarge }

// Helper class for card colors
class CardColors {
  final List<Color> backgroundGradient;
  final Color iconBackground;
  final Color iconColor;
  final Color textColor;
  final Color shadowColor;

  CardColors({
    required this.backgroundGradient,
    required this.iconBackground,
    required this.iconColor,
    required this.textColor,
    required this.shadowColor,
  });
}

// Banner Components
class CareerBannerStyle1 extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color backgroundColor;

  const CareerBannerStyle1({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.backgroundColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsiveValue(
      context: context,
      mobile: 16,
      tablet: 20,
      desktop: 24,
      largeDesktop: 28,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
        padding: EdgeInsets.all(padding * 1.5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundColor.withOpacity(0.9),
              backgroundColor.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.3),
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
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveValue(
                        context: context,
                        mobile: 20,
                        tablet: 22,
                        desktop: 24,
                        largeDesktop: 26,
                      ),
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveValue(
                        context: context,
                        mobile: 13,
                        tablet: 14,
                        desktop: 15,
                        largeDesktop: 16,
                      ),
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(padding),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: ResponsiveUtils.getResponsiveValue(
                  context: context,
                  mobile: 20,
                  tablet: 22,
                  desktop: 24,
                  largeDesktop: 26,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CareerBannerStyle5 extends StatelessWidget {
  final String title;
  final String subtitle;
  final String bottomText;
  final VoidCallback onTap;
  final Color backgroundColor;

  const CareerBannerStyle5({
    super.key,
    required this.title,
    required this.subtitle,
    required this.bottomText,
    required this.onTap,
    this.backgroundColor = AppColors.secondary,
  });

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsiveValue(
      context: context,
      mobile: 16,
      tablet: 20,
      desktop: 24,
      largeDesktop: 28,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
        padding: EdgeInsets.all(padding * 1.5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              backgroundColor,
              Color.alphaBlend(
                  backgroundColor.withOpacity(0.8), Colors.black12),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.4),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveValue(
                  context: context,
                  mobile: 22,
                  tablet: 24,
                  desktop: 26,
                  largeDesktop: 28,
                ),
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveValue(
                  context: context,
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                  largeDesktop: 17,
                ),
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: padding,
                vertical: padding * 0.5,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                bottomText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveUtils.getResponsiveValue(
                    context: context,
                    mobile: 11,
                    tablet: 12,
                    desktop: 13,
                    largeDesktop: 14,
                  ),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  UserModel? _currentUser;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<Offset> _logoSlideAnimation;
  int _currentBannerIndex = 0;
  final PageController _bannerController = PageController();
  final ScrollController _scrollController = ScrollController();

  // Services
  final CareerService _careerService = CareerService();
  final ResourceService _resourceService = ResourceService();
  final TestimonialService _testimonialService = TestimonialService();

  // Dynamic data streams
  late Stream<List<CareerModel>> _featuredCareersStream;
  late Stream<List<ResourceModel>> _popularResourcesStream;
  late Stream<List<Testimonial>> _successStoriesStream;

  // Dynamic banner content
  List<Map<String, dynamic>> _bannerContent = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeStreams();
    _fetchUserData();
    _initializeBannerContent();
    _startBannerAutoScroll();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  void _initializeStreams() {
    _featuredCareersStream = _careerService.getAllCareersStream().map(
        (careers) => careers.take(_getItemCountBasedOnScreenSize()).toList());

    _popularResourcesStream = _resourceService.getResourcesStream().map(
        (resources) =>
            resources.take(_getItemCountBasedOnScreenSize()).toList());

    _successStoriesStream = _testimonialService.getTestimonials().map(
        (testimonials) =>
            testimonials.take(_getItemCountBasedOnScreenSize()).toList());
  }

  void _initializeBannerContent() {
    _bannerContent = [
      {
        'title': "Discover Your Career Path",
        'subtitle':
            "Take our advanced assessment to find careers that match your skills and interests",
        'icon': Icons.auto_graph_rounded,
        'gradient': [AppColors.primaryLight, AppColors.primary],
        'image':
            'https://images.unsplash.com/photo-1521791136064-7986c2920216?ixlib=rb-4.0.3&auto=format&fit=crop&w=2069&q=80',
        'onTap': () => Navigator.pushNamed(context, careerBankScreenRoute),
        'badge': 'Career Quiz',
      },
      {
        'title': "Boost Your Skills",
        'subtitle': "Access premium learning resources and expert-led courses",
        'icon': Icons.school_rounded,
        'gradient': [AppColors.secondary, AppColors.secondaryDark],
        'image':
            'https://images.unsplash.com/photo-1517077304055-6e89abbf09b0?ixlib=rb-4.0.3&auto=format&fit=crop&w=2069&q=80',
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ResourcesScreen())),
        'badge': 'Resources',
      },
      {
        'title': "Join Our Community",
        'subtitle': "Connect with professionals and share experiences",
        'icon': Icons.people_alt_rounded,
        'gradient': [AppColors.success, Color(0xFF00A085)],
        'image':
            'https://images.unsplash.com/photo-1559028012-481c04fa702d?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80',
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const CommunityPage())),
        'badge': 'Community',
      },
    ];
  }

  int _getItemCountBasedOnScreenSize() {
    final screenType = ResponsiveUtils.getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return 3;
      case ScreenType.tablet:
        return 4;
      case ScreenType.desktop:
        return 6;
      case ScreenType.largeDesktop:
        return 8;
      case ScreenType.extraLarge:
        return 10;
    }
  }

  void _startBannerAutoScroll() {
    Future.delayed(const Duration(seconds: 6), () {
      if (_bannerController.hasClients && mounted) {
        if (_currentBannerIndex < _bannerContent.length - 1) {
          _currentBannerIndex++;
        } else {
          _currentBannerIndex = 0;
        }
        _bannerController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOutQuart,
        );
        _startBannerAutoScroll();
      }
    });
  }

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _currentUser = UserModel.fromDoc(userDoc);
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bannerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: _isLoading
          ? _buildEnhancedLoadingState()
          : AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: _buildDynamicContent(),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEnhancedLoadingState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.05),
            AppColors.lightBackground,
          ],
        ),
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SlideTransition(
                  position: _logoSlideAnimation,
                  child: ScaleTransition(
                    scale: _logoScaleAnimation,
                    child: SizedBox(
                      width: 300,
                      height: 300,
                      child: Image.asset(
                        'assets/logo/aspire_edge.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Text with fade animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        'Aspire Edge',
                        style: TextStyle(
                          fontSize: 32,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading Aspire Edge Dashboard...',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.darkGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: 280,
                        child: LinearProgressIndicator(
                          backgroundColor: AppColors.lightGrey,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.primary),
                          borderRadius: BorderRadius.circular(12),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDynamicContent() {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Fixed App Bar with Logo
        SliverToBoxAdapter(
          child: _buildFixedAppBar(),
        ),

        // Main Content
        SliverList(
          delegate: SliverChildListDelegate([
            SizedBox(height: ResponsiveUtils.getSectionSpacing(context) * 0.5),
            _buildWelcomeSection(),
            SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),

            // Enhanced Banner Section with Library-style banners
            _buildBannerSection(),
            SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),

            // Library-style Banner 1
            CareerBannerStyle1(
              title: "Discover Your\nCareer Potential",
              subtitle:
                  "Take our advanced career assessment and find your perfect path",
              onTap: () => Navigator.pushNamed(context, careerBankScreenRoute),
              backgroundColor: AppColors.primary,
            ),
            SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),

            _buildQuickActionsSection(),
            SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),

            // Library-style Banner 2
            CareerBannerStyle5(
              title: "Master New\nSkills",
              subtitle: "Access premium resources and expert-led courses",
              bottomText: "LEARNING RESOURCES",
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ResourcesScreen())),
              backgroundColor: AppColors.primary,
            ),
            SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),

            _buildFeaturedCareersSection(),
            SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),

            _buildPopularResourcesSection(),
            SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),

            // Library-style Banner 3
            CareerBannerStyle1(
              title: "Join Our Career\nCommunity",
              subtitle: "Connect with professionals and share experiences",
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CommunityPage())),
              backgroundColor: AppColors.primary,
            ),
            SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),

            _buildSuccessStoriesSection(),
            SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),

            _buildCommunityHighlightsSection(),
            SizedBox(height: ResponsiveUtils.getSectionSpacing(context) * 2),
          ]),
        ),
      ],
    );
  }

  Widget _buildFixedAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      height: 76,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo - Perfect mobile size
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/logo/aspire_edge.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Search Icon - Perfectly matched
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, careerBankScreenRoute);
              },
              icon: Icon(
                Icons.search_rounded,
                color: AppColors.darkGrey,
                size: 24,
              ),
              padding: EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool badge = false,
    int badgeCount = 0,
  }) {
    final padding = ResponsiveUtils.getResponsiveValue(
      context: context,
      mobile: 10,
      tablet: 12,
      desktop: 14,
      largeDesktop: 16,
    );

    final iconSize = ResponsiveUtils.getResponsiveValue(
      context: context,
      mobile: 18,
      tablet: 20,
      desktop: 22,
      largeDesktop: 24,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Icon(
              icon,
              color: AppColors.darkGrey,
              size: iconSize,
            ),
            if (badge)
              Positioned(
                top: padding * 0.6,
                right: padding * 0.6,
                child: Container(
                  width: iconSize * 0.8,
                  height: iconSize * 0.8,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      badgeCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: iconSize * 0.4,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final sectionPadding = ResponsiveUtils.getSectionPadding(context);

    return Container(
      margin: sectionPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: sectionPadding.vertical * 0.5),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 600;

              if (isCompact) {
                return _buildCompactWelcomeSection();
              } else {
                return _buildExpandedWelcomeSection();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompactWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Hello, ",
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveValue(
                    context: context,
                    mobile: 24,
                    tablet: 28,
                    desktop: 32,
                    largeDesktop: 36,
                  ),
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                  height: 1.1,
                  letterSpacing: -0.8,
                ),
              ),
              TextSpan(
                text: _currentUser?.name.split(' ').first ?? "Career Explorer",
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveValue(
                    context: context,
                    mobile: 24,
                    tablet: 28,
                    desktop: 32,
                    largeDesktop: 36,
                  ),
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  height: 1.1,
                  letterSpacing: -0.8,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: ResponsiveUtils.getSectionSpacing(context) * 0.5),
        _buildUserAvatar(),
        SizedBox(height: ResponsiveUtils.getSectionSpacing(context) * 0.5),
        Text(
          "Ready to explore new opportunities?",
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveValue(
              context: context,
              mobile: 16,
              tablet: 18,
              desktop: 20,
              largeDesktop: 22,
            ),
            color: AppColors.darkGrey,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
        SizedBox(height: ResponsiveUtils.getSectionSpacing(context) * 0.5),
        Text(
          "Your career journey is about to get more exciting. Discover new paths, learn essential skills, and connect with professionals who can help you grow.",
          style: TextStyle(
            color: AppColors.grey,
            fontSize: ResponsiveUtils.getResponsiveValue(
              context: context,
              mobile: 14,
              tablet: 15,
              desktop: 16,
              largeDesktop: 17,
            ),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedWelcomeSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Hello, ",
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveValue(
                          context: context,
                          mobile: 24,
                          tablet: 28,
                          desktop: 32,
                          largeDesktop: 36,
                        ),
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                        height: 1.1,
                        letterSpacing: -0.8,
                      ),
                    ),
                    TextSpan(
                      text: _currentUser?.name.split(' ').first ??
                          "Career Explorer",
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveValue(
                          context: context,
                          mobile: 24,
                          tablet: 28,
                          desktop: 32,
                          largeDesktop: 36,
                        ),
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        height: 1.1,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                  height: ResponsiveUtils.getSectionSpacing(context) * 0.5),
              Text(
                "Ready to explore new opportunities?",
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveValue(
                    context: context,
                    mobile: 16,
                    tablet: 18,
                    desktop: 20,
                    largeDesktop: 22,
                  ),
                  color: AppColors.darkGrey,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
              SizedBox(
                  height: ResponsiveUtils.getSectionSpacing(context) * 0.5),
              Text(
                "Your career journey is about to get more exciting. Discover new paths, learn essential skills, and connect with professionals who can help you grow.",
                style: TextStyle(
                  color: AppColors.grey,
                  fontSize: ResponsiveUtils.getResponsiveValue(
                    context: context,
                    mobile: 14,
                    tablet: 15,
                    desktop: 16,
                    largeDesktop: 17,
                  ),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: ResponsiveUtils.getSectionSpacing(context)),
        _buildUserAvatar(),
      ],
    );
  }

  Widget _buildUserAvatar() {
    final avatarSize = ResponsiveUtils.getResponsiveValue(
      context: context,
      mobile: 80,
      tablet: 100,
      desktop: 120,
      largeDesktop: 140,
    );

    return Stack(
      children: [
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withOpacity(0.4),
              width: ResponsiveUtils.getResponsiveValue(
                context: context,
                mobile: 4,
                tablet: 5,
                desktop: 6,
                largeDesktop: 7,
              ),
            ),
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.5),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipOval(
            child: _currentUser?.profilePic != null
                ? Image.network(
                    _currentUser!.profilePic!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.white,
                        child: Icon(
                          Icons.person_rounded,
                          color: AppColors.primary,
                          size: avatarSize * 0.4,
                        ),
                      );
                    },
                  )
                : Container(
                    color: Colors.white,
                    child: Icon(
                      Icons.person_rounded,
                      color: AppColors.primary,
                      size: avatarSize * 0.4,
                    ),
                  ),
          ),
        ),
        Positioned(
          bottom: ResponsiveUtils.getResponsiveValue(
            context: context,
            mobile: 4,
            tablet: 5,
            desktop: 6,
            largeDesktop: 7,
          ),
          right: ResponsiveUtils.getResponsiveValue(
            context: context,
            mobile: 4,
            tablet: 5,
            desktop: 6,
            largeDesktop: 7,
          ),
          child: Container(
            width: avatarSize * 0.25,
            height: avatarSize * 0.25,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: avatarSize * 0.12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerSection() {
    return SizedBox(
      height: ResponsiveUtils.getBannerHeight(context),
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _bannerController,
              onPageChanged: (index) {
                setState(() {
                  _currentBannerIndex = index;
                });
              },
              itemCount: _bannerContent.length,
              itemBuilder: (context, index) {
                final banner = _bannerContent[index];
                return _buildBannerCard(banner, index);
              },
            ),
          ),
          SizedBox(height: ResponsiveUtils.getSectionSpacing(context) * 0.5),
          _buildBannerIndicators(),
        ],
      ),
    );
  }

  Widget _buildBannerIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_bannerContent.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: _currentBannerIndex == index
              ? ResponsiveUtils.getResponsiveValue(
                  context: context,
                  mobile: 32,
                  tablet: 36,
                  desktop: 40,
                  largeDesktop: 44,
                )
              : 8,
          height: 6,
          margin: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.getResponsiveValue(
              context: context,
              mobile: 4,
              tablet: 5,
              desktop: 6,
              largeDesktop: 7,
            ),
          ),
          decoration: BoxDecoration(
            color: _currentBannerIndex == index
                ? AppColors.primary
                : AppColors.grey.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            boxShadow: _currentBannerIndex == index
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }

  Widget _buildBannerCard(Map<String, dynamic> banner, int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bannerWidth = screenWidth *
        (ResponsiveUtils.getScreenType(context) == ScreenType.mobile
            ? 0.9
            : ResponsiveUtils.getScreenType(context) == ScreenType.tablet
                ? 0.85
                : 0.8);

    final padding = ResponsiveUtils.getResponsiveValue(
      context: context,
      mobile: 20,
      tablet: 24,
      desktop: 28,
      largeDesktop: 32,
    );

    return GestureDetector(
      onTap: banner['onTap'] as VoidCallback?,
      child: Container(
        width: bannerWidth,
        margin: EdgeInsets.symmetric(horizontal: padding),
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(ResponsiveUtils.getResponsiveValue(
            context: context,
            mobile: 24,
            tablet: 28,
            desktop: 32,
            largeDesktop: 36,
          )),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(ResponsiveUtils.getResponsiveValue(
            context: context,
            mobile: 24,
            tablet: 28,
            desktop: 32,
            largeDesktop: 36,
          )),
          child: Stack(
            children: [
              // Background Image with Gradient Overlay
              Positioned.fill(
                child: Image.network(
                  banner['image'] as String,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: banner['gradient'] as List<Color>,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        (banner['gradient'] as List<Color>)[0].withOpacity(0.9),
                        (banner['gradient'] as List<Color>)[1]
                            .withOpacity(0.95),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: padding * 0.8,
                            vertical: padding * 0.4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(
                                ResponsiveUtils.getResponsiveValue(
                              context: context,
                              mobile: 16,
                              tablet: 18,
                              desktop: 20,
                              largeDesktop: 22,
                            )),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                banner['icon'] as IconData,
                                color: Colors.white,
                                size: ResponsiveUtils.getResponsiveValue(
                                  context: context,
                                  mobile: 16,
                                  tablet: 18,
                                  desktop: 20,
                                  largeDesktop: 22,
                                ),
                              ),
                              SizedBox(width: padding * 0.4),
                              Text(
                                banner['badge'] as String,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ResponsiveUtils.getResponsiveValue(
                                    context: context,
                                    mobile: 12,
                                    tablet: 13,
                                    desktop: 14,
                                    largeDesktop: 15,
                                  ),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: padding),
                        Text(
                          banner['title'] as String,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveUtils.getResponsiveValue(
                              context: context,
                              mobile: 22,
                              tablet: 26,
                              desktop: 30,
                              largeDesktop: 34,
                            ),
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: padding * 0.6),
                        Text(
                          banner['subtitle'] as String,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: ResponsiveUtils.getResponsiveValue(
                              context: context,
                              mobile: 14,
                              tablet: 16,
                              desktop: 18,
                              largeDesktop: 20,
                            ),
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    // CTA Button
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: padding * 1.2,
                            vertical: padding * 0.8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                                ResponsiveUtils.getResponsiveValue(
                              context: context,
                              mobile: 16,
                              tablet: 18,
                              desktop: 20,
                              largeDesktop: 22,
                            )),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Explore Now",
                                style: TextStyle(
                                  color: (banner['gradient'] as List<Color>)[0],
                                  fontSize: ResponsiveUtils.getResponsiveValue(
                                    context: context,
                                    mobile: 14,
                                    tablet: 15,
                                    desktop: 16,
                                    largeDesktop: 17,
                                  ),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: padding * 0.6),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: (banner['gradient'] as List<Color>)[0],
                                size: ResponsiveUtils.getResponsiveValue(
                                  context: context,
                                  mobile: 18,
                                  tablet: 20,
                                  desktop: 22,
                                  largeDesktop: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "${(index + 1).toString().padLeft(2, '0')}/${_bannerContent.length.toString().padLeft(2, '0')}",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: ResponsiveUtils.getResponsiveValue(
                              context: context,
                              mobile: 12,
                              tablet: 13,
                              desktop: 14,
                              largeDesktop: 15,
                            ),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    final quickActions = [
      {
        'title': "Career Quiz",
        'subtitle': "Find your perfect path",
        'icon': Icons.quiz_rounded,
        'color': AppColors.primary,
        'variant': 0,
        'onTap': () => Navigator.pushNamed(context, careerBankScreenRoute),
        'progress': 0.7,
      },
      {
        'title': "Career Bank",
        'subtitle': "Explore opportunities",
        'icon': Icons.work_history_rounded,
        'color': AppColors.primary,
        'variant': 1,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const CareerBankScreen())),
        'progress': null,
      },
      {
        'title': "Resources",
        'subtitle': "Learn & grow faster",
        'icon': Icons.library_books_rounded,
        'color': AppColors.primary,
        'variant': 2,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ResourcesScreen())),
        'progress': 0.4,
      },
      {
        'title': "Community",
        'subtitle': "Connect & share",
        'icon': Icons.people_alt_rounded,
        'color': AppColors.primary,
        'variant': 3,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const CommunityPage())),
        'progress': null,
      },
      {
        'title': "Success Stories",
        'subtitle': "Get inspired",
        'icon': Icons.celebration_rounded,
        'color': AppColors.primary,
        'variant': 4,
        'onTap': () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const UserTestimonialScreen())),
        'progress': 0.9,
      },
      {
        'title': "My Wishlist",
        'subtitle': "Saved opportunities",
        'icon': Icons.bookmark_added_rounded,
        'color': AppColors.primary,
        'variant': 1,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const BookmarkScreen())),
        'progress': null,
      },
    ];

    return Container(
      margin: ResponsiveUtils.getSectionPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickActionsHeaderSection(),
          SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
          _buildQuickActionsGrid(quickActions),
        ],
      ),
    );
  }

  Widget _buildQuickActionsHeaderSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveValue(
                    context: context,
                    mobile: 24,
                    tablet: 28,
                    desktop: 32,
                    largeDesktop: 36,
                  ),
                  fontWeight: FontWeight.w900,
                  color: AppColors.black,
                  letterSpacing: -0.5,
                  fontFamily: AppFonts.plusJakartaSans,
                ),
              ),
              SizedBox(
                  height: ResponsiveUtils.getSectionSpacing(context) * 0.3),
              Text(
                "Everything you need for your career journey",
                style: TextStyle(
                  color: AppColors.black60,
                  fontSize: ResponsiveUtils.getResponsiveValue(
                    context: context,
                    mobile: 14,
                    tablet: 15,
                    desktop: 16,
                    largeDesktop: 17,
                  ),
                  fontWeight: FontWeight.w500,
                  fontFamily: AppFonts.plusJakartaSans,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: ResponsiveUtils.getSectionSpacing(context) * 0.5),
      ],
    );
  }

  Widget _buildQuickActionsGrid(List<Map<String, dynamic>> quickActions) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveUtils.getGridCrossAxisCount(context),
        crossAxisSpacing: ResponsiveUtils.getSectionSpacing(context) * 0.8,
        mainAxisSpacing: ResponsiveUtils.getSectionSpacing(context) * 0.8,
        childAspectRatio: ResponsiveUtils.getChildAspectRatio(context),
      ),
      itemCount: quickActions.length,
      itemBuilder: (context, index) {
        final action = quickActions[index];
        return _buildQuickActionCard(
          title: action['title'] as String,
          subtitle: action['subtitle'] as String,
          icon: action['icon'] as IconData,
          color: action['color'] as Color,
          variant: action['variant'] as int,
          onTap: action['onTap'] as VoidCallback,
          progress: action['progress'] as double?,
        );
      },
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required int variant,
    required VoidCallback onTap,
    double? progress,
  }) {
    final cardColors = _getCardColorVariant(color, variant);
    final padding = ResponsiveUtils.getResponsiveValue(
      context: context,
      mobile: 16,
      tablet: 18,
      desktop: 20,
      largeDesktop: 22,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: cardColors.backgroundGradient,
          ),
          borderRadius:
              BorderRadius.circular(ResponsiveUtils.getResponsiveValue(
            context: context,
            mobile: 16,
            tablet: 18,
            desktop: 20,
            largeDesktop: 22,
          )),
          boxShadow: [
            BoxShadow(
              color: cardColors.shadowColor,
              blurRadius: ResponsiveUtils.getResponsiveValue(
                context: context,
                mobile: 8,
                tablet: 12,
                desktop: 16,
                largeDesktop: 20,
              ),
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            _buildCardBackgroundPattern(variant),
            Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(padding * 0.7),
                        decoration: BoxDecoration(
                          color: cardColors.iconBackground,
                          borderRadius: BorderRadius.circular(
                              ResponsiveUtils.getResponsiveValue(
                            context: context,
                            mobile: 10,
                            tablet: 12,
                            desktop: 14,
                            largeDesktop: 16,
                          )),
                        ),
                        child: Icon(
                          icon,
                          color: cardColors.iconColor,
                          size: ResponsiveUtils.getResponsiveValue(
                            context: context,
                            mobile: 20,
                            tablet: 22,
                            desktop: 24,
                            largeDesktop: 26,
                          ),
                        ),
                      ),
                      if (progress != null)
                        _buildProgressIndicator(progress, cardColors),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveValue(
                              context: context,
                              mobile: 16,
                              tablet: 17,
                              desktop: 18,
                              largeDesktop: 19,
                            ),
                            fontWeight: FontWeight.w800,
                            color: cardColors.textColor,
                            fontFamily: AppFonts.plusJakartaSans,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: padding * 0.3),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveValue(
                              context: context,
                              mobile: 12,
                              tablet: 13,
                              desktop: 14,
                              largeDesktop: 15,
                            ),
                            fontWeight: FontWeight.w500,
                            color: cardColors.textColor.withOpacity(0.8),
                            fontFamily: AppFonts.plusJakartaSans,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(double progress, CardColors colors) {
    final size = ResponsiveUtils.getResponsiveValue(
      context: context,
      mobile: 28,
      tablet: 32,
      desktop: 36,
      largeDesktop: 40,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 3,
            backgroundColor: colors.iconBackground,
            valueColor: AlwaysStoppedAnimation<Color>(colors.iconColor),
          ),
        ),
        Text(
          '${(progress * 100).toInt()}%',
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveValue(
              context: context,
              mobile: 9,
              tablet: 10,
              desktop: 11,
              largeDesktop: 12,
            ),
            fontWeight: FontWeight.w700,
            color: colors.textColor,
            fontFamily: AppFonts.plusJakartaSans,
          ),
        ),
      ],
    );
  }

  Widget _buildCardBackgroundPattern(int variant) {
    return Positioned(
      right: -ResponsiveUtils.getResponsiveValue(
        context: context,
        mobile: 20,
        tablet: 30,
        desktop: 40,
        largeDesktop: 50,
      ),
      bottom: -ResponsiveUtils.getResponsiveValue(
        context: context,
        mobile: 20,
        tablet: 30,
        desktop: 40,
        largeDesktop: 50,
      ),
      child: Opacity(
        opacity: 0.1,
        child: Icon(
          Icons.circle,
          size: ResponsiveUtils.getResponsiveValue(
            context: context,
            mobile: 100,
            tablet: 120,
            desktop: 140,
            largeDesktop: 160,
          ),
          color: AppColors.white,
        ),
      ),
    );
  }

  // Card color variant helper method
  CardColors _getCardColorVariant(Color baseColor, int variant) {
    switch (variant % 5) {
      case 0:
        return CardColors(
          backgroundGradient: [
            baseColor,
            Color.lerp(baseColor, AppColors.primaryDark, 0.7)!
          ],
          iconBackground: AppColors.white.withOpacity(0.2),
          iconColor: AppColors.white,
          textColor: AppColors.white,
          shadowColor: baseColor.withOpacity(0.3),
        );
      case 1:
        return CardColors(
          backgroundGradient: [
            Color.lerp(baseColor, AppColors.white, 0.9)!,
            Color.lerp(baseColor, AppColors.white, 0.7)!
          ],
          iconBackground: baseColor.withOpacity(0.1),
          iconColor: baseColor,
          textColor: AppColors.black,
          shadowColor: AppColors.black.withOpacity(0.1),
        );
      case 2:
        return CardColors(
          backgroundGradient: [
            baseColor.withOpacity(0.1),
            baseColor.withOpacity(0.05)
          ],
          iconBackground: baseColor.withOpacity(0.15),
          iconColor: baseColor,
          textColor: AppColors.black,
          shadowColor: AppColors.black.withOpacity(0.05),
        );
      case 3:
        return CardColors(
          backgroundGradient: [
            Color.lerp(baseColor, AppColors.primaryLight, 0.8)!,
            baseColor
          ],
          iconBackground: AppColors.white.withOpacity(0.15),
          iconColor: AppColors.white,
          textColor: AppColors.white,
          shadowColor: baseColor.withOpacity(0.4),
        );
      case 4:
      default:
        return CardColors(
          backgroundGradient: [
            baseColor,
            Color.lerp(baseColor, AppColors.black, 0.1)!
          ],
          iconBackground: AppColors.white.withOpacity(0.25),
          iconColor: AppColors.white,
          textColor: AppColors.white,
          shadowColor: baseColor.withOpacity(0.5),
        );
    }
  }

  Widget _buildFeaturedCareersSection() {
    return Container(
      margin: ResponsiveUtils.getSectionPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Featured Careers",
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveValue(
                    context: context,
                    mobile: 20,
                    tablet: 24,
                    desktop: 28,
                    largeDesktop: 32,
                  ),
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CareerBankScreen())),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.getResponsiveValue(
                      context: context,
                      mobile: 16,
                      tablet: 20,
                      desktop: 24,
                      largeDesktop: 28,
                    ),
                    vertical: ResponsiveUtils.getResponsiveValue(
                      context: context,
                      mobile: 8,
                      tablet: 10,
                      desktop: 12,
                      largeDesktop: 14,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getResponsiveValue(
                      context: context,
                      mobile: 12,
                      tablet: 14,
                      desktop: 16,
                      largeDesktop: 18,
                    )),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "View All",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: ResponsiveUtils.getResponsiveValue(
                            context: context,
                            mobile: 12,
                            tablet: 13,
                            desktop: 14,
                            largeDesktop: 15,
                          ),
                        ),
                      ),
                      SizedBox(
                          width:
                              ResponsiveUtils.getSectionSpacing(context) * 0.2),
                      Icon(Icons.arrow_forward_rounded,
                          color: AppColors.primary,
                          size: ResponsiveUtils.getResponsiveValue(
                            context: context,
                            mobile: 16,
                            tablet: 18,
                            desktop: 20,
                            largeDesktop: 22,
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
          StreamBuilder<List<CareerModel>>(
            stream: _featuredCareersStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildSectionLoading();
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState(
                  "No careers available",
                  Icons.work_outline_rounded,
                  "Check back later for new career opportunities",
                );
              }
              return _buildCareerList(snapshot.data!);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCareerList(List<CareerModel> careers) {
    return SizedBox(
      height: ResponsiveUtils.getResponsiveValue(
        context: context,
        mobile: 240,
        tablet: 280,
        desktop: 320,
        largeDesktop: 360,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: careers.length,
        itemBuilder: (context, index) {
          final career = careers[index];
          return _buildCareerCard(career, index, careers.length);
        },
      ),
    );
  }

  Widget _buildCareerCard(CareerModel career, int index, int totalCount) {
    final cardWidth = ResponsiveUtils.getResponsiveValue(
      context: context,
      mobile: 220,
      tablet: 260,
      desktop: 300,
      largeDesktop: 340,
    );

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          userCareerDetailScreenRoute,
          arguments: {
            'careerId': career.careerId,
          },
        );
      },
      child: Container(
        width: cardWidth,
        margin: EdgeInsets.only(
          left:
              index == 0 ? 0 : ResponsiveUtils.getSectionSpacing(context) * 0.8,
          right: index == totalCount - 1
              ? 0
              : ResponsiveUtils.getSectionSpacing(context) * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(ResponsiveUtils.getResponsiveValue(
            context: context,
            mobile: 20,
            tablet: 24,
            desktop: 28,
            largeDesktop: 32,
          )),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: ResponsiveUtils.getResponsiveValue(
                    context: context,
                    mobile: 140,
                    tablet: 160,
                    desktop: 180,
                    largeDesktop: 200,
                  ),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft:
                          Radius.circular(ResponsiveUtils.getResponsiveValue(
                        context: context,
                        mobile: 20,
                        tablet: 24,
                        desktop: 28,
                        largeDesktop: 32,
                      )),
                      topRight:
                          Radius.circular(ResponsiveUtils.getResponsiveValue(
                        context: context,
                        mobile: 20,
                        tablet: 24,
                        desktop: 28,
                        largeDesktop: 32,
                      )),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(
                        career.images.isNotEmpty
                            ? career.images[0]
                            : "https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=400",
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: ResponsiveUtils.getResponsiveValue(
                    context: context,
                    mobile: 140,
                    tablet: 160,
                    desktop: 180,
                    largeDesktop: 200,
                  ),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft:
                          Radius.circular(ResponsiveUtils.getResponsiveValue(
                        context: context,
                        mobile: 20,
                        tablet: 24,
                        desktop: 28,
                        largeDesktop: 32,
                      )),
                      topRight:
                          Radius.circular(ResponsiveUtils.getResponsiveValue(
                        context: context,
                        mobile: 20,
                        tablet: 24,
                        desktop: 28,
                        largeDesktop: 32,
                      )),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: ResponsiveUtils.getSectionSpacing(context) * 0.5,
                  left: ResponsiveUtils.getSectionSpacing(context) * 0.5,
                  right: ResponsiveUtils.getSectionSpacing(context) * 0.5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              ResponsiveUtils.getSectionSpacing(context) * 0.4,
                          vertical:
                              ResponsiveUtils.getSectionSpacing(context) * 0.2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(
                              ResponsiveUtils.getResponsiveValue(
                            context: context,
                            mobile: 10,
                            tablet: 12,
                            desktop: 14,
                            largeDesktop: 16,
                          )),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.trending_up_rounded,
                                color: Colors.white,
                                size: ResponsiveUtils.getResponsiveValue(
                                  context: context,
                                  mobile: 12,
                                  tablet: 14,
                                  desktop: 16,
                                  largeDesktop: 18,
                                )),
                            SizedBox(
                                width:
                                    ResponsiveUtils.getSectionSpacing(context) *
                                        0.2),
                            Text(
                              "High Demand",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: ResponsiveUtils.getResponsiveValue(
                                  context: context,
                                  mobile: 10,
                                  tablet: 11,
                                  desktop: 12,
                                  largeDesktop: 13,
                                ),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                          height:
                              ResponsiveUtils.getSectionSpacing(context) * 0.3),
                      Text(
                        career.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: ResponsiveUtils.getResponsiveValue(
                            context: context,
                            mobile: 16,
                            tablet: 18,
                            desktop: 20,
                            largeDesktop: 22,
                          ),
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(
                    ResponsiveUtils.getSectionSpacing(context) * 0.8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          career.industryName,
                          style: TextStyle(
                            color: AppColors.grey,
                            fontSize: ResponsiveUtils.getResponsiveValue(
                              context: context,
                              mobile: 12,
                              tablet: 13,
                              desktop: 14,
                              largeDesktop: 15,
                            ),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                ResponsiveUtils.getSectionSpacing(context) *
                                    0.6,
                            vertical:
                                ResponsiveUtils.getSectionSpacing(context) *
                                    0.3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                                ResponsiveUtils.getResponsiveValue(
                              context: context,
                              mobile: 10,
                              tablet: 12,
                              desktop: 14,
                              largeDesktop: 16,
                            )),
                          ),
                          child: Text(
                            career.salaryRange ?? "\$60K-\$90K",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: ResponsiveUtils.getResponsiveValue(
                                context: context,
                                mobile: 12,
                                tablet: 13,
                                desktop: 14,
                                largeDesktop: 15,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.all(
                              ResponsiveUtils.getSectionSpacing(context) * 0.3),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: ResponsiveUtils.getResponsiveValue(
                              context: context,
                              mobile: 16,
                              tablet: 18,
                              desktop: 20,
                              largeDesktop: 22,
                            ),
                          ),
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

  Widget _buildPopularResourcesSection() {
    return Container(
      margin: ResponsiveUtils.getSectionPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Learning Resources",
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveValue(
                    context: context,
                    mobile: 20,
                    tablet: 24,
                    desktop: 28,
                    largeDesktop: 32,
                  ),
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ResourcesScreen())),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.getResponsiveValue(
                      context: context,
                      mobile: 16,
                      tablet: 20,
                      desktop: 24,
                      largeDesktop: 28,
                    ),
                    vertical: ResponsiveUtils.getResponsiveValue(
                      context: context,
                      mobile: 8,
                      tablet: 10,
                      desktop: 12,
                      largeDesktop: 14,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getResponsiveValue(
                      context: context,
                      mobile: 12,
                      tablet: 14,
                      desktop: 16,
                      largeDesktop: 18,
                    )),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "View All",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: ResponsiveUtils.getResponsiveValue(
                            context: context,
                            mobile: 12,
                            tablet: 13,
                            desktop: 14,
                            largeDesktop: 15,
                          ),
                        ),
                      ),
                      SizedBox(
                          width:
                              ResponsiveUtils.getSectionSpacing(context) * 0.2),
                      Icon(Icons.arrow_forward_rounded,
                          color: AppColors.primary,
                          size: ResponsiveUtils.getResponsiveValue(
                            context: context,
                            mobile: 16,
                            tablet: 18,
                            desktop: 20,
                            largeDesktop: 22,
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
          StreamBuilder<List<ResourceModel>>(
            stream: _popularResourcesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildSectionLoading();
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState(
                  "No resources available",
                  Icons.library_books_rounded,
                  "Explore our learning materials to enhance your skills",
                );
              }
              return _buildResourceList(snapshot.data!);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResourceList(List<ResourceModel> resources) {
    return SizedBox(
      height: ResponsiveUtils.getResponsiveValue(
        context: context,
        mobile: 180,
        tablet: 220,
        desktop: 260,
        largeDesktop: 300,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: resources.length,
        itemBuilder: (context, index) {
          final resource = resources[index];
          return _buildResourceCard(resource, index, resources.length);
        },
      ),
    );
  }

  Widget _buildResourceCard(ResourceModel resource, int index, int totalCount) {
    final cardWidth = ResponsiveUtils.getResponsiveValue(
      context: context,
      mobile: 150,
      tablet: 180,
      desktop: 220,
      largeDesktop: 260,
    );

    final typeColor = _getResourceTypeColor(resource.type);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          resourceScreenRoute,
          arguments: {
            'resourceId': resource.resourceId,
          },
        );
      },
      child: Container(
        width: cardWidth,
        margin: EdgeInsets.only(
          left:
              index == 0 ? 0 : ResponsiveUtils.getSectionSpacing(context) * 0.8,
          right: index == totalCount - 1
              ? 0
              : ResponsiveUtils.getSectionSpacing(context) * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(ResponsiveUtils.getResponsiveValue(
            context: context,
            mobile: 16,
            tablet: 20,
            desktop: 24,
            largeDesktop: 28,
          )),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: ResponsiveUtils.getResponsiveValue(
                    context: context,
                    mobile: 100,
                    tablet: 120,
                    desktop: 140,
                    largeDesktop: 160,
                  ),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft:
                          Radius.circular(ResponsiveUtils.getResponsiveValue(
                        context: context,
                        mobile: 16,
                        tablet: 20,
                        desktop: 24,
                        largeDesktop: 28,
                      )),
                      topRight:
                          Radius.circular(ResponsiveUtils.getResponsiveValue(
                        context: context,
                        mobile: 16,
                        tablet: 20,
                        desktop: 24,
                        largeDesktop: 28,
                      )),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(
                        resource.displayImageUrl?.isNotEmpty == true
                            ? resource.displayImageUrl!
                            : _getDefaultResourceImage(resource.type),
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: ResponsiveUtils.getSectionSpacing(context) * 0.4,
                  right: ResponsiveUtils.getSectionSpacing(context) * 0.4,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          ResponsiveUtils.getSectionSpacing(context) * 0.3,
                      vertical:
                          ResponsiveUtils.getSectionSpacing(context) * 0.2,
                    ),
                    decoration: BoxDecoration(
                      color: typeColor,
                      borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getResponsiveValue(
                        context: context,
                        mobile: 8,
                        tablet: 10,
                        desktop: 12,
                        largeDesktop: 14,
                      )),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      resource.type.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ResponsiveUtils.getResponsiveValue(
                          context: context,
                          mobile: 8,
                          tablet: 9,
                          desktop: 10,
                          largeDesktop: 11,
                        ),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(
                    ResponsiveUtils.getSectionSpacing(context) * 0.6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resource.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: ResponsiveUtils.getResponsiveValue(
                              context: context,
                              mobile: 13,
                              tablet: 14,
                              desktop: 15,
                              largeDesktop: 16,
                            ),
                            color: AppColors.black,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.star_rounded,
                            color: AppColors.warning,
                            size: ResponsiveUtils.getResponsiveValue(
                              context: context,
                              mobile: 14,
                              tablet: 15,
                              desktop: 16,
                              largeDesktop: 17,
                            )),
                        SizedBox(
                            width: ResponsiveUtils.getSectionSpacing(context) *
                                0.2),
                        Text(
                          "4.8 (1.2K)",
                          style: TextStyle(
                            color: AppColors.grey,
                            fontSize: ResponsiveUtils.getResponsiveValue(
                              context: context,
                              mobile: 11,
                              tablet: 12,
                              desktop: 13,
                              largeDesktop: 14,
                            ),
                            fontWeight: FontWeight.w500,
                          ),
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

  Widget _buildSuccessStoriesSection() {
    return Container(
      margin: ResponsiveUtils.getSectionPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Success Stories",
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveValue(
                    context: context,
                    mobile: 20,
                    tablet: 24,
                    desktop: 28,
                    largeDesktop: 32,
                  ),
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UserTestimonialScreen())),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.getResponsiveValue(
                      context: context,
                      mobile: 16,
                      tablet: 20,
                      desktop: 24,
                      largeDesktop: 28,
                    ),
                    vertical: ResponsiveUtils.getResponsiveValue(
                      context: context,
                      mobile: 8,
                      tablet: 10,
                      desktop: 12,
                      largeDesktop: 14,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getResponsiveValue(
                      context: context,
                      mobile: 12,
                      tablet: 14,
                      desktop: 16,
                      largeDesktop: 18,
                    )),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "View All",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: ResponsiveUtils.getResponsiveValue(
                            context: context,
                            mobile: 12,
                            tablet: 13,
                            desktop: 14,
                            largeDesktop: 15,
                          ),
                        ),
                      ),
                      SizedBox(
                          width:
                              ResponsiveUtils.getSectionSpacing(context) * 0.2),
                      Icon(Icons.arrow_forward_rounded,
                          color: AppColors.primary,
                          size: ResponsiveUtils.getResponsiveValue(
                            context: context,
                            mobile: 16,
                            tablet: 18,
                            desktop: 20,
                            largeDesktop: 22,
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
          StreamBuilder<List<Testimonial>>(
            stream: _successStoriesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildSectionLoading();
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState(
                  "No success stories available",
                  Icons.people_alt_rounded,
                  "Be the first to share your success story",
                );
              }
              return _buildTestimonialList(snapshot.data!);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialList(List<Testimonial> testimonials) {
    return SizedBox(
      height: ResponsiveUtils.getResponsiveValue(
        context: context,
        mobile: 280,
        tablet: 320,
        desktop: 360,
        largeDesktop: 400,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: testimonials.length,
        itemBuilder: (context, index) {
          final testimonial = testimonials[index];
          return _buildTestimonialCard(testimonial, index, testimonials.length);
        },
      ),
    );
  }

  Widget _buildTestimonialCard(
      Testimonial testimonial, int index, int totalCount) {
    final cardWidth = ResponsiveUtils.getResponsiveValue(
      context: context,
      mobile: 240,
      tablet: 280,
      desktop: 320,
      largeDesktop: 360,
    );

    final tierColor = _getTierColor(testimonial.tier);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          userTestimonialScreenRoute,
          arguments: {
            'testimonialId': testimonial.testimonialId,
          },
        );
      },
      child: Container(
        width: cardWidth,
        margin: EdgeInsets.only(
          left:
              index == 0 ? 0 : ResponsiveUtils.getSectionSpacing(context) * 0.8,
          right: index == totalCount - 1
              ? 0
              : ResponsiveUtils.getSectionSpacing(context) * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(ResponsiveUtils.getResponsiveValue(
            context: context,
            mobile: 20,
            tablet: 24,
            desktop: 28,
            largeDesktop: 32,
          )),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(
                  ResponsiveUtils.getSectionSpacing(context) * 0.8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    tierColor.withOpacity(0.15),
                    tierColor.withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(ResponsiveUtils.getResponsiveValue(
                    context: context,
                    mobile: 20,
                    tablet: 24,
                    desktop: 28,
                    largeDesktop: 32,
                  )),
                  topRight: Radius.circular(ResponsiveUtils.getResponsiveValue(
                    context: context,
                    mobile: 20,
                    tablet: 24,
                    desktop: 28,
                    largeDesktop: 32,
                  )),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          ResponsiveUtils.getSectionSpacing(context) * 0.6,
                      vertical:
                          ResponsiveUtils.getSectionSpacing(context) * 0.4,
                    ),
                    decoration: BoxDecoration(
                      color: tierColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getResponsiveValue(
                        context: context,
                        mobile: 12,
                        tablet: 14,
                        desktop: 16,
                        largeDesktop: 18,
                      )),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getTierIcon(testimonial.tier),
                          size: ResponsiveUtils.getResponsiveValue(
                            context: context,
                            mobile: 16,
                            tablet: 18,
                            desktop: 20,
                            largeDesktop: 22,
                          ),
                          color: tierColor,
                        ),
                        SizedBox(
                            width: ResponsiveUtils.getSectionSpacing(context) *
                                0.4),
                        Text(
                          _getTierLabel(testimonial.tier),
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveValue(
                              context: context,
                              mobile: 13,
                              tablet: 14,
                              desktop: 15,
                              largeDesktop: 16,
                            ),
                            fontWeight: FontWeight.w600,
                            color: tierColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(
                    ResponsiveUtils.getSectionSpacing(context) * 0.8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.format_quote_rounded,
                      size: ResponsiveUtils.getResponsiveValue(
                        context: context,
                        mobile: 32,
                        tablet: 36,
                        desktop: 40,
                        largeDesktop: 44,
                      ),
                      color: tierColor.withOpacity(0.15),
                    ),
                    SizedBox(
                        height:
                            ResponsiveUtils.getSectionSpacing(context) * 0.6),
                    Expanded(
                      child: Text(
                        testimonial.story,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveValue(
                            context: context,
                            mobile: 13,
                            tablet: 14,
                            desktop: 15,
                            largeDesktop: 16,
                          ),
                          height: 1.6,
                          color: Colors.grey.shade800,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                        height:
                            ResponsiveUtils.getSectionSpacing(context) * 0.8),
                    Row(
                      children: [
                        Container(
                          width: ResponsiveUtils.getResponsiveValue(
                            context: context,
                            mobile: 48,
                            tablet: 52,
                            desktop: 56,
                            largeDesktop: 60,
                          ),
                          height: ResponsiveUtils.getResponsiveValue(
                            context: context,
                            mobile: 48,
                            tablet: 52,
                            desktop: 56,
                            largeDesktop: 60,
                          ),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: tierColor.withOpacity(0.3),
                              width: 2,
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                tierColor,
                                tierColor.withOpacity(0.7),
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: ClipOval(
                              child: Image.network(
                                testimonial.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade200,
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.grey.shade400,
                                      size: ResponsiveUtils.getResponsiveValue(
                                          context: context,
                                          mobile: 24,
                                          tablet: 26,
                                          desktop: 28,
                                          largeDesktop: 30),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                            width: ResponsiveUtils.getSectionSpacing(context) *
                                0.6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                testimonial.name,
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.getResponsiveValue(
                                    context: context,
                                    mobile: 15,
                                    tablet: 16,
                                    desktop: 17,
                                    largeDesktop: 18,
                                  ),
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(
                                  height: ResponsiveUtils.getSectionSpacing(
                                          context) *
                                      0.2),
                              Text(
                                _formatDate(testimonial.createdAt),
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.getResponsiveValue(
                                    context: context,
                                    mobile: 11,
                                    tablet: 12,
                                    desktop: 13,
                                    largeDesktop: 14,
                                  ),
                                  color: Colors.grey.shade500,
                                ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityHighlightsSection() {
    return Container(
      margin: ResponsiveUtils.getSectionPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Community Discussions",
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveValue(
                    context: context,
                    mobile: 20,
                    tablet: 24,
                    desktop: 28,
                    largeDesktop: 32,
                  ),
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CommunityPage())),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.getResponsiveValue(
                      context: context,
                      mobile: 16,
                      tablet: 20,
                      desktop: 24,
                      largeDesktop: 28,
                    ),
                    vertical: ResponsiveUtils.getResponsiveValue(
                      context: context,
                      mobile: 8,
                      tablet: 10,
                      desktop: 12,
                      largeDesktop: 14,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getResponsiveValue(
                      context: context,
                      mobile: 12,
                      tablet: 14,
                      desktop: 16,
                      largeDesktop: 18,
                    )),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "View All",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: ResponsiveUtils.getResponsiveValue(
                            context: context,
                            mobile: 12,
                            tablet: 13,
                            desktop: 14,
                            largeDesktop: 15,
                          ),
                        ),
                      ),
                      SizedBox(
                          width:
                              ResponsiveUtils.getSectionSpacing(context) * 0.2),
                      Icon(Icons.arrow_forward_rounded,
                          color: AppColors.primary,
                          size: ResponsiveUtils.getResponsiveValue(
                            context: context,
                            mobile: 16,
                            tablet: 18,
                            desktop: 20,
                            largeDesktop: 22,
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
          _buildEmptyState(
            "No discussions yet",
            Icons.forum_rounded,
            "Be the first to start a conversation in our community!",
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLoading() {
    return Container(
      height: ResponsiveUtils.getResponsiveValue(
        context: context,
        mobile: 160,
        tablet: 180,
        desktop: 200,
        largeDesktop: 220,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveValue(
          context: context,
          mobile: 20,
          tablet: 24,
          desktop: 28,
          largeDesktop: 32,
        )),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 3,
            ),
            SizedBox(height: ResponsiveUtils.getSectionSpacing(context) * 0.5),
            Text(
              "Loading content...",
              style: TextStyle(
                color: AppColors.darkGrey,
                fontSize: ResponsiveUtils.getResponsiveValue(
                  context: context,
                  mobile: 13,
                  tablet: 14,
                  desktop: 15,
                  largeDesktop: 16,
                ),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon, String subtitle) {
    return Container(
      height: ResponsiveUtils.getResponsiveValue(
        context: context,
        mobile: 160,
        tablet: 180,
        desktop: 200,
        largeDesktop: 220,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveValue(
          context: context,
          mobile: 20,
          tablet: 24,
          desktop: 28,
          largeDesktop: 32,
        )),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: ResponsiveUtils.getResponsiveValue(
                context: context,
                mobile: 60,
                tablet: 70,
                desktop: 80,
                largeDesktop: 90,
              ),
              height: ResponsiveUtils.getResponsiveValue(
                context: context,
                mobile: 60,
                tablet: 70,
                desktop: 80,
                largeDesktop: 90,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  color: AppColors.primary,
                  size: ResponsiveUtils.getResponsiveValue(
                    context: context,
                    mobile: 28,
                    tablet: 32,
                    desktop: 36,
                    largeDesktop: 40,
                  )),
            ),
            SizedBox(height: ResponsiveUtils.getSectionSpacing(context) * 0.5),
            Text(
              message,
              style: TextStyle(
                color: AppColors.black,
                fontSize: ResponsiveUtils.getResponsiveValue(
                  context: context,
                  mobile: 15,
                  tablet: 16,
                  desktop: 17,
                  largeDesktop: 18,
                ),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: ResponsiveUtils.getSectionSpacing(context) * 0.3),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getSectionSpacing(context)),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.darkGrey,
                  fontSize: ResponsiveUtils.getResponsiveValue(
                    context: context,
                    mobile: 12,
                    tablet: 13,
                    desktop: 14,
                    largeDesktop: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Color _getResourceTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'blog':
        return AppColors.info;
      case 'video':
        return AppColors.success;
      case 'ebook':
        return AppColors.secondary;
      case 'pdf':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  String _getDefaultResourceImage(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return "https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=300";
      case 'ebook':
        return "https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=300";
      default:
        return "https://images.unsplash.com/photo-1542435503-956c469947f6?w=300";
    }
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'student':
        return AppColors.info;
      case 'graduate':
        return AppColors.success;
      case 'professional':
        return AppColors.secondary;
      default:
        return AppColors.primary;
    }
  }

  IconData _getTierIcon(String tier) {
    switch (tier) {
      case 'student':
        return Icons.school_rounded;
      case 'graduate':
        return Icons.celebration_rounded;
      case 'professional':
        return Icons.work_rounded;
      default:
        return Icons.people_rounded;
    }
  }

  String _getTierLabel(String tier) {
    switch (tier) {
      case 'student':
        return 'Student Success';
      case 'graduate':
        return 'Graduate Journey';
      case 'professional':
        return 'Professional Growth';
      default:
        return 'Success Story';
    }
  }
}

// Enhanced number formatting extension
extension NumberFormatting on int {
  String formatCompact() {
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toString();
  }
}
