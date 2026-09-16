// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'package:flutter/material.dart';

/// Application colour palette, centralised to avoid hardcoding colours.
class AppColors {
  AppColors._();

  static const Color black = Color(0xFF000000);
  static const Color ink = Color(0xFF111111);
  static const Color white = Color(0xFFFFFFFF);

  static const Color surface = Color(0xFFF5F5F5); // Fields and light fills
  static const Color surfaceSoft = Color(0xFFF7F7F7);
  static const Color divider = Color(0xFFF0F0F0);

  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF999999);
  static const Color textMuted = Color(0xFF666666);
  static const Color textFaint = Color(0xFF5C5C5C);

  static const Color income = Color(0xFF22C55E);

  /// Cool grey gradient for the payment card (top-left to bottom-right).
  static const List<Color> cardGradient = [
    Color(0xFFE6E6E4),
    Color(0xFFCECECB),
  ];
}

/// Reusable decorations and input field styles.
class AppDecorations {
  AppDecorations._();

  /// Light grey rounded background for a form field.
  static BoxDecoration fieldBox() => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(12),
  );

  /// Borderless input decoration with light grey hint text.
  static InputDecoration fieldDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 14),
    border: InputBorder.none,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}
