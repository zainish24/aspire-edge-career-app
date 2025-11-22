import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

// Font Family
class AppFonts {
  static const String grandisExtended = "Grandis Extended";
  static const String plusJakartaSans = "Plus Jakarta Sans";
}

// Color Constants - Updated to match new structure
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF7B61FF);
  static const Color primaryLight = Color(0xFF9581FF);
  static const Color primaryDark = Color(0xFF6C56DD);
  static const Color primaryExtraLight = Color(0xFFEFECFF);
  
  // Primary Material Color
  static const MaterialColor primaryMaterial = MaterialColor(0xFF9581FF, <int, Color>{
    50: Color(0xFFEFECFF),
    100: Color(0xFFD7D0FF),
    200: Color(0xFFBDB0FF),
    300: Color(0xFFA390FF),
    400: Color(0xFF8F79FF),
    500: Color(0xFF7B61FF),
    600: Color(0xFF7359FF),
    700: Color(0xFF684FFF),
    800: Color(0xFF5E45FF),
    900: Color(0xFF6C56DD),
  });

  // Black Colors
  static const Color black = Color(0xFF16161E);
  static const Color black80 = Color(0xFF45454B);
  static const Color black60 = Color(0xFF737378);
  static const Color black40 = Color(0xFFA2A2A5);
  static const Color black20 = Color(0xFFD0D0D2);
  static const Color black10 = Color(0xFFE8E8E9);
  static const Color black5 = Color(0xFFF3F3F4);

  // White Colors
  static const Color white = Colors.white;
  static const Color white80 = Color(0xFFCCCCCC);
  static const Color white60 = Color(0xFF999999);
  static const Color white40 = Color(0xFF666666);
  static const Color white20 = Color(0xFF333333);
  static const Color white10 = Color(0xFF191919);
  static const Color white5 = Color(0xFF0D0D0D);

  // Grey Colors
  static const Color grey = Color(0xFFB8B5C3);
  static const Color lightGrey = Color(0xFFF8F8F9);
  static const Color darkGrey = Color(0xFF1C1C25);
  
  // Semantic Colors
  static const Color success = Color(0xFF2ED573);
  static const Color warning = Color(0xFFFFBE21);
  static const Color error = Color(0xFFEA5B5B);

  // Background Colors
  static const Color lightBackground = Color(0xFFF8F8F9);
  static const Color darkBackground = Color(0xFF1C1C25);

  // Surface Colors
  static const Color lightSurface = Colors.white;
  static const Color darkSurface = Color(0xFF1C1C25);
}

// Spacing Constants
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  
  // Legacy spacing (for backward compatibility)
  static const double defaultPadding = 16.0;
}

// Border Constants
class AppBorders {
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  
  // Legacy border radius (for backward compatibility)
  static const double defaultBorderRadius = 12.0;
}

// Duration Constants
class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  
  // Legacy duration (for backward compatibility)
  static const Duration defaultDuration = Duration(milliseconds: 300);
}



// Form Validators
class AppValidators {
  static final passwordValidator = MultiValidator([
    RequiredValidator(errorText: 'Password is required'),
    MinLengthValidator(8, errorText: 'Password must be at least 8 digits long'),
    PatternValidator(
      r'(?=.*?[#?!@$%^&*-])',
      errorText: 'Password must have at least one special character'
    )
  ]);

  static final emailValidator = MultiValidator([
    RequiredValidator(errorText: 'Email is required'),
    EmailValidator(errorText: "Enter a valid email address"),
  ]);

  static const String passwordNotMatchError = "Passwords do not match";
}

class AppConstants {
  static const String cloudinaryCloudName = 'YOUR_CLOUD_NAME';
  static const String cloudinaryUploadPreset = 'YOUR_UPLOAD_PRESET';
}

// Storage Keys
class AppStorageKeys {
  static const String recentSearches = 'recent_searches';
  static const int maxRecentSearches = 5;
}

// Text Constants (for consistency with your new theme)
class AppText {
  // Font Sizes
  static const double displayLarge = 57.0;
  static const double displayMedium = 45.0;
  static const double displaySmall = 36.0;
  static const double headlineLarge = 32.0;
  static const double headlineMedium = 28.0;
  static const double headlineSmall = 24.0;
  static const double titleLarge = 22.0;
  static const double titleMedium = 18.0;
  static const double titleSmall = 14.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
  static const double labelLarge = 14.0;
  static const double labelMedium = 12.0;
  static const double labelSmall = 11.0;
}

// Legacy constants for backward compatibility
// (These can be gradually phased out as you update your codebase)
const Color primaryColor = AppColors.primary;
const MaterialColor primaryMaterialColor = AppColors.primaryMaterial;
const Color blackColor = AppColors.black;
const Color blackColor80 = AppColors.black80;
const Color blackColor60 = AppColors.black60;
const Color blackColor40 = AppColors.black40;
const Color blackColor20 = AppColors.black20;
const Color blackColor10 = AppColors.black10;
const Color blackColor5 = AppColors.black5;
const Color whiteColor = AppColors.white;
const Color whileColor80 = AppColors.white80;
const Color whileColor60 = AppColors.white60;
const Color whileColor40 = AppColors.white40;
const Color whileColor20 = AppColors.white20;
const Color whileColor10 = AppColors.white10;
const Color whileColor5 = AppColors.white5;
const Color greyColor = AppColors.grey;
const Color lightGreyColor = AppColors.lightGrey;
const Color darkGreyColor = AppColors.darkGrey;
const Color purpleColor = AppColors.primary;
const Color successColor = AppColors.success;
const Color warningColor = AppColors.warning;
const Color errorColor = AppColors.error;
const double defaultPadding = AppSpacing.defaultPadding;
const double defaultBorderRadious = AppBorders.defaultBorderRadius;
const Duration defaultDuration = AppDurations.defaultDuration;
final passwordValidator = AppValidators.passwordValidator;
final emaildValidator = AppValidators.emailValidator;
const pasNotMatchErrorText = AppValidators.passwordNotMatchError;
const String kRecentSearchesKey = AppStorageKeys.recentSearches;
const int kMaxRecentSearches = AppStorageKeys.maxRecentSearches;