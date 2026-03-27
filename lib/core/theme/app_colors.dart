import 'package:flutter/material.dart';

/// "Steel & Charcoal" — Monochromatic premium palette
/// Translated from CSS design reference (light + dark tokens)
class AppColors {
  AppColors._();

  // ─── Dark theme (primary) ─────────────────────────────────────────────────
  // Mapped from .dark CSS vars

  /// #1A1A1A — main scaffold background
  static const Color background = Color(0xFF1A1A1A);

  /// #202020 — card / primary surface
  static const Color surface = Color(0xFF202020);

  /// #2A2A2A — muted / secondary surface
  static const Color surfaceMuted = Color(0xFF2A2A2A);

  /// #303030 — input fill / tertiary surface
  static const Color surfaceInput = Color(0xFF303030);

  /// #404040 — elevated / accent surface
  static const Color surfaceElevated = Color(0xFF404040);

  /// #1F1F1F — sidebar / bottom nav
  static const Color sidebar = Color(0xFF1F1F1F);

  /// #353535 — borders, dividers
  static const Color divider = Color(0xFF353535);

  /// #A0A0A0 — primary interactive (silver)
  static const Color primary = Color(0xFFA0A0A0);

  /// #1A1A1A — text on primary
  static const Color onPrimary = Color(0xFF1A1A1A);

  /// #303030 — secondary interactive
  static const Color secondary = Color(0xFF303030);

  /// #D9D9D9 — text on secondary
  static const Color onSecondary = Color(0xFFD9D9D9);

  /// #D9D9D9 — primary text
  static const Color textPrimary = Color(0xFFD9D9D9);

  /// #808080 — secondary/muted text
  static const Color textSecondary = Color(0xFF808080);

  /// #606060 — tertiary/hint text
  static const Color textTertiary = Color(0xFF606060);

  /// #A0A0A0 — focus ring
  static const Color ring = Color(0xFFA0A0A0);

  /// #7E9CA0 — chart-2, muted blue-green for income
  static const Color income = Color(0xFF5A8F72);

  /// #E06666 — destructive / expense
  static const Color expense = Color(0xFFE06666);

  /// #C4924A — warm amber for warnings
  static const Color warning = Color(0xFFC4924A);

  /// #6B8FAE — steel blue for info
  static const Color info = Color(0xFF6B8FAE);

  // Shimmer (dark)
  static const Color shimmerBase = Color(0xFF202020);
  static const Color shimmerHighlight = Color(0xFF2C2C2C);

  // ─── Light theme ─────────────────────────────────────────────────────────
  // Mapped from :root CSS vars

  /// #F0F0F0 — light scaffold background
  static const Color backgroundLight = Color(0xFFF0F0F0);

  /// #F5F5F5 — light card surface
  static const Color surfaceLight = Color(0xFFF5F5F5);

  /// #EAEAEA — light sidebar surface
  static const Color sidebarLight = Color(0xFFEAEAEA);

  /// #D0D0D0 — light borders
  static const Color dividerLight = Color(0xFFD0D0D0);

  /// #E0E0E0 — light input fill
  static const Color inputLight = Color(0xFFE0E0E0);

  /// #606060 — light primary
  static const Color primaryLight = Color(0xFF606060);

  /// #333333 — light primary text
  static const Color textPrimaryLight = Color(0xFF333333);

  /// #666666 — light secondary text
  static const Color textSecondaryLight = Color(0xFF666666);
}
