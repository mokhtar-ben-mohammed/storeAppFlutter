import React from 'react';
import { Sparkles } from 'lucide-react';
import { useApp } from '../context/AppContext';
import { MarketplaceAppIcons } from '../components/MarketplaceAppIcons';
import { HomeCarouselSlider } from '../components/HomeCarouselSlider';
import { ProductCard } from '../components/ProductCard';

export const HomeScreen: React.FC = () => {
  const { products } = useApp();

  return (
    <div className="pb-36 text-right space-y-6 pt-3 px-4 max-w-md mx-auto">
      {/* 1. Promotional Carousel Slider (Replaced the search section as requested) */}
      <section>
        <HomeCarouselSlider />
      </section>

      {/* 2. Chinese Marketplace Circles (Free-flowing Horizontal Slider, No Card Wrapper) */}
      <section className="space-y-2">
        <div className="flex items-center justify-between px-1">
          <span className="text-xs font-bold text-slate-900">
            تصفح منتجات المتاجر الصينية
          </span>
          <span className="text-[11px] text-slate-400 font-medium">
            اسحب أفقياً لاختيار المتجر
          </span>
        </div>

        <MarketplaceAppIcons />
      </section>

      {/* 3. Recommended Products Grid (Spacious, Clean, High Contrast) */}
      <section className="space-y-3 pt-1">
        <div className="flex items-center justify-between px-1">
          <div className="flex items-center gap-1.5">
            <Sparkles size={15} className="text-amber-500" />
            <h2 className="text-xs font-bold text-slate-900">
              منتجات مقترحة للشراء المباشر
            </h2>
          </div>
          <span className="text-[11px] text-slate-500">
            {products.length} منتجات مميزة
          </span>
        </div>

        {/* Products Grid */}
        <div className="grid grid-cols-2 gap-3 sm:gap-4">
          {products.map((product) => (
            <ProductCard key={product.id} product={product} layout="grid" />
          ))}
        </div>
      </section>
    </div>
  );
};
