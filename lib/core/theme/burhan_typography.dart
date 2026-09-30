import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:store/core/theme/burhan_colors.dart';

/// Typography system matching storeAppUI (Tajawal font with Cairo fallback).
class BurhanTypography {
  const BurhanTypography._();

  static TextStyle get headline => GoogleFonts.tajawal(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: BurhanColors.slate900,
        letterSpacing: -0.5,
      );

  static TextStyle get titleLarge => GoogleFonts.tajawal(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: BurhanColors.slate900,
      );

  static TextStyle get titleMedium => GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: BurhanColors.slate900,
      );

  static TextStyle get titleSmall => GoogleFonts.tajawal(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: BurhanColors.slate900,
      );

  static TextStyle get bodyMedium => GoogleFonts.tajawal(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: BurhanColors.slate700,
        height: 1.4,
      );

  static TextStyle get bodySmall => GoogleFonts.tajawal(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: BurhanColors.slate500,
        height: 1.3,
      );

  static TextStyle get caption => GoogleFonts.tajawal(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: BurhanColors.slate400,
      );

  static TextStyle get badge => GoogleFonts.tajawal(
        fontSize: 9,
        fontWeight: FontWeight.w800,
      );

  static TextStyle get priceMain => GoogleFonts.tajawal(
        fontSize: 13,
        fontWeight: FontWeight.w900,
        color: BurhanColors.primary,
        letterSpacing: -0.3,
      );
}
