import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppInputThemes {
  static InputDecorationTheme get lightInputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: Color.alphaBlend(
          AppColors.lightGrey.withAlpha(153), Colors.transparent),
      contentPadding: const EdgeInsets.all(AppSpacing.md),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorders.radiusMd),
        borderSide: BorderSide.none,
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
        borderSide: BorderSide.none,
      ),
      labelStyle: TextStyle(
        color: Color.alphaBlend(
            AppColors.black.withAlpha(153), Colors.transparent),
        fontSize: AppText.bodyMedium,
      ),
      hintStyle: TextStyle(
        color: Color.alphaBlend(
            AppColors.black.withAlpha(102), Colors.transparent),
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
      fillColor: Color.alphaBlend(
          AppColors.darkSurface.withAlpha(204), Colors.transparent),
      contentPadding: const EdgeInsets.all(AppSpacing.md),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorders.radiusMd),
        borderSide: BorderSide.none,
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
        borderSide: BorderSide.none,
      ),
      labelStyle: TextStyle(
        color: Color.alphaBlend(
            AppColors.white.withAlpha(178), Colors.transparent),
        fontSize: AppText.bodyMedium,
      ),
      hintStyle: TextStyle(
        color: Color.alphaBlend(
            AppColors.white.withAlpha(128), Colors.transparent),
        fontSize: AppText.bodyMedium,
      ),
      errorStyle: const TextStyle(
        color: AppColors.error,
        fontSize: AppText.labelSmall,
      ),
    );
  }

  static OutlineInputBorder get outlineInputBorder {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppBorders.radiusMd),
      borderSide: BorderSide.none,
    );
  }

  static OutlineInputBorder get focusedOutlineInputBorder {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppBorders.radiusMd),
      borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
    );
  }

  static OutlineInputBorder get errorOutlineInputBorder {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppBorders.radiusMd),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    );
  }

  static OutlineInputBorder secondaryOutlineInputBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppBorders.radiusMd),
      borderSide: BorderSide(
        color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.15),
        width: 1.5,
      ),
    );
  }
}

// Add this extension to your theme file
extension InputBorderExtension on BuildContext {
  OutlineInputBorder get secondaryOutlineInputBorder {
    return AppInputThemes.secondaryOutlineInputBorder(this);
  }
}
