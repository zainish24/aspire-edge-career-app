// components/login_form.dart
import 'package:flutter/material.dart';
import '/../constants.dart';

class LogInForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePasswordVisibility;

  const LogInForm({
    Key? key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePasswordVisibility,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Form(
      key: formKey,
      child: Column(
        children: [
          // Email Field
          Container(
            decoration: BoxDecoration(
              color: AppColors.lightBackground,
              borderRadius: BorderRadius.circular(AppBorders.radiusLg),
              border: Border.all(color: AppColors.black10),
            ),
            child: TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                fontSize: isSmallScreen ? AppText.bodyMedium : AppText.bodyLarge,
                color: AppColors.black,
                fontWeight: FontWeight.w500,
                fontFamily: AppFonts.plusJakartaSans,
              ),
              decoration: InputDecoration(
                labelText: "EMAIL ADDRESS",
                labelStyle: TextStyle(
                  color: AppColors.black60,
                  fontSize: AppText.labelSmall,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  fontFamily: AppFonts.plusJakartaSans,
                ),
                hintText: "Enter your email address",
                hintStyle: TextStyle(
                  color: AppColors.black40,
                  fontSize: isSmallScreen ? AppText.bodyMedium : AppText.bodyLarge,
                  fontFamily: AppFonts.plusJakartaSans,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: isSmallScreen ? AppSpacing.lg : AppSpacing.xl,
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.sm),
                  child: Icon(
                    Icons.email_rounded,
                    color: AppColors.primary,
                    size: isSmallScreen ? 20 : 22,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
          ),
          SizedBox(height: AppSpacing.lg),

          // Password Field
          Container(
            decoration: BoxDecoration(
              color: AppColors.lightBackground,
              borderRadius: BorderRadius.circular(AppBorders.radiusLg),
              border: Border.all(color: AppColors.black10),
            ),
            child: TextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              style: TextStyle(
                fontSize: isSmallScreen ? AppText.bodyMedium : AppText.bodyLarge,
                color: AppColors.black,
                fontWeight: FontWeight.w500,
                fontFamily: AppFonts.plusJakartaSans,
              ),
              decoration: InputDecoration(
                labelText: "PASSWORD",
                labelStyle: TextStyle(
                  color: AppColors.black60,
                  fontSize: AppText.labelSmall,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  fontFamily: AppFonts.plusJakartaSans,
                ),
                hintText: "Enter your password",
                hintStyle: TextStyle(
                  color: AppColors.black40,
                  fontSize: isSmallScreen ? AppText.bodyMedium : AppText.bodyLarge,
                  fontFamily: AppFonts.plusJakartaSans,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: isSmallScreen ? AppSpacing.lg : AppSpacing.xl,
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.sm),
                  child: Icon(
                    Icons.lock_rounded,
                    color: AppColors.primary,
                    size: isSmallScreen ? 20 : 22,
                  ),
                ),
                suffixIcon: Container(
                  margin: const EdgeInsets.only(right: AppSpacing.md),
                  child: IconButton(
                    onPressed: onTogglePasswordVisibility,
                    icon: Icon(
                      obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                      color: AppColors.black60,
                      size: isSmallScreen ? 20 : 22,
                    ),
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}