import 'dart:async';
import 'package:flutter/material.dart';
import 'package:store/core/theme/burhan_colors.dart';
import 'package:store/core/theme/burhan_typography.dart';

class CarouselSlideData {
  const CarouselSlideData({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.gradientColors,
    required this.accentColor,
    required this.icon,
  });

  final String badge;
  final String title;
  final String subtitle;
  final String cta;
  final List<Color> gradientColors;
  final Color accentColor;
  final IconData icon;
}

/// Home promotional banner carousel matching HomeCarouselSlider.tsx in storeAppUI.
class HomeCarouselSlider extends StatefulWidget {
  const HomeCarouselSlider({
    super.key,
    this.onCtaTap,
  });

  final ValueChanged<int>? onCtaTap;

  @override
  State<HomeCarouselSlider> createState() => _HomeCarouselSliderState();
}

class _HomeCarouselSliderState extends State<HomeCarouselSlider> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _timer;

  static const List<CarouselSlideData> slides = [
    CarouselSlideData(
      badge: 'تخفيضات المصانع · 1688',
      title: 'شراء مباشر بأسعار التكلفة من مصانع الصين',
      subtitle: 'وفّر حتى 40% وتجاوز قيود الدفع الصيني بحسابات محلية بالريال اليمني.',
      cta: 'تصفح مصانع 1688',
      gradientColors: [Color(0xFF0B2038), Color(0xFF123157), Color(0xFF08182B)],
      accentColor: BurhanColors.amber,
      icon: Icons.auto_awesome_rounded,
    ),
    CarouselSlideData(
      badge: 'ضمان الفحص العيني الشامل',
      title: 'تصوير حقيقي لكل منتج في مستودع قوانغتشو',
      subtitle: 'يفحص خبراؤنا سلامة القطع ومطابقتها قبل مغادرتها إلى اليمن مع ضمان الاسترجاع.',
      cta: 'كيف نضمن شحنتك؟',
      gradientColors: [Color(0xFF063B2F), Color(0xFF0D2D2A), Color(0xFF0B2038)],
      accentColor: BurhanColors.emerald500,
      icon: Icons.verified_user_rounded,
    ),
    CarouselSlideData(
      badge: 'ترندات تاوباو الحصرية · Taobao',
      title: 'أحدث الإلكترونيات ومقتنيات الموضة الآسيوية',
      subtitle: 'اكتشف ملايين المنتجات الحصرية والترندات بضغطة زر واحدة لباب بيتك.',
      cta: 'استكشف منتجات تاوباو',
      gradientColors: [Color(0xFF7F1D1D), Color(0xFF451A24), Color(0xFF0B2038)],
      accentColor: Color(0xFFFCA5A5),
      icon: Icons.stars_rounded,
    ),
    CarouselSlideData(
      badge: 'شحن مباشر ومضمون لليمن',
      title: 'تخليص جمركي مسبق وشحن جوي وبحري',
      subtitle: 'خيارات شحن جوي سريع (7-10 أيام) وشحن بحري اقتصادي للحاويات والطرود الكبيرة.',
      cta: 'تصفح الأسواق الصينية',
      gradientColors: [Color(0xFF1E1B4B), Color(0xFF172554), Color(0xFF0B2038)],
      accentColor: Color(0xFF7DD3FC),
      icon: Icons.flight_takeoff_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_pageController.hasClients) {
        final next = (_currentIndex + 1) % slides.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 168,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (idx) => setState(() => _currentIndex = idx),
        itemCount: slides.length,
        itemBuilder: (context, index) {
          final slide = slides[index];

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: slide.gradientColors,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              boxShadow: [
                BoxShadow(
                  color: slide.gradientColors.first.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Badge & Dots Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: slide.accentColor.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: slide.accentColor.withValues(alpha: 0.35),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(slide.icon, size: 11, color: slide.accentColor),
                          const SizedBox(width: 4),
                          Text(
                            slide.badge,
                            style: BurhanTypography.badge.copyWith(
                              color: slide.accentColor,
                              fontSize: 9.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Dots
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        slides.length,
                        (dotIdx) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: _currentIndex == dotIdx ? 14 : 5,
                          height: 4.5,
                          decoration: BoxDecoration(
                            color: _currentIndex == dotIdx
                                ? BurhanColors.amber
                                : Colors.white.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Middle Title & Subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slide.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: BurhanTypography.titleSmall.copyWith(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      slide.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: BurhanTypography.caption.copyWith(
                        color: BurhanColors.slate300,
                        fontSize: 10,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),

                // Bottom Action Button & Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => widget.onCtaTap?.call(index),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              slide.cta,
                              style: BurhanTypography.badge.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_back_rounded,
                              size: 13,
                              color: BurhanColors.amber,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Prev / Next Arrows
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            final prev = (_currentIndex - 1 + slides.length) % slides.length;
                            _pageController.animateToPage(
                              prev,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 10,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () {
                            final next = (_currentIndex + 1) % slides.length;
                            _pageController.animateToPage(
                              next,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 10,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
