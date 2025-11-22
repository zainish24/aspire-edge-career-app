import 'package:flutter/material.dart';

// Color Constants - Based on the Education App Image
class AppColors {
  // Primary Colors (From the image - blue shades)
  static const Color primary = Color(0xFF7B61FF);
  static const Color primaryLight = Color(0xFF9581FF);
  static const Color primaryDark = Color(0xFF6C56DD);
  static const Color primaryExtraLight = Color(0xFFEFECFF);
  
  // Secondary Colors (Orange accents from buttons and icons)
  static const Color secondary = Color(0xFFFF9F43); // Vibrant orange
  static const Color secondaryLight = Color(0xFFFFBf75); // Lighter orange
  static const Color secondaryDark = Color(0xFFE87F10); // Darker orange
  
  // Neutral Colors
  static const Color black = Color(0xFF2D3436);
  static const Color darkGrey = Color(0xFF636E72);
  static const Color grey = Color(0xFFB2BEC3);
  static const Color lightGrey = Color(0xFFDFE6E9);
  static const Color white = Color(0xFFFFFFFF);
  
  // Background Colors (From the image)
  static const Color lightBackground = Color(0xFFF5F6FA);
  static const Color darkBackground = Color(0xFF19212C);
  
  // Surface Colors
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color darkSurface = Color(0xFF222D3A);
  
  // Semantic Colors
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFD63031);
  static const Color info = Color(0xFF0984E3);

  static Color? get black60 => null;
}

// Text Constants
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

// Spacing Constants
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// Border Constants
class AppBorders {
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
}

// Shadows
class AppShadows {
  static const List<BoxShadow> lightShadow = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];
  
  static const List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
  
  static const List<BoxShadow> largeShadow = [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
  
  static const List<BoxShadow> darkShadow = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];
}

// Button Themes
class AppButtonThemes {
  static ButtonStyle get elevatedButtonLight {
    return ElevatedButton.styleFrom(
      foregroundColor: AppColors.white,
      backgroundColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      textStyle: TextStyle(
        fontSize: AppText.bodyLarge,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorders.radiusMd),
      ),
      elevation: 2,
      shadowColor: Colors.transparent,
    ).copyWith(
      backgroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return AppColors.primaryDark;
          } else if (states.contains(WidgetState.disabled)) {
            return AppColors.grey;
          }
          return AppColors.primary;
        },
      ),
    );
  }
  
  static ButtonStyle get elevatedButtonDark {
    return ElevatedButton.styleFrom(
      foregroundColor: AppColors.white,
      backgroundColor: AppColors.primaryLight,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      textStyle: TextStyle(
        fontSize: AppText.bodyLarge,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorders.radiusMd),
      ),
      elevation: 2,
      shadowColor: Colors.transparent,
    ).copyWith(
      backgroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return AppColors.primary;
          } else if (states.contains(WidgetState.disabled)) {
            return Color.alphaBlend(AppColors.grey.withAlpha(128), AppColors.primaryLight);
          }
          return AppColors.primaryLight;
        },
      ),
    );
  }
  
  static ButtonStyle get textButtonLight {
    return TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      textStyle: TextStyle(
        fontSize: AppText.bodyMedium,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorders.radiusSm),
      ),
    ).copyWith(
      foregroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return AppColors.primaryDark;
          } else if (states.contains(WidgetState.disabled)) {
            return AppColors.grey;
          }
          return AppColors.primary;
        },
      ),
    );
  }
  
  static ButtonStyle get textButtonDark {
    return TextButton.styleFrom(
      foregroundColor: AppColors.primaryLight,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      textStyle: TextStyle(
        fontSize: AppText.bodyMedium,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorders.radiusSm),
      ),
    ).copyWith(
      foregroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return AppColors.white;
          } else if (states.contains(WidgetState.disabled)) {
            return Color.alphaBlend(AppColors.grey.withAlpha(128), AppColors.primaryLight);
          }
          return AppColors.primaryLight;
        },
      ),
    );
  }
  
  static ButtonStyle get outlinedButtonLight {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      backgroundColor: Colors.transparent,
      side: const BorderSide(color: AppColors.primary, width: 1.5),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      textStyle: TextStyle(
        fontSize: AppText.bodyLarge,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorders.radiusMd),
      ),
    ).copyWith(
      foregroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return AppColors.primaryDark;
          } else if (states.contains(WidgetState.disabled)) {
            return AppColors.grey;
          }
          return AppColors.primary;
        },
      ),
      side: WidgetStateProperty.resolveWith<BorderSide>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return const BorderSide(color: AppColors.primaryDark, width: 1.5);
          } else if (states.contains(WidgetState.disabled)) {
            return const BorderSide(color: AppColors.grey, width: 1.5);
          }
          return const BorderSide(color: AppColors.primary, width: 1.5);
        },
      ),
    );
  }
  
  static ButtonStyle get outlinedButtonDark {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.primaryLight,
      backgroundColor: Colors.transparent,
      side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      textStyle: TextStyle(
        fontSize: AppText.bodyLarge,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorders.radiusMd),
      ),
    ).copyWith(
      foregroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return AppColors.white;
          } else if (states.contains(WidgetState.disabled)) {
            return Color.alphaBlend(AppColors.grey.withAlpha(128), AppColors.primaryLight);
          }
          return AppColors.primaryLight;
        },
      ),
      side: WidgetStateProperty.resolveWith<BorderSide>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return const BorderSide(color: AppColors.white, width: 1.5);
          } else if (states.contains(WidgetState.disabled)) {
            return const BorderSide(color: AppColors.grey, width: 1.5);
          }
          return const BorderSide(color: AppColors.primaryLight, width: 1.5);
        },
      ),
    );
  }
}

// Input Decoration Themes
class AppInputThemes {
  static InputDecorationTheme get lightInputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.all(AppSpacing.md),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorders.radiusMd),
        borderSide: const BorderSide(color: AppColors.lightGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorders.radiusMd),
        borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorders.radiusMd),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorders.radiusMd),
        borderSide: const BorderSide(color: AppColors.error, width: 2.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorders.radiusMd),
        borderSide: const BorderSide(color: AppColors.lightGrey),
      ),
      labelStyle: TextStyle(
        color: AppColors.darkGrey,
        fontSize: AppText.bodyMedium,
      ),
      hintStyle: TextStyle(
        color: AppColors.grey,
        fontSize: AppText.bodyMedium,
      ),
      errorStyle: const TextStyle(
        color: AppColors.error,
        fontSize: AppText.labelSmall,
      ),
    );
  }
  
  static InputDecorationTheme get darkInputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      contentPadding: const EdgeInsets.all(AppSpacing.md),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorders.radiusMd),
        borderSide: BorderSide(color: AppColors.darkGrey.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorders.radiusMd),
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorders.radiusMd),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorders.radiusMd),
        borderSide: const BorderSide(color: AppColors.error, width: 2.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorders.radiusMd),
        borderSide: BorderSide(color: AppColors.darkGrey.withOpacity(0.5)),
      ),
      labelStyle: TextStyle(
        color: AppColors.lightGrey,
        fontSize: AppText.bodyMedium,
      ),
      hintStyle: TextStyle(
        color: AppColors.grey,
        fontSize: AppText.bodyMedium,
      ),
      errorStyle: const TextStyle(
        color: AppColors.error,
        fontSize: AppText.labelSmall,
      ),
    );
  }
}

// Checkbox Themes
class AppCheckboxThemes {
  static CheckboxThemeData get lightCheckboxTheme {
    return CheckboxThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorders.radiusSm),
      ),
      side: WidgetStateBorderSide.resolveWith(
        (states) => const BorderSide(width: 1.5, color: AppColors.grey),
      ),
      checkColor: WidgetStateProperty.all(AppColors.white),
      fillColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        },
      ),
    );
  }
  
  static CheckboxThemeData get darkCheckboxTheme {
    return CheckboxThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorders.radiusSm),
      ),
      side: WidgetStateBorderSide.resolveWith(
        (states) => BorderSide(width: 1.5, color: Color.alphaBlend(AppColors.grey.withAlpha(178), Colors.transparent)),
      ),
      checkColor: WidgetStateProperty.all(AppColors.white),
      fillColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLight;
          }
          return Colors.transparent;
        },
      ),
    );
  }
}

// AppBar Themes
class AppAppBarThemes {
  static AppBarTheme get lightAppBarTheme {
    return AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.black,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.black,
        fontSize: AppText.headlineSmall,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: const IconThemeData(color: AppColors.black),
      actionsIconTheme: const IconThemeData(color: AppColors.black),
    );
  }
  
  static AppBarTheme get darkAppBarTheme {
    return AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.white,
        fontSize: AppText.headlineSmall,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: const IconThemeData(color: AppColors.white),
      actionsIconTheme: const IconThemeData(color: AppColors.white),
    );
  }
}

// Card Themes
class AppCardThemes {
  static CardTheme get lightCardTheme {
    return const CardTheme(
      color: AppColors.white,
      shadowColor: Color(0x1A000000),
      surfaceTintColor: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppBorders.radiusLg)),
      ),
      margin: EdgeInsets.all(AppSpacing.sm),
    );
  }
  
  static CardTheme get darkCardTheme {
    return const CardTheme(
      color: AppColors.darkSurface,
      shadowColor: Color(0x4D000000),
      surfaceTintColor: AppColors.darkSurface,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppBorders.radiusLg)),
      ),
      margin: EdgeInsets.all(AppSpacing.sm),
    );
  }
}

// Dialog Themes
class AppDialogThemes {
  static DialogTheme get lightDialogTheme {
    return const DialogTheme(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppBorders.radiusXl)),
      ),
      titleTextStyle: TextStyle(
        color: AppColors.black,
        fontSize: AppText.headlineSmall,
        fontWeight: FontWeight.w700,
      ),
      contentTextStyle: TextStyle(
        color: Color(0x8D000000),
        fontSize: AppText.bodyMedium,
      ),
    );
  }
  
  static DialogTheme get darkDialogTheme {
    return const DialogTheme(
      backgroundColor: AppColors.darkSurface,
      surfaceTintColor: AppColors.darkSurface,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppBorders.radiusXl)),
      ),
      titleTextStyle: TextStyle(
        color: AppColors.white,
        fontSize: AppText.headlineSmall,
        fontWeight: FontWeight.w700,
      ),
      contentTextStyle: TextStyle(
        color: Color(0xB3FFFFFF),
        fontSize: AppText.bodyMedium,
      ),
    );
  }
}

// Complete App Theme
class AppTheme {
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: "Poppins", // Changed to Poppins which is commonly used in education apps
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryLight,
        surface: AppColors.lightSurface,
        background: AppColors.lightBackground,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.black,
        onBackground: AppColors.black,
        onError: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      iconTheme: const IconThemeData(color: AppColors.black),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: AppText.displayLarge,
          fontWeight: FontWeight.w800,
          color: AppColors.black,
          letterSpacing: -1.5,
        ),
        displayMedium: TextStyle(
          fontSize: AppText.displayMedium,
          fontWeight: FontWeight.w700,
          color: AppColors.black,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontSize: AppText.displaySmall,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
        headlineLarge: TextStyle(
          fontSize: AppText.headlineLarge,
          fontWeight: FontWeight.w700,
          color: AppColors.black,
        ),
        headlineMedium: TextStyle(
          fontSize: AppText.headlineMedium,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
        headlineSmall: TextStyle(
          fontSize: AppText.headlineSmall,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
        titleLarge: TextStyle(
          fontSize: AppText.titleLarge,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
        titleMedium: TextStyle(
          fontSize: AppText.titleMedium,
          fontWeight: FontWeight.w500,
          color: AppColors.black,
        ),
        titleSmall: TextStyle(
          fontSize: AppText.titleSmall,
          fontWeight: FontWeight.w500,
          color: AppColors.black,
        ),
        bodyLarge: TextStyle(
          fontSize: AppText.bodyLarge,
          fontWeight: FontWeight.w400,
          color: AppColors.black,
        ),
        bodyMedium: TextStyle(
          fontSize: AppText.bodyMedium,
          fontWeight: FontWeight.w400,
          color: AppColors.darkGrey,
        ),
        bodySmall: TextStyle(
          fontSize: AppText.bodySmall,
          fontWeight: FontWeight.w400,
          color: AppColors.grey,
        ),
        labelLarge: TextStyle(
          fontSize: AppText.labelLarge,
          fontWeight: FontWeight.w500,
          color: AppColors.darkGrey,
        ),
        labelMedium: TextStyle(
          fontSize: AppText.labelMedium,
          fontWeight: FontWeight.w500,
          color: AppColors.grey,
        ),
        labelSmall: TextStyle(
          fontSize: AppText.labelSmall,
          fontWeight: FontWeight.w400,
          color: AppColors.grey,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: AppButtonThemes.elevatedButtonLight),
      textButtonTheme: TextButtonThemeData(style: AppButtonThemes.textButtonLight),
      outlinedButtonTheme: OutlinedButtonThemeData(style: AppButtonThemes.outlinedButtonLight),
      inputDecorationTheme: AppInputThemes.lightInputDecorationTheme,
      checkboxTheme: AppCheckboxThemes.lightCheckboxTheme,
      appBarTheme: AppAppBarThemes.lightAppBarTheme,
      // cardTheme: AppCardThemes.lightCardTheme,
      // dialogTheme: AppDialogThemes.lightDialogTheme,
      useMaterial3: true,
    );
  }

  static ThemeData darkTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: "Poppins",
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        primaryContainer: AppColors.primary,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryDark,
        surface: AppColors.darkSurface,
        background: AppColors.darkBackground,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.white,
        onBackground: AppColors.white,
        onError: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      iconTheme: const IconThemeData(color: AppColors.white),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: AppText.displayLarge,
          fontWeight: FontWeight.w800,
          color: AppColors.white,
          letterSpacing: -1.5,
        ),
        displayMedium: TextStyle(
          fontSize: AppText.displayMedium,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontSize: AppText.displaySmall,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        headlineLarge: TextStyle(
          fontSize: AppText.headlineLarge,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: AppText.headlineMedium,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        headlineSmall: TextStyle(
          fontSize: AppText.headlineSmall,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        titleLarge: TextStyle(
          fontSize: AppText.titleLarge,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        titleMedium: TextStyle(
          fontSize: AppText.titleMedium,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
        titleSmall: TextStyle(
          fontSize: AppText.titleSmall,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: AppText.bodyLarge,
          fontWeight: FontWeight.w400,
          color: AppColors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: AppText.bodyMedium,
          fontWeight: FontWeight.w400,
          color: AppColors.lightGrey,
        ),
        bodySmall: TextStyle(
          fontSize: AppText.bodySmall,
          fontWeight: FontWeight.w400,
          color: AppColors.grey,
        ),
        labelLarge: TextStyle(
          fontSize: AppText.labelLarge,
          fontWeight: FontWeight.w500,
          color: AppColors.lightGrey,
        ),
        labelMedium: TextStyle(
          fontSize: AppText.labelMedium,
          fontWeight: FontWeight.w500,
          color: AppColors.grey,
        ),
        labelSmall: TextStyle(
          fontSize: AppText.labelSmall,
          fontWeight: FontWeight.w400,
          color: AppColors.grey,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: AppButtonThemes.elevatedButtonDark),
      textButtonTheme: TextButtonThemeData(style: AppButtonThemes.textButtonDark),
      outlinedButtonTheme: OutlinedButtonThemeData(style: AppButtonThemes.outlinedButtonDark),
      inputDecorationTheme: AppInputThemes.darkInputDecorationTheme,
      checkboxTheme: AppCheckboxThemes.darkCheckboxTheme,
      appBarTheme: AppAppBarThemes.darkAppBarTheme,
      // cardTheme: AppCardThemes.darkCardTheme,
      // dialogTheme: AppDialogThemes.darkDialogTheme,
      useMaterial3: true,
    );
  }
}