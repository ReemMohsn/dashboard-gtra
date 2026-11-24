import 'package:flutter/material.dart';

abstract final class AppColor {
  // Brand & Primary
  static const Color primary = Color(0xFF0E738A);
  static const Color primaryDark = Color(0xFF0A5566);
  static const Color primarySoft = Color(0xFFE7F4F7);
  static const Color primaryBorder = Color(0xFF8CC5D2);

  // Surfaces & Backgrounds
  static const Color scaffoldBackground = Color(0xFFF4F7F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF8FAFC);
  static const Color surfaceMuted = Color(0xFFF1F5F8);
  static const Color explanationSurface = Color(0xFFEDF6FA);
  static const Color explanationBorder = Color(0xFFCDE5EE);

  // Typography
  static const Color textPrimary = Color(0xFF0F273A);
  static const Color textSecondary = Color(0xFF526577);
  static const Color textMuted = Color(0xFF7B8D9E);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Borders, Dividers & Shadows
  static const Color border = Color(0xFFDDE6EE);
  static const Color borderSubtle = Color(0xFFE8EEF3);
  static const Color divider = Color(0xFFE4ECF2);
  static const Color cardShadow = Color(0x120F273A);

  // Priority & Golden Rule Semantic Colors
  static const Color urgentHealth = Color(0xFF7E1946);
  static const Color urgentHealthSoft = Color(0xFFFBEBF1);
  static const Color priorityHigh = Color(0xFFD32F3F);
  static const Color priorityMedium = Color(0xFFC85A17);
  static const Color priorityLow = Color(0xFFD99B06);

  // Incident Lifecycle State Colors
  static const Color stateNew = Color(0xFF4B5E6F);
  static const Color stateConfirmed = Color(0xFF1D63B8);
  static const Color stateInProgress = Color(0xFF5B4BB7);
  static const Color stateResolved = Color(0xFF1E8E5A);
  static const Color stateExpired = Color(0xFF64748B);

  // Flags & Warnings
  static const Color escalatingBg = Color(0xFFFEF3C7);
  static const Color escalatingBorder = Color(0xFFF5C451);
  static const Color escalatingText = Color(0xFF925E00);

  static const Color repeatBg = Color(0xFFFFEDD5);
  static const Color repeatBorder = Color(0xFFFDBA74);
  static const Color repeatText = Color(0xFF9A3412);

  static const Color abnormalDelayBg = Color(0xFFFEE2E2);
  static const Color abnormalDelayBorder = Color(0xFFFCA5A5);
  static const Color abnormalDelayText = Color(0xFF991B1B);

  static const Color neutralBadgeBg = Color(0xFFF8FAFC);
  static const Color neutralBadgeBorder = Color(0xFFCBD5E1);
  static const Color neutralBadgeText = Color(0xFF334155);

  // Map Canvas Tones
  static const Color mapBackground = Color(0xFFEAF1F5);
  static const Color mapWaterway = Color(0xFFC5E5F0);
  static const Color mapRoad = Color(0xFFFFFFFF);
  static const Color mapQuietMarker = Color(0xFF8E9AA6);

  // General Feedback
  static const Color danger = Color(0xFFD92D20);
  static const Color success = Color(0xFF1E8E5A);
  static const Color warning = Color(0xFFD97706);
}
