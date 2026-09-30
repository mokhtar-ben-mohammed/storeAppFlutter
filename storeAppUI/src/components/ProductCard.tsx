import React, { useState } from 'react';
import { Heart, Plus, Star, CheckCircle2, Image as ImageIcon } from 'lucide-react';
import { Product } from '../types';
import { StoreBadge } from './StoreBadge';
import { useApp } from '../context/AppContext';

interface ProductCardProps {
  product: Product;
  layout?: 'grid' | 'horizontal';
}

export const ProductCard: React.FC<ProductCardProps> = ({ product, layout = 'grid' }) => {
  const { openProductDetails, addToCart, toggleFavorite, isFavorite, formatPrice } = useApp();
  const [imageError, setImageError] = useState(false);

  const favorited = isFavorite(product.id);
  const priceInfo = formatPrice(product.originalPriceCny);

  if (layout === 'horizontal') {
    return (
      <div
        onClick={() => openProductDetails(product)}
        className="group relative flex bg-white/90 backdrop-blur-xs rounded-xl p-2.5 border border-slate-200/70 shadow-xs hover:border-amber-300 transition-all cursor-pointer active-press"
      >
        {/* Product Image */}
        <div className="relative w-24 h-24 shrink-0 rounded-lg overflow-hidden bg-slate-100 border border-slate-100">
          {!imageError ? (
            <img
              src={product.images[0]}
              alt={product.title}
              onError={() => setImageError(true)}
              loading="lazy"
              referrerPolicy="no-referrer"
              className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
            />
          ) : (
            <div className="w-full h-full flex flex-col items-center justify-center bg-slate-100 text-slate-400 p-2 text-center">
              <ImageIcon size={20} className="mb-1 text-slate-400" />
              <span className="text-[9px] line-clamp-1">{product.store}</span>
            </div>
          )}

          <div className="absolute top-1.5 start-1.5">
            <StoreBadge store={product.store} size="sm" showLabel={false} />
          </div>
        </div>

        {/* Info */}
        <div className="flex-1 ms-3 flex flex-col justify-between py-0.5 text-right">
          <div>
            <div className="flex items-center justify-between gap-1">
              <div className="flex items-center gap-1 text-[11px] text-amber-500 font-bold">
                <Star size={12} className="fill-amber-400 text-amber-400" />
                <span>{product.rating}</span>
                <span className="text-slate-400 font-normal">({product.salesCount})</span>
              </div>
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  toggleFavorite(product.id);
                }}
                className="w-7 h-7 rounded-md flex items-center justify-center text-slate-400 hover:text-rose-500 active-press"
              >
                <Heart size={15} className={favorited ? 'text-rose-500 fill-rose-500' : ''} />
              </button>
            </div>

            <h3 className="text-xs font-semibold text-slate-900 line-clamp-2 mt-1 leading-snug">
              {product.title}
            </h3>
          </div>

          <div className="flex items-end justify-between mt-2 pt-1 border-t border-slate-100">
            <div>
              <span className="text-[10px] text-slate-400 block line-through">
                ¥{product.originalPriceCny} (الصين)
              </span>
              <span className="text-xs font-bold text-[#0B2038]">
                {priceInfo.formatted}
              </span>
            </div>

            <button
              onClick={(e) => {
                e.stopPropagation();
                addToCart(product);
              }}
              className="w-7 h-7 rounded-lg bg-[#0B2038] text-white flex items-center justify-center hover:bg-amber-600 transition-colors active-press shadow-xs"
              aria-label="أضف إلى السلة"
            >
              <Plus size={15} />
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div
      onClick={() => openProductDetails(product)}
      className="group relative flex flex-col bg-white/90 backdrop-blur-xs rounded-xl overflow-hidden border border-slate-200/70 shadow-xs hover:shadow-md hover:border-amber-300 transition-all cursor-pointer active-press text-right"
    >
      {/* Image container */}
      <div className="relative aspect-square w-full overflow-hidden bg-slate-100">
        {!imageError ? (
          <img
            src={product.images[0]}
            alt={product.title}
            onError={() => setImageError(true)}
            loading="lazy"
            referrerPolicy="no-referrer"
            className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
          />
        ) : (
          <div className="w-full h-full flex flex-col items-center justify-center bg-slate-100 text-slate-400 p-4 text-center">
            <ImageIcon size={28} className="mb-1 text-slate-400" />
            <span className="text-xs font-medium">{product.title.slice(0, 15)}...</span>
          </div>
        )}

        {/* Store Badge */}
        <div className="absolute top-2 start-2 flex flex-col gap-1 items-start">
          <StoreBadge store={product.store} size="sm" />
          {product.isVerifiedSupplier && (
            <span className="inline-flex items-center gap-0.5 text-[9px] font-bold bg-[#0B2038]/85 text-white px-1.5 py-0.5 rounded shadow-xs backdrop-blur-xs">
              <CheckCircle2 size={10} className="text-amber-400" />
              مورد موثوق
            </span>
          )}
        </div>

        {/* Favorite Button */}
        <button
          onClick={(e) => {
            e.stopPropagation();
            toggleFavorite(product.id);
          }}
          className="absolute top-2 end-2 w-7 h-7 rounded-lg bg-white/90 backdrop-blur-xs flex items-center justify-center text-slate-500 hover:text-rose-500 shadow-xs transition-colors active-press"
          aria-label="إضافة للمفضلة"
        >
          <Heart size={14} className={favorited ? 'text-rose-500 fill-rose-500' : ''} />
        </button>

        {/* Rating overlay badge */}
        <div className="absolute bottom-2 start-2 px-1.5 py-0.5 rounded-md bg-black/65 backdrop-blur-xs text-white text-[10px] font-medium flex items-center gap-1">
          <Star size={10} className="fill-amber-400 text-amber-400" />
          <span>{product.rating}</span>
        </div>
      </div>

      {/* Details container */}
      <div className="p-3 flex flex-col justify-between flex-1">
        <div>
          <h3 className="text-xs font-semibold text-slate-900 line-clamp-2 leading-relaxed group-hover:text-amber-700 transition-colors">
            {product.title}
          </h3>

          <div className="mt-1 flex items-center gap-1 text-[10px] text-slate-400">
            <span>سعر الصين: ¥{product.originalPriceCny}</span>
            <span>·</span>
            <span>{product.salesCount}+ مبيع</span>
          </div>
        </div>

        {/* Price & Action row */}
        <div className="mt-2.5 pt-2 border-t border-slate-100 flex items-center justify-between">
          <div>
            <span className="text-[10px] text-slate-400 block font-medium">سعر برهان:</span>
            <div className="text-xs font-bold text-[#0B2038] tracking-tight">
              {priceInfo.formatted}
            </div>
          </div>

          <button
            onClick={(e) => {
              e.stopPropagation();
              addToCart(product);
            }}
            className="w-7 h-7 rounded-lg bg-[#0B2038] text-white flex items-center justify-center hover:bg-amber-600 transition-colors active-press shadow-xs"
            aria-label="أضف إلى السلة"
          >
            <Plus size={15} strokeWidth={2.5} />
          </button>
        </div>
      </div>
    </div>
  );
};
