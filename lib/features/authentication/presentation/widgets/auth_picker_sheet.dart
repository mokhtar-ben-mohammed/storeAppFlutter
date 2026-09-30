import 'package:flutter/material.dart';
import 'package:store/core/theme/burhan_colors.dart';
import 'package:store/core/theme/burhan_typography.dart';

/// Flag emoji from ISO2 (e.g. YE → 🇾🇪).
String authFlagFromIso2(String iso2) {
  final code = iso2.trim().toUpperCase();
  if (code.length != 2) return '🏳️';
  return String.fromCharCodes([
    0x1F1E6 + code.codeUnitAt(0) - 0x41,
    0x1F1E6 + code.codeUnitAt(1) - 0x41,
  ]);
}

/// Shared auth bottom-sheet list matching the phone dial-code picker style.
Future<T?> showAuthPickerSheet<T>({
  required BuildContext context,
  required String title,
  required IconData icon,
  required List<T> items,
  required T? selected,
  required String Function(T item) labelOf,
  required String Function(T item) trailingOf,
  String Function(T item)? leadingEmojiOf,
  bool Function(T a, T b)? equals,
}) {
  bool isSame(T a, T b) => equals != null ? equals(a, b) : identical(a, b) || a == b;

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Container(
        height: MediaQuery.of(sheetContext).size.height * 0.58,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: BurhanColors.slate300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: BurhanColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: BurhanTypography.titleSmall.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: BurhanColors.slate200),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        'لا توجد عناصر للعرض',
                        style: BurhanTypography.bodyMedium.copyWith(
                          color: BurhanColors.slate500,
                        ),
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const Divider(
                        height: 1,
                        color: BurhanColors.slate100,
                      ),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final selectedItem = selected;
                        final isSelected =
                            selectedItem != null && isSame(item, selectedItem);
                        final emoji = leadingEmojiOf?.call(item);

                        return InkWell(
                          onTap: () => Navigator.pop(sheetContext, item),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? BurhanColors.slate100
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                if (emoji != null) ...[
                                  Text(emoji, style: const TextStyle(fontSize: 22)),
                                  const SizedBox(width: 12),
                                ],
                                Expanded(
                                  child: Text(
                                    labelOf(item),
                                    style: BurhanTypography.bodyMedium.copyWith(
                                      fontWeight:
                                          isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected
                                          ? BurhanColors.primary
                                          : BurhanColors.slate800,
                                    ),
                                  ),
                                ),
                                Text(
                                  trailingOf(item),
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: BurhanColors.slate600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: BurhanColors.primary,
                                    size: 18,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    },
  );
}

/// Tappable field styled like the phone dial-code pill.
class AuthSheetField extends StatelessWidget {
  const AuthSheetField({
    super.key,
    required this.label,
    required this.valueText,
    required this.onTap,
    this.leading,
    this.enabled = true,
  });

  final String label;
  final String valueText;
  final VoidCallback? onTap;
  final Widget? leading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: BurhanTypography.titleSmall.copyWith(fontSize: 12.5),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: BurhanColors.slate50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: BurhanColors.slate200),
            ),
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    valueText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: BurhanTypography.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: BurhanColors.slate900,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: BurhanColors.slate500,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
