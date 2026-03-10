import 'package:flutter/material.dart';

class AppColors {
  // Primary Sustainability Palette
  static const Color primary = Color(0xFF00C853); // Vibrant Emerald
  static const Color primaryDark = Color(0xFF1B5E20); // Deep Forest
  static const Color primaryLight = Color(0xFFB9F6CA); // Soft Mint

  // Secondary / Accent
  static const Color accent = Color(
    0xFFFFD600,
  ); // Golden Sun (for money/earnings)
  static const Color secondary = Color(
    0xFF00B0FF,
  ); // Sky Blue (for trust/transparency)

  // Neutral Palette
  static const Color background = Color(
    0xFFF5F9F7,
  ); // Very light mint-tinted gray
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA000);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00C853), Color(0xFF1B5E20)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white, Color(0xFFF1F8E9)],
  );
}
