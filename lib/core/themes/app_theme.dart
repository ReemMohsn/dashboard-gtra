import 'package:flutter/material.dart';
import 'package:gtra_dashboard/core/themes/app_color.dart';

abstract final class AppTheme {
  static const String fontFamily = 'Cairo';
  static const List<String> fontFamilyFallback = [
    'Segoe UI',
    'Tahoma',
    'Arial',
    'sans-serif',
  ];

  // Unified Spacing Tokens
  static const double spaceXs = 6;
  static const double spaceSm = 10;
  static const double spaceMd = 16;
  static const double spaceLg = 24;

  // Unified Radius Tokens
  static const double cardRadius = 16;
  static const double innerCardRadius = 12;
  static const double buttonRadius = 10;
  static const double pillRadius = 999;

  // Unified Card Shadows
  static const List<BoxShadow> cardShadows = [
    BoxShadow(
      color: AppColor.cardShadow,
      blurRadius: 14,
      offset: Offset(0, 4),
    ),
  ];

  static BoxDecoration cardDecoration({
    Color color = AppColor.surface,
    Color borderColor = AppColor.border,
    double borderWidth = 1,
    double radius = cardRadius,
    bool elevated = true,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor, width: borderWidth),
      boxShadow: elevated ? cardShadows : null,
    );
  }

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme.light(
      primary: AppColor.primary,
      secondary: AppColor.primaryDark,
      surface: AppColor.surface,
      onPrimary: AppColor.onPrimary,
      onSecondary: AppColor.onPrimary,
      onSurface: AppColor.textPrimary,
      error: AppColor.danger,
    );

    TextStyle style({
      required double size,
      required FontWeight weight,
      Color color = AppColor.textPrimary,
      double height = 1.35,
    }) {
      return TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColor.scaffoldBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColor.surface,
        foregroundColor: AppColor.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: style(size: 18, weight: FontWeight.w700),
      ),
      cardTheme: CardThemeData(
        color: AppColor.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: AppColor.border),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: style(size: 28, weight: FontWeight.w800, height: 1.2),
        headlineMedium: style(size: 22, weight: FontWeight.w700, height: 1.25),
        headlineSmall: style(size: 18, weight: FontWeight.w700, height: 1.3),
        titleLarge: style(size: 18, weight: FontWeight.w700),
        titleMedium: style(size: 15, weight: FontWeight.w700),
        titleSmall: style(size: 14, weight: FontWeight.w600),
        bodyLarge: style(
          size: 15,
          weight: FontWeight.w400,
          color: AppColor.textPrimary,
          height: 1.5,
        ),
        bodyMedium: style(
          size: 13.5,
          weight: FontWeight.w400,
          color: AppColor.textSecondary,
          height: 1.45,
        ),
        bodySmall: style(
          size: 12,
          weight: FontWeight.w400,
          color: AppColor.textMuted,
          height: 1.4,
        ),
        labelLarge: style(
          size: 14,
          weight: FontWeight.w700,
          color: AppColor.onPrimary,
        ),
        labelMedium: style(
          size: 12.5,
          weight: FontWeight.w600,
          color: AppColor.textPrimary,
        ),
        labelSmall: style(
          size: 11.5,
          weight: FontWeight.w600,
          color: AppColor.textSecondary,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColor.divider,
        thickness: 1,
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          foregroundColor: AppColor.onPrimary,
          backgroundColor: AppColor.primary,
          disabledForegroundColor: AppColor.onPrimary,
          disabledBackgroundColor: AppColor.primaryBorder,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: style(
            size: 14,
            weight: FontWeight.w700,
            color: AppColor.onPrimary,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          foregroundColor: AppColor.primary,
          backgroundColor: AppColor.surface,
          side: const BorderSide(color: AppColor.primary, width: 1.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: style(
            size: 14,
            weight: FontWeight.w700,
            color: AppColor.primary,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColor.primary,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          textStyle: style(
            size: 13.5,
            weight: FontWeight.w700,
            color: AppColor.primary,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(innerCardRadius),
        ),
        contentTextStyle: style(
          size: 13.5,
          weight: FontWeight.w600,
          color: AppColor.onPrimary,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColor.textPrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: style(
          size: 12,
          weight: FontWeight.w500,
          color: AppColor.onPrimary,
        ),
      ),
    );
  }
}
