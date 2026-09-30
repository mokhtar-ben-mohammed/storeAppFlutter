import 'package:flutter/material.dart';
import 'package:store/core/theme/burhan_colors.dart';
import 'package:store/core/theme/burhan_typography.dart';

enum BurhanLogoSize { sm, md, lg, xl }
enum BurhanLogoVariant { emblem, horizontal, full }

/// Renders the official Burhan logo with custom vector emblem and typography.
class BurhanLogo extends StatelessWidget {
  const BurhanLogo({
    super.key,
    this.size = BurhanLogoSize.md,
    this.variant = BurhanLogoVariant.horizontal,
    this.isLight = false,
  });

  final BurhanLogoSize size;
  final BurhanLogoVariant variant;
  final bool isLight;

  double get emblemDimension => switch (size) {
        BurhanLogoSize.sm => 28.0,
        BurhanLogoSize.md => 38.0,
        BurhanLogoSize.lg => 54.0,
        BurhanLogoSize.xl => 80.0,
      };

  double get titleFontSize => switch (size) {
        BurhanLogoSize.sm => 14.0,
        BurhanLogoSize.md => 17.0,
        BurhanLogoSize.lg => 22.0,
        BurhanLogoSize.xl => 28.0,
      };

  double get subtitleFontSize => switch (size) {
        BurhanLogoSize.sm => 8.5,
        BurhanLogoSize.md => 10.0,
        BurhanLogoSize.lg => 11.5,
        BurhanLogoSize.xl => 13.0,
      };

  @override
  Widget build(BuildContext context) {
    final emblem = SizedBox(
      width: emblemDimension,
      height: emblemDimension,
      child: CustomPaint(
        painter: _BurhanEmblemPainter(),
      ),
    );

    if (variant == BurhanLogoVariant.emblem) {
      return emblem;
    }

    final textColumn = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          variant == BurhanLogoVariant.full ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'بُرهان',
              style: BurhanTypography.headline.copyWith(
                fontSize: titleFontSize,
                color: isLight ? Colors.white : BurhanColors.slate900,
                height: 1.1,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: BurhanColors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: BurhanColors.amber.withValues(alpha: 0.3),
                  width: 0.8,
                ),
              ),
              child: Text(
                'BURHAN',
                style: BurhanTypography.badge.copyWith(
                  color: BurhanColors.amberDark,
                  fontSize: 8.5,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 1.5),
        Text(
          'وسيط الشراء الموثوق من الصين',
          style: BurhanTypography.caption.copyWith(
            fontSize: subtitleFontSize,
            color: isLight ? BurhanColors.slate300 : BurhanColors.slate500,
            height: 1.1,
          ),
        ),
      ],
    );

    if (variant == BurhanLogoVariant.full) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          emblem,
          const SizedBox(height: 8),
          textColumn,
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        emblem,
        const SizedBox(width: 8),
        textColumn,
      ],
    );
  }
}

/// Custom painter reproducing the geometry of the Burhan circular emblem.
class _BurhanEmblemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer Circle (Navy)
    final outerPaint = Paint()
      ..color = const Color(0xFF0B2038)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, outerPaint);

    final outerBorder = Paint()
      ..color = const Color(0xFF16345A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.03;
    canvas.drawCircle(center, radius - 1, outerBorder);

    // Inner White Disk
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.82, innerPaint);

    // Scale factors for geometric paths
    final w = size.width;
    final h = size.height;

    // Golden upward arrow in center
    final arrowPath = Path()
      ..moveTo(w * 0.50, h * 0.18)
      ..lineTo(w * 0.62, h * 0.36)
      ..lineTo(w * 0.54, h * 0.36)
      ..lineTo(w * 0.54, h * 0.44)
      ..lineTo(w * 0.46, h * 0.44)
      ..lineTo(w * 0.46, h * 0.36)
      ..lineTo(w * 0.38, h * 0.36)
      ..close();

    final goldPaint = Paint()
      ..color = const Color(0xFFE69806)
      ..style = PaintingStyle.fill;
    canvas.drawPath(arrowPath, goldPaint);

    // Intertwined Left loop (Amber)
    final leftLoop = Path()
      ..moveTo(w * 0.50, h * 0.40)
      ..cubicTo(w * 0.40, h * 0.34, w * 0.28, h * 0.38, w * 0.22, h * 0.46)
      ..cubicTo(w * 0.16, h * 0.55, w * 0.20, h * 0.68, w * 0.32, h * 0.73)
      ..cubicTo(w * 0.40, h * 0.77, w * 0.47, h * 0.72, w * 0.50, h * 0.64)
      ..cubicTo(w * 0.45, h * 0.57, w * 0.35, h * 0.55, w * 0.30, h * 0.60)
      ..close();
    canvas.drawPath(leftLoop, Paint()..color = const Color(0xFFF59E0B));

    // Intertwined Right loop (Navy)
    final rightLoop = Path()
      ..moveTo(w * 0.50, h * 0.40)
      ..cubicTo(w * 0.60, h * 0.34, w * 0.72, h * 0.38, w * 0.78, h * 0.46)
      ..cubicTo(w * 0.84, h * 0.55, w * 0.80, h * 0.68, w * 0.68, h * 0.73)
      ..cubicTo(w * 0.60, h * 0.77, w * 0.53, h * 0.72, w * 0.50, h * 0.64)
      ..cubicTo(w * 0.55, h * 0.57, w * 0.65, h * 0.55, w * 0.70, h * 0.60)
      ..close();
    canvas.drawPath(rightLoop, Paint()..color = const Color(0xFF0F294A));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
