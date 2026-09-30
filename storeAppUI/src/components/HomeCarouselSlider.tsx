import React, { useState, useEffect } from 'react';
import { ChevronLeft, ChevronRight, ShieldCheck, Sparkles, Plane, ArrowLeft } from 'lucide-react';
import { useApp } from '../context/AppContext';

export const HomeCarouselSlider: React.FC = () => {
  const { openStoreView, navigateToView } = useApp();
  const [currentSlide, setCurrentSlide] = useState(0);

  const slides = [
    {
      id: 1,
      badge: 'تخفيضات المصانع · 1688',
      title: 'شراء مباشر بأسعار التكلفة من مصانع الصين',
      subtitle: 'وفّر حتى 40% وتجاوز قيود الدفع الصيني بحسابات محلية بالريال اليمني.',
      cta: 'تصفح مصانع 1688',
      action: () => openStoreView('1688'),
      gradient: 'from-[#0B2038] via-[#123157] to-[#08182B]',
      accentColor: 'text-amber-400',
      badgeBg: 'bg-amber-400/20 text-amber-300 border-amber-400/30',
      icon: Sparkles,
    },
    {
      id: 2,
      badge: 'ضمان الفحص العيني الشامل',
      title: 'تصوير حقيقي لكل منتج في مستودع قوانغتشو',
      subtitle: 'يفحص خبراؤنا سلامة القطع ومطابقتها قبل مغادرتها إلى اليمن مع ضمان الاسترجاع.',
      cta: 'كيف نضمن شحنتك؟',
      action: () => navigateToView('how_it_works'),
      gradient: 'from-[#063B2F] via-[#0D2D2A] to-[#0B2038]',
      accentColor: 'text-emerald-400',
      badgeBg: 'bg-emerald-400/20 text-emerald-300 border-emerald-400/30',
      icon: ShieldCheck,
    },
    {
      id: 3,
      badge: 'ترندات تاوباو الحصرية · Taobao',
      title: 'أحدث الإلكترونيات ومقتنيات الموضة الآسيوية',
      subtitle: 'اكتشف ملايين المنتجات الحصرية والترندات بضغطة زر واحدة لباب بيتك.',
      cta: 'استكشف منتجات تاوباو',
      action: () => openStoreView('taobao'),
      gradient: 'from-[#7F1D1D] via-[#451A24] to-[#0B2038]',
      accentColor: 'text-rose-300',
      badgeBg: 'bg-rose-400/20 text-rose-200 border-rose-400/30',
      icon: Sparkles,
    },
    {
      id: 4,
      badge: 'شحن مباشر ومضمون لليمن',
      title: 'تخليص جمركي مسبق وشحن جوي وبحري',
      subtitle: 'خيارات شحن جوي سريع (7-10 أيام) وشحن بحري اقتصادي للحاويات والطرود الكبيرة.',
      cta: 'تصفح الأسواق الصينية',
      action: () => openStoreView('1688'),
      gradient: 'from-[#1E1B4B] via-[#172554] to-[#0B2038]',
      accentColor: 'text-sky-300',
      badgeBg: 'bg-sky-400/20 text-sky-200 border-sky-400/30',
      icon: Plane,
    },
  ];

  // Auto advance slide every 5 seconds
  useEffect(() => {
    const timer = setInterval(() => {
      setCurrentSlide((prev) => (prev + 1) % slides.length);
    }, 5000);
    return () => clearInterval(timer);
  }, [slides.length]);

  const slide = slides[currentSlide];
  const Icon = slide.icon;

  return (
    <div className="relative w-full overflow-hidden rounded-xl shadow-xs select-none">
      {/* Slide Canvas */}
      <div
        className={`relative bg-gradient-to-br ${slide.gradient} text-white p-4 sm:p-5 transition-all duration-500 min-h-[160px] flex flex-col justify-between border border-white/10`}
      >
        {/* Subtle decorative glow */}
        <div className="absolute -top-12 -left-12 w-36 h-36 rounded-full bg-white/5 blur-2xl pointer-events-none" />

        {/* Top Tag & Slide Counter */}
        <div className="flex items-center justify-between z-10">
          <span
            className={`inline-flex items-center gap-1 text-[10px] font-bold px-2 py-0.5 rounded-md border ${slide.badgeBg}`}
          >
            <Icon size={11} />
            <span>{slide.badge}</span>
          </span>

          {/* Dots Indicator */}
          <div className="flex items-center gap-1 bg-black/30 backdrop-blur-xs px-2 py-1 rounded-full">
            {slides.map((_, idx) => (
              <button
                key={idx}
                onClick={() => setCurrentSlide(idx)}
                aria-label={`شريحة ${idx + 1}`}
                className={`transition-all duration-300 rounded-full ${
                  currentSlide === idx ? 'w-4 h-1.5 bg-amber-400' : 'w-1.5 h-1.5 bg-white/40'
                }`}
              />
            ))}
          </div>
        </div>

        {/* Middle Content */}
        <div className="my-2 z-10 space-y-1">
          <h2 className="text-sm sm:text-base font-black text-white leading-snug">
            {slide.title}
          </h2>
          <p className="text-[11px] text-slate-300 line-clamp-2 leading-relaxed">
            {slide.subtitle}
          </p>
        </div>

        {/* Bottom CTA Action & Navigation */}
        <div className="flex items-center justify-between z-10 pt-1">
          <button
            onClick={slide.action}
            className="flex items-center gap-1.5 bg-white/15 hover:bg-white/25 backdrop-blur-xs border border-white/20 text-white text-[11px] font-bold px-3 py-1.5 rounded-lg active-press transition-colors shadow-2xs"
          >
            <span>{slide.cta}</span>
            <ArrowLeft size={13} className="text-amber-400" />
          </button>

          {/* Manual Next / Prev arrows */}
          <div className="flex items-center gap-1">
            <button
              onClick={() =>
                setCurrentSlide((prev) => (prev - 1 + slides.length) % slides.length)
              }
              aria-label="الشريحة السابقة"
              className="w-6 h-6 rounded-md bg-white/10 hover:bg-white/20 flex items-center justify-center text-white/80 active-press"
            >
              <ChevronRight size={14} />
            </button>
            <button
              onClick={() => setCurrentSlide((prev) => (prev + 1) % slides.length)}
              aria-label="الشريحة التالية"
              className="w-6 h-6 rounded-md bg-white/10 hover:bg-white/20 flex items-center justify-center text-white/80 active-press"
            >
              <ChevronLeft size={14} />
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
