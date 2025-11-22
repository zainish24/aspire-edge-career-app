import 'package:flutter/material.dart';
import 'components/onbording_content.dart';
import 'package:aspire_edge/routes/route_constants.dart';
import 'package:aspire_edge/theme/app_theme.dart';

// Modern Onboarding Screen with Premium Design
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _pageIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _buttonScaleAnimation;
  late Animation<Offset> _slideAnimation;

  final List<OnboardPage> _onboardData = [
    OnboardPage(
      image: "Illustration/1.png",
      title: "Discover Your Career Path",
      description:
          "Explore thousands of career options that match your unique skills and interests. Get AI-powered recommendations tailored to your strengths.",
      icon: Icons.explore_rounded,
      gradient: [AppColors.primary, AppColors.primaryLight],
    ),
    OnboardPage(
      image: "Illustration/2.png",
      title: "Smart Career Assessment",
      description:
          "Take intelligent quizzes backed by career psychology to discover paths that align with your personality, abilities, and aspirations.",
      icon: Icons.psychology_rounded,
      gradient: [AppColors.primary, AppColors.primaryLight],
    ),
    OnboardPage(
      image: "Illustration/3.png",
      title: "Premium Learning Resources",
      description:
          "Access expert-led courses, industry insights, and professional guidance to make informed career decisions and accelerate your growth.",
      icon: Icons.school_rounded,
      gradient: [AppColors.primary, AppColors.primaryLight],
    ),
  ];

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    _initAnimations();
    super.initState();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _buttonScaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.5, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildSkipButton(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _pageIndex == _onboardData.length - 1
          ? const SizedBox.shrink()
          : MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(AppBorders.radiusLg),
                child: InkWell(
                  onTap: () {
                    _navigateToLogin(context);
                  },
                  borderRadius: BorderRadius.circular(AppBorders.radiusLg),
                  onHover: (hovered) {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppBorders.radiusLg),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: AppColors.lightGrey.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      "Skip",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGrey,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    final isLastPage = _pageIndex == _onboardData.length - 1;
    final buttonSize = MediaQuery.of(context).size.width * 0.16;

    return AnimatedBuilder(
      animation: _buttonScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _buttonScaleAnimation.value,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: isLastPage ? 160 : buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isLastPage
                      ? [AppColors.primary, AppColors.primary.withOpacity(0.9)]
                      : _onboardData[_pageIndex].gradient,
                ),
                borderRadius: BorderRadius.circular(
                    isLastPage ? AppBorders.radiusLg : buttonSize / 2),
                boxShadow: [
                  BoxShadow(
                    color: (isLastPage
                                ? AppColors.primary
                                : _onboardData[_pageIndex].gradient[0])
                            .withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(
                    isLastPage ? AppBorders.radiusLg : buttonSize / 2),
                child: InkWell(
                  onTap: () => _handleNextButton(context),
                  borderRadius: BorderRadius.circular(
                      isLastPage ? AppBorders.radiusLg : buttonSize / 2),
                  onHover: (hovered) {
                    if (hovered) {
                      _animationController.forward();
                    }
                  },
                  child: Stack(
                    children: [
                      // Ripple effect background
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                isLastPage ? AppBorders.radiusLg : buttonSize / 2),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: isLastPage
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Get Started",
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: AppColors.white,
                                      size: 20,
                                    ),
                                  ],
                                )
                              : Icon(
                                  Icons.arrow_forward_rounded,
                                  color: AppColors.white,
                                  size: 24,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleNextButton(BuildContext context) {
    if (_pageIndex < _onboardData.length - 1) {
      _pageController.nextPage(
        curve: Curves.easeInOutCubic,
        duration: const Duration(milliseconds: 600),
      );
    } else {
      _navigateToLogin(context);
    }
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.pushNamed(context, logInScreenRoute);
  }

  Widget _buildBackgroundDecoration() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              _onboardData[_pageIndex].gradient[0].withOpacity(0.03),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingParticles() {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 1000),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.8, -0.8),
              radius: 1.0,
              colors: [
                _onboardData[_pageIndex].gradient[1].withOpacity(0.05),
                Colors.transparent,
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
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          _buildBackgroundDecoration(),
          _buildFloatingParticles(),
          
          SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width < 600 ? 24 : 40,
                vertical: 16,
              ),
              child: Column(
                children: [
                  // Header with Skip Button
                  AnimatedBuilder(
                    animation: _slideAnimation,
                    builder: (context, child) {
                      return SlideTransition(
                        position: _slideAnimation,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // App Logo/Brand
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.work_rounded,
                                color: AppColors.primary,
                                size: 28,
                              ),
                            ),
                            _buildSkipButton(context),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Page View
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _onboardData.length,
                      onPageChanged: (value) {
                        setState(() {
                          _pageIndex = value;
                        });
                        _animationController.forward();
                      },
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) => OnboardingContent(
                        title: _onboardData[index].title,
                        description: _onboardData[index].description,
                        image: _onboardData[index].image,
                        stepNumber: index + 1,
                        isTextOnTop: index.isOdd,
                        icon: _onboardData[index].icon,
                        gradient: _onboardData[index].gradient,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Bottom Navigation - Premium
                  AnimatedBuilder(
                    animation: _slideAnimation,
                    builder: (context, child) {
                      return SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: AppColors.lightGrey.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Enhanced Dot Indicators
                              Row(
                                children: [
                                  ...List.generate(
                                    _onboardData.length,
                                    (index) => Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: _ModernDotIndicator(
                                        isActive: index == _pageIndex,
                                        activeColor: _onboardData[_pageIndex].gradient[0],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const Spacer(),

                              // Page Info with Animation
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _onboardData[_pageIndex]
                                          .gradient[0]
                                          .withOpacity(0.1),
                                      _onboardData[_pageIndex]
                                          .gradient[1]
                                          .withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(AppBorders.radiusMd),
                                ),
                                child: Text(
                                  "${_pageIndex + 1}/${_onboardData.length}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _onboardData[_pageIndex].gradient[0],
                                  ),
                                ),
                              ),

                              const SizedBox(width: 20),

                              // Next Button
                              _buildNextButton(context),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Modern Dot Indicator with Glow Effect
class _ModernDotIndicator extends StatelessWidget {
  final bool isActive;
  final Color activeColor;

  const _ModernDotIndicator({
    required this.isActive,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.fastOutSlowIn,
      width: isActive ? 32 : 12,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? activeColor : AppColors.grey.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: activeColor.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
    );
  }
}

class OnboardPage {
  final String image, title, description;
  final IconData icon;
  final List<Color> gradient;

  OnboardPage({
    required this.image,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
  });
}