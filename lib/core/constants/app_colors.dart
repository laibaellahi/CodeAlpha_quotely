// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';
/// Centralized color palette for the Quote App.
/// All colors follow Material 3 design principles with accessibility in mind.
abstract class AppColors {
  // ── Primary ──────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF4F46E5); // Deep Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF3730A3);
  // ── Secondary ────────────────────────────────────────────────────────────
  static const Color secondary = Color(0xFF14B8A6); // Teal
  static const Color secondaryLight = Color(0xFF5EEAD4);
  // ── Accent ───────────────────────────────────────────────────────────────
  static const Color accent = Color(0xFFF59E0B); // Amber
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color error = Color(0xFFEF4444); // Red
  // ── Light Theme ──────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color divider = Color(0xFFE2E8F0);
  // ── Dark Theme ───────────────────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  // ── Quote Card Gradients ──────────────────────────────────────────────────
  static const List<List<Color>> cardGradients = [
    [Color(0xFF4F46E5), Color(0xFF7C3AED)], // Indigo → Purple
    [Color(0xFF0EA5E9), Color(0xFF14B8A6)], // Sky → Teal
    [Color(0xFFF59E0B), Color(0xFFEF4444)], // Amber → Red
    [Color(0xFF10B981), Color(0xFF0EA5E9)], // Emerald → Sky
    [Color(0xFF8B5CF6), Color(0xFFEC4899)], // Violet → Pink
    [Color(0xFF06B6D4), Color(0xFF3B82F6)], // Cyan → Blue
    [Color(0xFFF97316), Color(0xFFEAB308)], // Orange → Yellow
    [Color(0xFF6366F1), Color(0xFF14B8A6)], // Indigo → Teal
    [Color(0xFFDC2626), Color(0xFF9333EA)], // Red → Purple
    [Color(0xFF059669), Color(0xFF2563EB)], // Green → Blue
  ];
}