// login_screen.dart
// ignore_for_file: unused_import, unused_local_variable, unnecessary_cast

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/../constants.dart';
import '/../routes/route_constants.dart';
import '/../services/auth_service.dart';
import 'components/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  // Career-focused Unsplash images matching your theme
  final String _backgroundPattern =
      "https://images.unsplash.com/photo-1559136555-9303baea8ebd?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80";

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

Future<void> _loginUser() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _loading = true);

  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim());

    // Get user data from Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(userCredential.user!.uid)
        .get();

    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>?;
      final userRole = userData?['role'] ?? 'user';

      _showCustomDialog(context, "Login successful", isError: false);

      // Add a small delay for smooth transition
      await Future.delayed(const Duration(milliseconds: 1500));

      // Role-based navigation
      if (userRole == "admin") {
        Navigator.pushNamedAndRemoveUntil(
          context,
          adminEntryPointScreenRoute,
          (route) => false,
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          userEntryPointScreenRoute,
          (route) => false,
        );
      }
    } else {
      _showError("User profile not found. Please contact support.");
    }

    _emailController.clear();
    _passwordController.clear();
  } on FirebaseAuthException catch (e) {
    String message = "Login failed";
    if (e.code == 'user-not-found') {
      message = "No user found with this email";
    } else if (e.code == 'wrong-password') {
      message = "Incorrect password";
    } else if (e.code == 'invalid-email') {
      message = "Invalid email format";
    }
    _showError(message);
  } catch (e) {
    _showError("An unexpected error occurred");
  } finally {
    if (mounted) {
      setState(() => _loading = false);
    }
  }
}


  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _showError(String message) {
    _showCustomDialog(context, message, isError: true);
  }

  void _showCustomDialog(BuildContext context, String message,
      {bool isError = true}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorders.radiusXl),
          ),
          elevation: 8,
          backgroundColor: isError ? AppColors.error : AppColors.success,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isError
                        ? Icons.error_outline_rounded
                        : Icons.check_circle_rounded,
                    color: isError ? AppColors.error : AppColors.success,
                    size: 32,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: AppText.bodyLarge,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFonts.plusJakartaSans,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor:
                          isError ? AppColors.error : AppColors.success,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppBorders.radiusMd),
                      ),
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      elevation: 0,
                    ),
                    child: Text(
                      "OK",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontFamily: AppFonts.plusJakartaSans,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isLargeScreen = screenWidth > 1200;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Modern Banner Section
                      _buildBannerSection(screenWidth, isSmallScreen),

                      // Content Section
                      Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight -
                              (isSmallScreen ? 280 : screenWidth * 0.45),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(AppBorders.radiusXl),
                            topRight: Radius.circular(AppBorders.radiusXl),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withOpacity(0.08),
                              blurRadius: 40,
                              offset: const Offset(0, -20),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(
                              isSmallScreen ? AppSpacing.lg : AppSpacing.xl),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header Section
                              _buildHeaderSection(isSmallScreen),
                              SizedBox(
                                  height: isSmallScreen
                                      ? AppSpacing.xl
                                      : AppSpacing.xxl),

                              // Login Form Card
                              _buildLoginCard(isSmallScreen, isLargeScreen),

                              const SizedBox(height: AppSpacing.xl),

                              // Footer
                              _buildFooter(isSmallScreen),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Modern Loading Overlay - Fixed with IgnorePointer
          if (_loading)
            IgnorePointer(
              ignoring: false,
              child: Container(
                color: AppColors.black.withOpacity(0.6),
                child: Center(
                  child: Container(
                    width: isSmallScreen ? 120 : 140,
                    height: isSmallScreen ? 120 : 140,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppBorders.radiusXl),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withOpacity(0.2),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: isSmallScreen ? 40 : 48,
                          height: isSmallScreen ? 40 : 48,
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 4,
                            backgroundColor: AppColors.primaryExtraLight,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          "Signing In...",
                          style: TextStyle(
                            color: AppColors.darkGrey,
                            fontSize: isSmallScreen
                                ? AppText.bodySmall
                                : AppText.bodyMedium,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppFonts.plusJakartaSans,
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

  Widget _buildBannerSection(double screenWidth, bool isSmallScreen) {
    final bannerHeight = isSmallScreen ? 280.0 : screenWidth * 0.45;

    return SizedBox(
      height: bannerHeight,
      width: double.infinity,
      child: Stack(
        children: [
          // Gradient Background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryDark,
                  AppColors.primary,
                  AppColors.primaryLight,
                ],
              ),
            ),
          ),

          // Background Pattern with Enhanced Overlay
          Container(
            width: double.infinity,
            height: double.infinity,
            child: CachedNetworkImage(
              imageUrl: _backgroundPattern,
              fit: BoxFit.cover,
              color:
                  AppColors.primaryDark.withOpacity(0.4), // Increased opacity
              colorBlendMode:
                  BlendMode.multiply, // Changed to multiply for better blending
            ),
          ),

          // Primary Color Overlay for Better Contrast
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withOpacity(0.3),
                  AppColors.primaryDark.withOpacity(0.5),
                ],
              ),
            ),
          ),

          // Content with Enhanced Visibility
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? AppSpacing.lg : AppSpacing.xl,
              vertical: isSmallScreen ? AppSpacing.xl : AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo and Back Button Row with Enhanced Visibility
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Enhanced Logo Container with Custom Logo
                    Container(
                      width: isSmallScreen ? 50 : 60,
                      height: isSmallScreen ? 50 : 60,
                      decoration: BoxDecoration(
                        color: AppColors.white
                            .withOpacity(0.25), // Increased opacity
                        borderRadius:
                            BorderRadius.circular(AppBorders.radiusLg),
                        border: Border.all(
                          color: AppColors.white
                              .withOpacity(0.4), // Enhanced border
                          width: 2, // Thicker border
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryDark
                                .withOpacity(0.4), // Primary shadow
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: AppColors.black
                                .withOpacity(0.2), // Additional shadow
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/logo/aspire_edge.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    if (!isSmallScreen)
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white
                              .withOpacity(0.25), // Enhanced opacity
                          borderRadius:
                              BorderRadius.circular(AppBorders.radiusLg),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryDark.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.white,
                            size: 22,
                          ),
                        ),
                      ),
                  ],
                ),

                // Enhanced Banner Text Content with Shadows
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Title with Text Shadow
                    Stack(
                      children: [
                        // Text Shadow
                        Text(
                          "Welcome Back",
                          style: TextStyle(
                            fontSize: isSmallScreen
                                ? AppText.headlineSmall
                                : AppText.headlineLarge,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark
                                .withOpacity(0.3), // Shadow color
                            fontFamily: AppFonts.plusJakartaSans,
                            height: 1.1,
                          ),
                        ),
                        // Main Text
                        Text(
                          "Welcome Back",
                          style: TextStyle(
                            fontSize: isSmallScreen
                                ? AppText.headlineSmall
                                : AppText.headlineLarge,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                            fontFamily: AppFonts.plusJakartaSans,
                            height: 1.1,
                            shadows: [
                              Shadow(
                                color: AppColors.primaryDark
                                    .withOpacity(0.5), // Text shadow
                                blurRadius: 8,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                        height: isSmallScreen ? AppSpacing.sm : AppSpacing.md),

                    // Enhanced Subtitle Container
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            isSmallScreen ? AppSpacing.md : AppSpacing.lg,
                        vertical: isSmallScreen ? AppSpacing.sm : AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white
                            .withOpacity(0.2), // Enhanced background
                        borderRadius:
                            BorderRadius.circular(AppBorders.radiusLg),
                        border: Border.all(
                          color: AppColors.white
                              .withOpacity(0.4), // Enhanced border
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary
                                .withOpacity(0.3), // Primary color shadow
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: AppColors.black
                                .withOpacity(0.15), // Additional depth
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.star_rounded,
                              color: AppColors.white,
                              size: isSmallScreen ? 16 : 18,
                            ),
                          ),
                          SizedBox(
                              width: isSmallScreen
                                  ? AppSpacing.sm
                                  : AppSpacing.md),
                          Text(
                            "Continue your career journey",
                            style: TextStyle(
                              fontSize: isSmallScreen
                                  ? AppText.bodySmall
                                  : AppText.bodyMedium,
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppFonts.plusJakartaSans,
                              shadows: [
                                Shadow(
                                  color: AppColors.primaryDark.withOpacity(0.4),
                                  blurRadius: 4,
                                  offset: const Offset(1, 1),
                                ),
                              ],
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

          // Additional Gradient Overlay for Top Section
          Container(
            width: double.infinity,
            height: bannerHeight * 0.3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryDark.withOpacity(0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Additional Gradient Overlay for Bottom Section
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: bannerHeight * 0.4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.primaryDark.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryExtraLight,
            borderRadius: BorderRadius.circular(AppBorders.radiusMd),
          ),
          child: Text(
            "SIGN IN",
            style: TextStyle(
              fontSize: AppText.labelSmall,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              fontFamily: AppFonts.plusJakartaSans,
              letterSpacing: 1.2,
            ),
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Text(
          "Login to Your Account",
          style: TextStyle(
            fontSize:
                isSmallScreen ? AppText.headlineMedium : AppText.headlineLarge,
            fontWeight: FontWeight.w800,
            color: AppColors.black,
            fontFamily: AppFonts.plusJakartaSans,
            height: 1.1,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          "Enter your credentials to access your personalized career dashboard",
          style: TextStyle(
            fontSize: isSmallScreen ? AppText.bodyMedium : AppText.bodyLarge,
            color: AppColors.black60,
            fontWeight: FontWeight.w500,
            fontFamily: AppFonts.plusJakartaSans,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(bool isSmallScreen, bool isLargeScreen) {
    final cardPadding = isSmallScreen ? AppSpacing.lg : AppSpacing.xl;

    return Container(
      width: isLargeScreen ? 500 : double.infinity,
      margin: isLargeScreen
          ? const EdgeInsets.symmetric(horizontal: AppSpacing.xl)
          : null,
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppBorders.radiusXl),
        border: Border.all(
          color: AppColors.black10,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Login Form
          LogInForm(
            formKey: _formKey,
            emailController: _emailController,
            passwordController: _passwordController,
            obscurePassword: _obscurePassword,
            onTogglePasswordVisibility: _togglePasswordVisibility,
          ),
          SizedBox(height: isSmallScreen ? AppSpacing.lg : AppSpacing.xl),

          // Forgot Password
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryExtraLight,
                  AppColors.primaryExtraLight.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(AppBorders.radiusLg),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(
                    context, chooseVerificationMethodScreenRoute);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorders.radiusLg),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_reset_rounded,
                    size: isSmallScreen ? 18 : 20,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: isSmallScreen
                          ? AppText.bodyMedium
                          : AppText.bodyLarge,
                      fontFamily: AppFonts.plusJakartaSans,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: isSmallScreen ? AppSpacing.lg : AppSpacing.xl),

          // Login Button
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppBorders.radiusLg),
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: isSmallScreen ? 56 : 60,
              child: ElevatedButton(
                onPressed: _loginUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: AppColors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppBorders.radiusLg),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.login_rounded,
                      size: isSmallScreen ? 20 : 22,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      "Sign In to AspireEdge",
                      style: TextStyle(
                        fontSize: isSmallScreen
                            ? AppText.bodyLarge
                            : AppText.titleSmall,
                        fontWeight: FontWeight.w800,
                        fontFamily: AppFonts.plusJakartaSans,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(AppBorders.radiusLg),
        border: Border.all(color: AppColors.black10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "New to AspireEdge?",
            style: TextStyle(
              color: AppColors.black60,
              fontSize: isSmallScreen ? AppText.bodyMedium : AppText.bodyLarge,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.plusJakartaSans,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
              ),
              borderRadius: BorderRadius.circular(AppBorders.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, signUpScreenRoute);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorders.radiusMd),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    "Join Now",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: isSmallScreen
                          ? AppText.bodyMedium
                          : AppText.bodyLarge,
                      fontFamily: AppFonts.plusJakartaSans,
                    ),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: isSmallScreen ? 16 : 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
