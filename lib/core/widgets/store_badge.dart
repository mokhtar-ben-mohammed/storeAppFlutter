import 'package:flutter/material.dart';
import 'package:store/core/theme/burhan_colors.dart';
import 'package:store/core/theme/burhan_typography.dart';

enum StoreType { s1688, taobao, goofish, aliexpress }

enum StoreBadgeSize { sm, md }

/// Badge widget indicating Chinese marketplace origin.
class StoreBadge extends StatelessWidget {
  const StoreBadge({
    super.key,
    required this.store,
    this.showChineseLabel = true,
    this.isSmall = false,
    this.size,
  });

  /// Can be either [StoreType] or a [String] (e.g. '1688', 'taobao', etc.).
  final dynamic store;
  final bool showChineseLabel;
  final bool isSmall;
  final StoreBadgeSize? size;

  static StoreType fromString(String str) {
    return switch (str.toLowerCase()) {
      '1688' => StoreType.s1688,
      'taobao' => StoreType.taobao,
      'goofish' => StoreType.goofish,
      'aliexpress' => StoreType.aliexpress,
      _ => StoreType.s1688,
    };
  }

  StoreType get _resolvedStore {
    if (store is StoreType) return store as StoreType;
    return fromString(store?.toString() ?? '');
  }

  bool get _effectiveSmall => isSmall || size == StoreBadgeSize.sm;

  (String name, String cnName, Color bg, Color border, Color text) get _config =>
      switch (_resolvedStore) {
        StoreType.s1688 => (
            '1688',
            '阿里巴巴',
            BurhanColors.store1688Bg,
            BurhanColors.store1688Border,
            BurhanColors.store1688Text,
          ),
        StoreType.taobao => (
            'Taobao',
            '淘宝网',
            BurhanColors.storeTaobaoBg,
            BurhanColors.storeTaobaoBorder,
            BurhanColors.storeTaobaoText,
          ),
        StoreType.goofish => (
            'Goofish',
            '闲鱼',
            BurhanColors.storeGoofishBg,
            BurhanColors.storeGoofishBorder,
            BurhanColors.storeGoofishText,
          ),
        StoreType.aliexpress => (
            'AliExpress',
            '速卖通',
            BurhanColors.storeAliexpressBg,
            BurhanColors.storeAliexpressBorder,
            BurhanColors.storeAliexpressText,
          ),
      };

  @override
  Widget build(BuildContext context) {
    final (name, cnName, bg, border, text) = _config;
    final small = _effectiveSmall;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 5 : 7,
        vertical: small ? 1.5 : 2.5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: BurhanTypography.badge.copyWith(
              color: text,
              fontSize: small ? 9 : 10.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (showChineseLabel) ...[
            const SizedBox(width: 3),
            Text(
              cnName,
              style: BurhanTypography.caption.copyWith(
                color: text.withValues(alpha: 0.75),
                fontSize: small ? 8.5 : 9.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
