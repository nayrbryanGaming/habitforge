import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand Trinity (The Forge Aesthetic)
  static const Color primary = Color(0xFF2563EB); // Royal Blue (Trust)
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color accent = Color(0xFFF97316);  // Magma Orange (Energy)

  static const Color gold = Color(0xFFF59E0B);    // Mastery Gold (Achievement)

  // Surface Hierarchy (Glassmorphic Base)
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color streakFire = Color(0xFFFF6B6B);

  static const Color streakGold = Color(0xFFFFD93D);

  // Typography Hierarchy
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Border & Dividers
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color borderDark = Color(0xFF334155);


  // Masterpiece Elevation (Layered Shadows)
  static List<BoxShadow> get premiumShadow => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.03),
      blurRadius: 1,
      offset: const Offset(0, 1),
    ),
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
      blurRadius: 24,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get highElevationShadow => [
    BoxShadow(
      color: const Color(0xFF2563EB).withValues(alpha: 0.08),
      blurRadius: 40,
      spreadRadius: -8,
      offset: const Offset(0, 20),
    ),
  ];

  // Clinical Glassmorphic Token
  static BoxDecoration glassDecoration({
    required Color color,
    double opacity = 0.1,
    double blur = 12,
  }) {
    return BoxDecoration(
      color: color.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
    );
  }

  // Branding Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient magmaGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFEA580C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient forgeGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}



