import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Dark Theme Fundamentals
  static const Color backgroundPrimary = Color(
    0xFF0B1120,
  ); // Deeper darker blue (Slate 900+)
  static const Color backgroundSecondary = Color(0xFF1E293B); // Slate 800
  static const Color backgroundTertiary = Color(0xFF334155); // Slate 700

  // Accents (More vibrant & modern)
  static const Color bottonColor = Color(0xFF0EA5E9); // Modern Sky Blue
  static const Color progressColor = Color(0xFF10B981); // Emerald Green

  // Text & Borders
  static const Color textColor = Color(0xFF94A3B8); // Slate 400
  static const Color textLight = Color(0xFFF8FAFC); // Slate 50
  static const Color borderColor = Color(0xFF334155); // Slate 700

  // Specific Assets
  static const Color ballColor = Color(0xFF3B82F6); // Blue 500

  // Translucent / Glassmorphic (New)
  static final Color glassBackground = Colors.white.withValues(alpha: 0.05);
  static final Color glassBorder = Colors.white.withValues(alpha: 0.1);
  static final Color primaryTranslucent = bottonColor.withValues(alpha: 0.15);
  static final Color successTranslucent = progressColor.withValues(alpha: 0.15);
  static final Color errorTranslucent = merah.withValues(alpha: 0.15);

  // Neutral Colors
  static const Color putih = Colors.white;
  static const Color hytam = Colors.black;
  static const Color merah = Color(0xFFEF4444); // Red 500
  static const Color kuning = Color(0xFFF59E0B); // Amber 500
  static const Color hijau = Color(0xFF10B981); // Emerald 500
}
