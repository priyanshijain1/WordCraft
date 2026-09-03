import 'package:flutter/material.dart';

/// App-wide design tokens. Keeps colors, spacing, and durations in one place
/// so screens never use magic numbers.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFFFF6B6B);
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF22223B);
  static const Color correct = Color(0xFF2ECC71);
  static const Color wrong = Color(0xFFE74C3C);
  static const Color textLight = Color(0xFF2D3436);
  static const Color textDark = Color(0xFFF5F5F5);
  static const Color tileLight = Color(0xFFE8E6FF);
  static const Color tileDark = Color(0xFF2C2C54);
}

/// Spacing scale used across all screens.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double cardRadius = 12;
  static const double buttonRadius = 8;
}

/// Animation and interaction durations.
class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration screenTransition = Duration(milliseconds: 250);
}

/// Game rules and limits.
class GameConstants {
  GameConstants._();

  static const int wordsPerGame = 8;
  static const Duration timePerWord = Duration(seconds: 30);
  static const int basePoints = 100;
  static const int pointsPerSecondLeft = 10;
  static const int skipPenalty = 50;
  static const int minWordLength = 4;
  static const int maxWordLength = 7;
}
