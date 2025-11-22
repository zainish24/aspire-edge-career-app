import 'package:flutter/material.dart';
import 'app_theme.dart'; // Your new constants file

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