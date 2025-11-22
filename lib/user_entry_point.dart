import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aspire_edge/theme/app_theme.dart';
import 'package:aspire_edge/routes/screen_export.dart';
import '../screens/user_screens/bookmark/views/bookmark_screen.dart';
import 'screens/user_screens/community/views/community_page.dart';
import '../screens/user_screens/home/views/home_screen.dart';

class UserEntryPoint extends StatefulWidget {
  final int initialIndex;
  const UserEntryPoint({super.key, this.initialIndex = 0});

  @override
  State<UserEntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<UserEntryPoint>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  bool _isNavigating = false;

  AnimationController? _loadingController;
  Animation<double>? _loadingAnimation;

  final List<Widget> _pages = [
    HomeScreen(), // index 0
    const CareerBankScreen(),
    const BookmarkScreen(),
    CommunityPage(),
    const ProfileScreen(
      userId: '',
      userName: '',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _loadingAnimation = CurvedAnimation(
      parent: _loadingController!,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _loadingController?.dispose();
    super.dispose();
  }

  void _navigateWithLoading(int index) {
    if (_loadingController == null) return;

    setState(() {
      _isNavigating = true;
    });

    _loadingController!.forward();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _currentIndex = index;
        });

        Future.delayed(const Duration(milliseconds: 2000), () {
          if (mounted) {
            _loadingController!.reverse();
            setState(() {
              _isNavigating = false;
            });
          }
        });
      }
    });
  }

  // Custom icon widget with fallback for missing SVG assets
  Widget _buildNavIcon(String iconName, bool isSelected) {
    final color = isSelected ? AppColors.primary : AppColors.grey;

    // Try to load SVG, fallback to Material Icons if SVG fails
    try {
      return SvgPicture.string(
        _getSvgData(iconName),
        height: 24,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    } catch (e) {
      // Fallback to Material icons if SVG fails
      final iconData = _getFallbackIcon(iconName);
      return Icon(iconData, size: 24, color: color);
    }
  }

  // Get SVG data as string (inline SVG)
  String _getSvgData(String iconName) {
    switch (iconName) {
      case 'home':
        return '''
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M9.99998 19V14H14V19C14 19.55 14.45 20 15 20H18C18.55 20 19 19.55 19 19V12H20.7C21.16 12 21.38 11.43 21.03 11.13L12.67 3.6C12.29 3.26 11.71 3.26 11.33 3.6L2.96998 11.13C2.62998 11.43 2.83998 12 3.29998 12H4.99998V19C4.99998 19.55 5.44998 20 5.99998 20H8.99998C9.54998 20 9.99998 19.55 9.99998 19Z" fill="currentColor"/>
          </svg>
        ''';
case 'discover':
  return '''
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M12 2C6.48 2 2 6.48 2 12C2 17.52 6.48 22 12 22C17.52 22 22 17.52 22 12C22 6.48 17.52 2 12 2ZM16.64 8.8L14.88 14.88L8.8 16.64L10.56 10.56L16.64 8.8ZM12 13.5C12.8284 13.5 13.5 12.8284 13.5 12C13.5 11.1716 12.8284 10.5 12 10.5C11.1716 10.5 10.5 11.1716 10.5 12C10.5 12.8284 11.1716 13.5 12 13.5Z" fill="currentColor"/>
    </svg>
  ''';
      case 'bookmark':
        return '''
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M17 3H7C5.9 3 5.01 3.9 5.01 5L5 21L12 18L19 21V5C19 3.9 18.1 3 17 3Z" fill="currentColor"/>
          </svg>
        ''';
      case 'community':
        return '''
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M16 11C17.66 11 18.99 9.66 18.99 8C18.99 6.34 17.66 5 16 5C14.34 5 13 6.34 13 8C13 9.66 14.34 11 16 11ZM8 11C9.66 11 10.99 9.66 10.99 8C10.99 6.34 9.66 5 8 5C6.34 5 5 6.34 5 8C5 9.66 6.34 11 8 11ZM8 13C5.67 13 1 14.17 1 16.5V19H15V16.5C15 14.17 10.33 13 8 13ZM16 13C15.71 13 15.38 13.02 15.03 13.05C16.19 13.89 17 15.02 17 16.5V19H23V16.5C23 14.17 18.33 13 16 13Z" fill="currentColor"/>
          </svg>
        ''';
      case 'profile':
        return '''
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M12 12C14.21 12 16 10.21 16 8C16 5.79 14.21 4 12 4C9.79 4 8 5.79 8 8C8 10.21 9.79 12 12 12ZM12 14C9.33 14 4 15.34 4 18V20H20V18C20 15.34 14.67 14 12 14Z" fill="currentColor"/>
          </svg>
        ''';
      default:
        return '''
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <rect width="24" height="24" fill="currentColor"/>
          </svg>
        ''';
    }
  }

  // Fallback to Material icons if SVG fails
  IconData _getFallbackIcon(String iconName) {
    switch (iconName) {
      case 'home':
        return Icons.home_outlined;
      // case 'discover':
      //   return Icons.explore_outlined;
      case 'bookmark':
        return Icons.bookmark_outline;
      case 'community':
        return Icons.people_outline;
      case 'profile':
        return Icons.person_outline;
      default:
        return Icons.error_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Scaffold(
          body: PageTransitionSwitcher(
            // duration: defaultDuration,`
            transitionBuilder: (child, animation, secondAnimation) {
              return FadeThroughTransition(
                animation: animation,
                secondaryAnimation: secondAnimation,
                child: child,
              );
            },
            child: _pages[_currentIndex],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex > 4 ? 4 : _currentIndex,
              onTap: _navigateWithLoading,
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedFontSize: AppText.labelSmall,
              unselectedFontSize: AppText.labelSmall,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.grey,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              items: [
                BottomNavigationBarItem(
                  icon: _buildNavIcon('home', _currentIndex == 0),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIcon('discover', _currentIndex == 1),
                  label: "Discover",
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIcon('bookmark', _currentIndex == 2),
                  label: "Bookmark",
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIcon('community', _currentIndex == 3),
                  label: "Community",
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIcon('profile', _currentIndex == 4),
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),

        // Global loading overlay
        if (_isNavigating && _loadingAnimation != null)
          FadeTransition(
            opacity: _loadingAnimation!,
            // child: Container(
            //   color: Colors.black.withOpacity(0.5),
            //   child: Center(
            //     child: Image.asset(
            //       // 'assets/gif/1.gif',
            //       width: 250,
            //       height: 250,
            //       fit: BoxFit.contain,
            //       errorBuilder: (context, error, stackTrace) {
            //         return Container(
            //           width: 250,
            //           height: 250,
            //           color: AppColors.primary.withOpacity(0.7),
            //           child: const Center(
            //             child: CircularProgressIndicator(
            //               valueColor:
            //                   AlwaysStoppedAnimation<Color>(Colors.white),
            //             ),
            //           ),
            //         );
            //       },
            //     ),
            //   ),
            // ),
          ),
      ],
    );
  }
}
