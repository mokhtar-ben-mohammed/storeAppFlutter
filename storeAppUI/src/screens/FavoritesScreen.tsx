import React from 'react';
import { Heart, ShoppingBag, ArrowRight } from 'lucide-react';
import { useApp } from '../context/AppContext';
import { TopHeader } from '../components/TopHeader';
import { ProductCard } from '../components/ProductCard';

export const FavoritesScreen: React.FC = () => {
  const { products, favoriteProductIds, setActiveTab } = useApp();

  const favoriteProducts = products.filter((p) => favoriteProductIds.includes(p.id));

  return (
    <div className="min-h-screen bg-slate-50 text-right pb-28">
      <TopHeader title="قائمة المنتجات المفضلة" showBack={true} />

      <div className="max-w-md mx-auto px-4 pt-3 space-y-4">
        <div className="flex items-center justify-between">
          <p className="text-xs text-slate-500">
            المنتجات التي قمت بحفظها للرجوع إليها لاحقاً ({favoriteProducts.length})
          </p>
        </div>

        {favoriteProducts.length > 0 ? (
          <div className="grid grid-cols-2 gap-3">
            {favoriteProducts.map((prod) => (
              <ProductCard key={prod.id} product={prod} layout="grid" />
            ))}
          </div>
        ) : (
          <div className="bg-white rounded-3xl p-8 border border-slate-200/80 text-center space-y-3 my-8">
            <div className="w-16 h-16 rounded-2xl bg-rose-50 text-rose-500 flex items-center justify-center mx-auto">
              <Heart size={32} />
            </div>
            <h3 className="text-sm font-bold font-cairo text-slate-900">
              قائمة المفضلة فارغة حالياً
            </h3>
            <p className="text-xs text-slate-500 max-w-xs mx-auto leading-relaxed">
              اضغط على رمز القلب عند تصفح أي منتج من 1688 أو Taobao لحفظه هنا ومقارنة الأسعار.
            </p>
            <button
              onClick={() => setActiveTab('home')}
              className="bg-[#0B2038] hover:bg-slate-800 text-white text-xs font-bold font-cairo px-5 py-2.5 rounded-xl active-press mt-2"
            >
              استكشف المنتجات الآن
            </button>
          </div>
        )}
      </div>
    </div>
  );
};
