import 'package:flutter/material.dart';

/// Centralised colour tokens for SkillBridge.
///
/// Semantic roles first, raw values second: prefer [primary], [success],
/// [warning] etc. over hard-coded `Color(0x...)` at call sites.
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------- Brand
  /// Deep royal blue — trust and education.
  static const Color primary = Color(0xFF1E40AF);
  static const Color primaryBright = Color(0xFF2563EB);
  static const Color primarySoft = Color(0xFFEFF6FF);

  /// Modern teal — quick actions, active states, focus.
  static const Color secondary = Color(0xFF0D9488);
  static const Color secondaryBright = Color(0xFF14B8A6);
  static const Color secondarySoft = Color(0xFFF0FDFA);

  // ----------------------------------------------------------- Neutrals
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);
  static const Color fieldFill = Color(0xFFF1F5F9);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);

  // ------------------------------------------------------------ Semantic
  static const Color success = Color(0xFF059669);
  static const Color successSoft = Color(0xFFECFDF5);

  static const Color warning = Color(0xFFD97706);
  static const Color warningSoft = Color(0xFFFFFBEB);

  static const Color error = Color(0xFFE11D48);
  static const Color errorSoft = Color(0xFFFFF1F2);

  static const Color info = Color(0xFF0284C7);
  static const Color infoSoft = Color(0xFFF0F9FF);

  /// Interview / Test stage.
  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleSoft = Color(0xFFF5F3FF);

  // ----------------------------------------------------- Dark-mode tokens
  static const Color darkBackground = Color(0xFF0B1120);
  static const Color darkSurface = Color(0xFF111C33);
  static const Color darkBorder = Color(0xFF1E293B);
  static const Color darkFieldFill = Color(0xFF16233D);
  static const Color darkTextPrimary = Color(0xFFE2E8F0);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // ------------------------------------------------------------ Geometry
  static const double radiusCard = 16.0;
  static const double radiusField = 12.0;
  static const double radiusPill = 24.0;

  /// Soft drop shadow used in place of harsh Material elevation.
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  // ---------------------------------------------- Backwards-compatible
  // Names used by the instructor and coordinator screens, kept so those
  // screens pick up the new palette without edits.
  static const Color primaryIndigo = primary;
  static const Color emeraldGreen = success;
  static const Color crimsonRed = error;
  static const Color amber = warning;
  static const Color cardSurface = surface;
}
