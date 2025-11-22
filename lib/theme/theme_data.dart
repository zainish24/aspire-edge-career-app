import 'package:flutter/material.dart';
import 'app_theme.dart';

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

class AppScrollbarThemes {
  static ScrollbarThemeData get scrollbarTheme {
    return ScrollbarThemeData(
      trackColor: WidgetStateProperty.all(AppColors.primary),
      thumbColor: WidgetStateProperty.all(AppColors.primary.withOpacity(0.7)),
      thickness: WidgetStateProperty.all(6.0),
      radius: const Radius.circular(AppBorders.radiusSm),
      crossAxisMargin: 2.0,
    );
  }
}

class AppDataTableThemes {
  static DataTableThemeData get lightDataTableTheme {
    return DataTableThemeData(
      columnSpacing: AppSpacing.xl,
      headingRowColor: WidgetStateProperty.all(AppColors.lightGrey),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppBorders.radiusMd),
        border: Border.all(color: AppColors.lightGrey),
      ),
      dataTextStyle: TextStyle(
        fontSize: AppText.bodySmall,
        fontWeight: FontWeight.w500,
        color: AppColors.black,
      ),
      headingTextStyle: TextStyle(
        fontSize: AppText.bodyMedium,
        fontWeight: FontWeight.w600,
        color: AppColors.black,
      ),
    );
  }
  
  static DataTableThemeData get darkDataTableTheme {
    return DataTableThemeData(
      columnSpacing: AppSpacing.xl,
      headingRowColor: WidgetStateProperty.all(AppColors.darkGrey),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppBorders.radiusMd),
        border: Border.all(color: AppColors.darkGrey),
      ),
      dataTextStyle: TextStyle(
        fontSize: AppText.bodySmall,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
      ),
      headingTextStyle: TextStyle(
        fontSize: AppText.bodyMedium,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
    );
  }
}