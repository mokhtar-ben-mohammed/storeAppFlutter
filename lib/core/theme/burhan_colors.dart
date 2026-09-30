import 'package:flutter/material.dart';

/// Design tokens & color palette extracted from storeAppUI.
class BurhanColors {
  const BurhanColors._();

  // Primary Palette - Deep Royal Navy
  static const Color primary = Color(0xFF0B2038);
  static const Color primaryLight = Color(0xFF163B66);
  static const Color primaryDark = Color(0xFF08182B);
  static const Color primaryAccent = Color(0xFF0F294A);

  // Accent & Gold Palette
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberLight = Color(0xFFFBBF24);
  static const Color amberDark = Color(0xFFD97706);
  static const Color gold = Color(0xFFE69806);

  // Slate Neutral Canvas
  static const Color background = Color(0xFFF8FAFC); // slate-50
  static const Color card = Color(0xFFFFFFFF);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);

  // Status & Utility Colors
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald50 = Color(0xFFECFDF5);
  static const Color emerald600 = Color(0xFF059669);
  static const Color rose500 = Color(0xFFF43F5E);
  static const Color rose50 = Color(0xFFFFF1F2);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue50 = Color(0xFFEFF6FF);

  // Chinese Marketplace Gradients & Badges
  // 1688
  static const Color store1688Start = Color(0xFFFF6A00);
  static const Color store1688End = Color(0xFFFF4E00);
  static const Color store1688Bg = Color(0xFFFFF7ED);
  static const Color store1688Border = Color(0xFFFED7AA);
  static const Color store1688Text = Color(0xFFEA580C);

  // Taobao
  static const Color storeTaobaoStart = Color(0xFFFF5000);
  static const Color storeTaobaoEnd = Color(0xFFE02E00);
  static const Color storeTaobaoBg = Color(0xFFFEF2F2);
  static const Color storeTaobaoBorder = Color(0xFFFECACA);
  static const Color storeTaobaoText = Color(0xFFDC2626);

  // Goofish
  static const Color storeGoofishStart = Color(0xFFFFD200);
  static const Color storeGoofishEnd = Color(0xFFFFB700);
  static const Color storeGoofishBg = Color(0xFFFEFCE8);
  static const Color storeGoofishBorder = Color(0xFFFEF08A);
  static const Color storeGoofishText = Color(0xFF854D0E);

  // AliExpress
  static const Color storeAliexpressStart = Color(0xFFE62E04);
  static const Color storeAliexpressEnd = Color(0xFFC41C00);
  static const Color storeAliexpressBg = Color(0xFFFFF1F2);
  static const Color storeAliexpressBorder = Color(0xFFFECDD3);
  static const Color storeAliexpressText = Color(0xFFE11D48);

  // Factories
  static const Color storeFactoryStart = Color(0xFF0B2038);
  static const Color storeFactoryEnd = Color(0xFF163B66);

  // Shadows & Borders
  static final BoxShadow cardShadow = BoxShadow(
    color: Colors.black.withValues(alpha: 0.04),
    blurRadius: 10,
    offset: const Offset(0, 2),
  );

  static final BoxShadow elevatedShadow = BoxShadow(
    color: const Color(0xFF0B2038).withValues(alpha: 0.08),
    blurRadius: 16,
    offset: const Offset(0, 4),
  );
}
