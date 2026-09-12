import 'package:flutter/material.dart';

/// App Color Palette for TIMEFLOW Design System (Material 3)
class AppColors {
  AppColors._();

  // Primary Palette (Deep Flow Blue / Violet Accent)
  static const Color primary = Color(0xFF6366F1); // Indigo Primary
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  // Secondary Palette (Cyan / Teal Accent)
  static const Color secondary = Color(0xFF0EA5E9); // Sky Blue
  static const Color secondaryLight = Color(0xFF38BDF8);

  // Accent Colors for Categories & Statuses
  static const Color success = Color(0xFF10B981); // Emerald Green
  static const Color warning = Color(0xFFF59E0B); // Amber Warning
  static const Color error = Color(0xFFEF4444); // Red Danger
  static const Color info = Color(0xFF3B82F6); // Blue Info
  static const Color purple = Color(0xFFA855F7); // Violet Purple

  // Neutral Palette - Light Mode
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Neutral Palette - Dark Mode
  static const Color darkBackground = Color(0xFF0B0F19);
  static const Color darkSurface = Color(0xFF131C2E);
  static const Color darkSurfaceVariant = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF334155);

  // Time Slot & Task Card Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient activeTaskGradient = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
