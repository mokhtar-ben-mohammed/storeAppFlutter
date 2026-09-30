import React, { useState } from 'react';
import { useApp } from '../context/AppContext';
import { TopHeader } from '../components/TopHeader';
import { ProductCard } from '../components/ProductCard';
import { Search, ShieldCheck, ArrowRight, Sparkles, Filter } from 'lucide-react';
import { StoreType } from '../types';

export const StoreProductsScreen: React.FC = () => {
  const {
    selectedStoreForView,
    products,
    navigateBack,
    formatPrice,
  } = useApp();

  const store = selectedStoreForView || '1688';
  const [storeSearch, setStoreSearch] = useState('');

  const storeMeta: Record<
    StoreType,
    {
      title: string;
      chineseName: string;
      color: string;
      desc: string;
      badge: string;
    }
  > = {
    '1688': {
      title: 'متجر 1688 (علي بابا الصين)',
      chineseName: '阿里巴巴 1688',
      color: 'from-orange-500 to-amber-600',
      desc: 'بوابة مصانع الصين المباشرة للبيع بالجملة والتجزئة بأقل أسعار التكلفة العالمية.',
      badge: 'أسعار المصانع المباشرة',
    },
    taobao: {
      title: 'متجر تاوباو (Taobao)',
      chineseName: '淘宝网',
      color: 'from-red-500 to-orange-600',
      desc: 'أضخم منصة تسوق صينية لأحدث صيحات الأزياء، الديكورات، والإلكترونيات الحصرية.',
      badge: 'ملايين المنتجات المتجددة',
    },
    goofish: {
      title: 'متجر جوفيش (Goofish / Xianyu)',
      chineseName: '闲鱼二手',
      color: 'from-amber-400 to-yellow-500',
      desc: 'سوق المقتنيات النادرة والأجهزة المستعملة بحالات ممتازة مع فحص سلامة القطع.',
      badge: 'مفحوص ومضمون من برهان',
    },
    aliexpress: {
      title: 'متجر علي إكسبريس (AliExpress)',
      chineseName: '全球速卖通',
      color: 'from-rose-500 to-red-600',
      desc: 'تجزئة دولية سريعة مع عروض موسمية وتنوع ضخم في الإكسسوارات والأجهزة الذكية.',
      badge: 'شحن موحد وسريع',
    },
  };

  const meta = storeMeta[store] || storeMeta['1688'];

  // Filter products by this store and search term
  const storeProducts = products.filter((p) => {
    if (p.store !== store) return false;
    if (storeSearch.trim()) {
      return (
        p.title.toLowerCase().includes(storeSearch.toLowerCase()) ||
        p.description.toLowerCase().includes(storeSearch.toLowerCase())
      );
    }
    return true;
  });

  return (
    <div className="min-h-screen bg-slate-50 text-right pb-32">
      {/* Top Header */}
      <TopHeader title={meta.title} showBack={true} />

      <div className="max-w-md mx-auto px-4 pt-3 space-y-4">
        {/* Store Banner */}
        <div
          className={`rounded-2xl bg-gradient-to-br ${meta.color} text-white p-4 shadow-sm space-y-2 relative overflow-hidden`}
        >
          <div className="flex items-center justify-between">
            <span className="text-[10px] font-bold bg-white/20 backdrop-blur-xs px-2 py-0.5 rounded-md border border-white/25">
              {meta.badge}
            </span>
            <span className="text-xs font-mono font-bold opacity-85">
              {meta.chineseName}
            </span>
          </div>

          <div>
            <h1 className="text-base font-black text-white">
              {meta.title}
            </h1>
            <p className="text-xs text-white/90 leading-relaxed mt-0.5">
              {meta.desc}
            </p>
          </div>

          <div className="pt-1 flex items-center gap-1.5 text-[10px] text-white/95">
            <ShieldCheck size={13} className="text-amber-300" />
            <span>فحص جودة وتصوير حقيقي قبل الشحن لليمن</span>
          </div>
        </div>

        {/* Search within store */}
        <div className="relative">
          <div className="flex items-center bg-white/85 backdrop-blur-md rounded-xl px-3 py-1 border border-slate-200/90 shadow-2xs focus-within:border-[#0B2038]">
            <Search size={16} className="text-slate-400 ms-1" />
            <input
              type="text"
              value={storeSearch}
              onChange={(e) => setStoreSearch(e.target.value)}
              placeholder={`ابحث داخل منتجات ${meta.title}...`}
              className="w-full bg-transparent px-2.5 py-1.5 text-xs font-medium text-slate-900 placeholder:text-slate-400 focus:outline-none"
            />
          </div>
        </div>

        {/* Products Count */}
        <div className="flex items-center justify-between text-xs px-1">
          <span className="font-bold text-slate-800">
            منتجات المتجر المتاحة للشراء ({storeProducts.length})
          </span>
          <span className="text-slate-400 text-[10px]">
            شامل الفحص والشحن لليمن
          </span>
        </div>

        {/* Products Grid */}
        {storeProducts.length > 0 ? (
          <div className="grid grid-cols-2 gap-3 sm:gap-4">
            {storeProducts.map((product) => (
              <ProductCard key={product.id} product={product} layout="grid" />
            ))}
          </div>
        ) : (
          <div className="bg-white/80 backdrop-blur-xs rounded-xl p-8 border border-slate-200/80 text-center space-y-2">
            <p className="text-xs text-slate-500">
              لا توجد منتجات مطابقة لبحثك في هذا المتجر.
            </p>
            <button
              onClick={() => setStoreSearch('')}
              className="text-xs font-bold text-amber-600 hover:underline"
            >
              عرض كافة منتجات المتجر
            </button>
          </div>
        )}
      </div>
    </div>
  );
};
