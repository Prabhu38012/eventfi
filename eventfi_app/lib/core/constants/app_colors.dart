import 'package:flutter/material.dart';

/// EventFi Ember Color Palette
/// ──────────────────────────────────────────
/// Dark   → #1C1917  Warm Charcoal (page bg)
/// Accent → #FF6B35  Ember Orange  (CTAs)
/// Light  → #F7F4EE  Warm Off-White (text / buttons)
class AppColors {
  AppColors._();

  // ─── Core Brand ──────────────────────────────────────────
  static const Color dark   = Color(0xFF1C1917);  // Page background
  static const Color accent = Color(0xFFFF6B35);  // CTAs, active states
  static const Color light  = Color(0xFFF7F4EE);  // Light text, icon fills

  // ─── Surface Hierarchy ───────────────────────────────────
  static const Color surface1 = Color(0xFF262220);  // Cards
  static const Color surface2 = Color(0xFF2C2623);  // Elevated cards
  static const Color surface3 = Color(0xFF332E2A);  // Inputs, search bars

  // ─── Text Colors ─────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF7F4EE);
  static const Color textSecondary = Color(0xFF9A8F87);
  static const Color textHint      = Color(0xFF6B625C);

  // ─── Semantic Colors ─────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color error   = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFC107);
  static const Color info    = Color(0xFF42A5F5);

  // ─── Event Category Colors ───────────────────────────────
  static const Color theatre   = Color(0xFFB39DDB);  // Purple
  static const Color concert   = Color(0xFFFF6B35);  // Ember (same as accent)
  static const Color standup   = Color(0xFFFFD54F);  // Yellow
  static const Color dance     = Color(0xFFF48FB1);  // Pink
  static const Color themePark = Color(0xFF80CBC4);  // Teal

  // ─── Gold Points ─────────────────────────────────────────
  static const Color gold     = Color(0xFFD4A853);
  static const Color goldDark = Color(0xFF9C6B00);

  // ─── Divider & Border ────────────────────────────────────
  static const Color divider = Color(0xFF2C2623);
  static const Color border  = Color(0xFF3A3431);
}
