// sign_up_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/../constants.dart';
import '/../routes/route_constants.dart';
import '/../models/user_model.dart';
import 'login_screen.dart';
import 'components/sign_up_form.dart';
import 'terms_of_services_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? _selectedTier;
  bool _isTermsAccepted = false;
  String? _termsError;
  bool _loading = false;

  /// Tier options for user selection
  final List<String> _tierOptions = ["student", "professional", "graduate"];
  final String _role = "user";

  // Career-focused Unsplash images matching your theme
  final String _backgroundPattern =
      "https://images.unsplash.com/photo-1552664730-d307ca884978?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80";

  Future<void> _validateAndContinue() async {
    setState(() {
      _termsError = _isTermsAccepted ? null : "Please accept Terms of Service";
    });

    if (!_isTermsAccepted) {
      return;
    }

    if (_selectedTier == null) {
      _showCustomDialog(context, "Please select your tier", isError: true);
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _loading = true);

    try {
      // Firebase Auth
      UserCredential authuser = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim());

      // Create UserModel and save to Firestore
      final userModel = UserModel(
        userId: authuser.user!.uid,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        role: _role,
        tier: _selectedTier,
        profilePic: "",
        bookmarks: [],
        createdAt: DateTime.now(),
        isActive: true,
      );

      await FirebaseFirestore.instance
          .collection("users")
          .doc(authuser.user!.uid)
          .set(userModel.toMap());

      _showCustomDialog(context, "Account created successfully!",
          isError: false);

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    } on FirebaseAuthException catch (e) {
      String message = "Registration failed";
      if (e.code == 'email-already-in-use') {
        message = "Email is already registered";
      } else if (e.code == 'weak-password') {
        message = "Password is too weak";
      }
      _showCustomDialog(context, message, isError: true);
    } catch (e) {
      _showCustomDialog(context, "Error: ${e.toString()}", isError: true);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
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
                              (isSmallScreen ? 300 : screenWidth * 0.5),
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

                              // SignUp Form Card
                              _buildSignUpCard(isSmallScreen, isLargeScreen),

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
                          "Creating Account...",
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
    final bannerHeight = isSmallScreen ? 300.0 : screenWidth * 0.5;

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
              colorBlendMode: BlendMode.multiply, // Better blending
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
                  AppColors.primary.withOpacity(0.4),
                  AppColors.primaryDark.withOpacity(0.6),
                ],
              ),
            ),
          ),

          // Floating Elements with Enhanced Visibility
          if (!isSmallScreen)
            Positioned(
              top: 60,
              right: 40,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.25), // Enhanced opacity
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.white.withOpacity(0.4), // Enhanced border
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark
                          .withOpacity(0.4), // Primary shadow
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color:
                          AppColors.black.withOpacity(0.2), // Additional shadow
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.work_outline_rounded,
                  color: AppColors.white,
                  size: 40,
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
                // Enhanced Logo and Back Button Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Enhanced Logo Container with Custom Logo
                    Container(
                      width: isSmallScreen ? 60 : 70,
                      height: isSmallScreen ? 60 : 70,
                      decoration: BoxDecoration(
                        color: AppColors.white
                            .withOpacity(0.25), // Increased opacity
                        borderRadius:
                            BorderRadius.circular(AppBorders.radiusLg),
                        border: Border.all(
                          color: AppColors.white
                              .withOpacity(0.4), // Enhanced border
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryDark
                                .withOpacity(0.5), // Primary shadow
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                          BoxShadow(
                            color: AppColors.black
                                .withOpacity(0.25), // Additional shadow
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
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
                              blurRadius: 12,
                              offset: const Offset(0, 4),
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

                // Enhanced Banner Text Content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Title with Enhanced Visibility
                    Stack(
                      children: [
                        // Text Shadow for Depth
                        Text(
                          "Start Your Journey",
                          style: TextStyle(
                            fontSize: isSmallScreen
                                ? AppText.headlineMedium
                                : AppText.displaySmall,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark.withOpacity(0.4),
                            fontFamily: AppFonts.plusJakartaSans,
                            height: 1.1,
                          ),
                        ),
                        // Main Text with Shadow
                        Text(
                          "Start Your Journey",
                          style: TextStyle(
                            fontSize: isSmallScreen
                                ? AppText.headlineMedium
                                : AppText.displaySmall,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                            fontFamily: AppFonts.plusJakartaSans,
                            height: 1.1,
                            shadows: [
                              Shadow(
                                color: AppColors.primaryDark
                                    .withOpacity(0.6), // Enhanced shadow
                                blurRadius: 12,
                                offset: const Offset(3, 3),
                              ),
                              Shadow(
                                color: AppColors.black
                                    .withOpacity(0.3), // Additional shadow
                                blurRadius: 6,
                                offset: const Offset(1, 1),
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
                            .withOpacity(0.22), // Enhanced background
                        borderRadius:
                            BorderRadius.circular(AppBorders.radiusLg),
                        border: Border.all(
                          color: AppColors.white
                              .withOpacity(0.45), // Enhanced border
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary
                                .withOpacity(0.4), // Enhanced primary shadow
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                          BoxShadow(
                            color: AppColors.black
                                .withOpacity(0.2), // Depth shadow
                            blurRadius: 8,
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
                              color: AppColors.white.withOpacity(
                                  0.35), // Enhanced icon background
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.people_alt_rounded,
                              color: AppColors.white,
                              size: isSmallScreen ? 16 : 18,
                            ),
                          ),
                          SizedBox(
                              width: isSmallScreen
                                  ? AppSpacing.sm
                                  : AppSpacing.md),
                          Text(
                            "Join 10,000+ Career Seekers",
                            style: TextStyle(
                              fontSize: isSmallScreen
                                  ? AppText.bodySmall
                                  : AppText.bodyMedium,
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppFonts.plusJakartaSans,
                              shadows: [
                                Shadow(
                                  color: AppColors.primaryDark
                                      .withOpacity(0.5), // Text shadow
                                  blurRadius: 6,
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

          // Top Gradient Overlay
          Container(
            width: double.infinity,
            height: bannerHeight * 0.35,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryDark.withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Bottom Gradient Overlay
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: bannerHeight * 0.45,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.primaryDark.withOpacity(0.6),
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
            "CREATE ACCOUNT",
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
          "Join AspireEdge Community",
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
          "Create your account and unlock personalized career guidance and opportunities",
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

  Widget _buildSignUpCard(bool isSmallScreen, bool isLargeScreen) {
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
          // SignUp Form with Tier Selection
          SignUpForm(
            formKey: _formKey,
            emailController: emailController,
            nameController: nameController,
            phoneController: phoneController,
            passwordController: passwordController,
            confirmPasswordController: confirmPasswordController,
            tierValue: _selectedTier,
            onTierChanged: (val) {
              setState(() => _selectedTier = val);
            },
            tierOptions: _tierOptions,
            role: _role,
          ),
          SizedBox(height: isSmallScreen ? AppSpacing.lg : AppSpacing.xl),

          // Terms & Conditions
          _buildTermsSection(isSmallScreen),
          SizedBox(height: isSmallScreen ? AppSpacing.lg : AppSpacing.xl),

          // Sign Up Button
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
                onPressed: _validateAndContinue,
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
                      Icons.person_add_alt_1_rounded,
                      size: isSmallScreen ? 20 : 22,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      "Create My Account",
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

  Widget _buildTermsSection(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primaryExtraLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppBorders.radiusLg),
        border: Border.all(
          color: _termsError != null
              ? AppColors.error.withOpacity(0.3)
              : AppColors.black10,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _isTermsAccepted ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(AppBorders.radiusSm),
              border: Border.all(
                color: _isTermsAccepted ? AppColors.primary : AppColors.black40,
                width: 2,
              ),
            ),
            child: Checkbox(
              value: _isTermsAccepted,
              onChanged: (val) {
                setState(() {
                  _isTermsAccepted = val ?? false;
                  _termsError = null;
                });
              },
              activeColor: Colors.transparent,
              checkColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorders.radiusSm),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: "I agree to the ",
                    style: TextStyle(
                      color: AppColors.black80,
                      fontSize: isSmallScreen
                          ? AppText.bodySmall
                          : AppText.bodyMedium,
                      fontWeight: FontWeight.w500,
                      fontFamily: AppFonts.plusJakartaSans,
                    ),
                    children: [
                      TextSpan(
                        text: "Terms of Service ",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TermsOfServicesScreen(
                                  onAccepted: () {
                                    setState(() {
                                      _isTermsAccepted = true;
                                      _termsError = null;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            );
                          },
                      ),
                      const TextSpan(text: "and "),
                      TextSpan(
                        text: "Privacy Policy",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Navigate to privacy policy
                          },
                      ),
                    ],
                  ),
                ),
                if (_termsError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.error,
                          size: isSmallScreen ? 14 : 16,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          _termsError!,
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: isSmallScreen
                                ? AppText.labelSmall
                                : AppText.bodySmall,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppFonts.plusJakartaSans,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
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
            "Already have an account?",
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
                Navigator.pushNamed(context, logInScreenRoute);
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
                  Icon(
                    Icons.login_rounded,
                    size: isSmallScreen ? 16 : 18,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    "Sign In",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}