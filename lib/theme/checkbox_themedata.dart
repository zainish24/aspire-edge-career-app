import 'package:flutter/material.dart';
import 'app_theme.dart';

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