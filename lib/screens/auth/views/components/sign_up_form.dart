// components/sign_up_form.dart
import 'package:flutter/material.dart';
import '/../constants.dart';

class SignUpForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final String? tierValue;
  final Function(String?) onTierChanged;
  final List<String> tierOptions;
  final String role;

  const SignUpForm({
    Key? key,
    required this.formKey,
    required this.emailController,
    required this.nameController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.tierValue,
    required this.onTierChanged,
    required this.tierOptions,
    required this.role,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Form(
      key: formKey,
      child: Column(
        children: [
          // Name Field
          _buildFormField(
            controller: nameController,
            label: "FULL NAME",
            icon: Icons.person_rounded,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.lg),

          // Email Field
          _buildFormField(
            controller: emailController,
            label: "EMAIL ADDRESS",
            icon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email address';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.lg),

          // Phone Field
          _buildFormField(
            controller: phoneController,
            label: "PHONE NUMBER",
            icon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.lg),

          // Tier Selection
          _buildTierSelection(isSmallScreen),
          SizedBox(height: AppSpacing.lg),

          // Password Field
          _buildPasswordField(
            controller: passwordController,
            label: "PASSWORD",
            isConfirm: false,
          ),
          SizedBox(height: AppSpacing.lg),

          // Confirm Password Field
          _buildPasswordField(
            controller: confirmPasswordController,
            label: "CONFIRM PASSWORD",
            isConfirm: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(AppBorders.radiusLg),
        border: Border.all(color: AppColors.black10),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          color: AppColors.black,
          fontSize: AppText.bodyMedium,
          fontWeight: FontWeight.w500,
          fontFamily: AppFonts.plusJakartaSans,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: AppColors.black60,
            fontSize: AppText.labelSmall,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            fontFamily: AppFonts.plusJakartaSans,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.sm),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildTierSelection(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "SELECT YOUR TIER",
          style: TextStyle(
            color: AppColors.black60,
            fontSize: AppText.labelSmall,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            fontFamily: AppFonts.plusJakartaSans,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.lightBackground,
            borderRadius: BorderRadius.circular(AppBorders.radiusLg),
            border: Border.all(color: AppColors.black10),
          ),
          child: DropdownButtonFormField<String>(
            value: tierValue,
            onChanged: onTierChanged,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.sm),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
            items: tierOptions.map((String tier) {
              return DropdownMenuItem<String>(
                value: tier,
                child: Text(
                  tier.toUpperCase(),
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: AppText.bodyMedium,
                    fontWeight: FontWeight.w500,
                    fontFamily: AppFonts.plusJakartaSans,
                  ),
                ),
              );
            }).toList(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your tier';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isConfirm,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(AppBorders.radiusLg),
        border: Border.all(color: AppColors.black10),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: true,
        style: TextStyle(
          color: AppColors.black,
          fontSize: AppText.bodyMedium,
          fontWeight: FontWeight.w500,
          fontFamily: AppFonts.plusJakartaSans,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: AppColors.black60,
            fontSize: AppText.labelSmall,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            fontFamily: AppFonts.plusJakartaSans,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.sm),
            child: Icon(
              Icons.lock_rounded,
              color: AppColors.primary,
              size: 20,
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
          if (isConfirm && value != passwordController.text) {
            return 'Passwords do not match';
          }
          return null;
        },
      ),
    );
  }
}