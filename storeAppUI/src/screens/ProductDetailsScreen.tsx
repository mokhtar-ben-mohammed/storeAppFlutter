import React, { useState } from 'react';
import {
  Heart,
  ShoppingBag,
  Star,
  CheckCircle2,
  ChevronDown,
  ChevronUp,
  ShieldCheck,
  Truck,
  Sparkles,
  Share2,
  HelpCircle,
  ExternalLink,
  Info,
} from 'lucide-react';
import { useApp } from '../context/AppContext';
import { StoreBadge } from '../components/StoreBadge';
import { TopHeader } from '../components/TopHeader';

export const ProductDetailsScreen: React.FC = () => {
  const {
    selectedProduct,
    addToCart,
    toggleFavorite,
    isFavorite,
    formatPrice,
    convertPrice,
    proceedToCheckout,
    currency,
    showToast,
  } = useApp();

  const [activeImageIndex, setActiveImageIndex] = useState(0);
  const [selectedVariantId, setSelectedVariantId] = useState<string>(
    selectedProduct?.variants[0]?.id || ''
  );
  const [quantity, setQuantity] = useState(1);
  const [showPriceBreakdown, setShowPriceBreakdown] = useState(true);

  if (!selectedProduct) {
    return (
      <div className="p-8 text-center text-slate-500">
        لم يتم العثور على المنتج المطلوب.
      </div>
    );
  }

  const selectedVariant =
    selectedProduct.variants.find((v) => v.id === selectedVariantId) ||
    selectedProduct.variants[0];

  const unitPriceCny =
    selectedProduct.originalPriceCny + (selectedVariant?.priceModifierCny || 0);

  // Check if bulk wholesale discount applies (from 1688 tiers)
  let activeTierPriceCny = unitPriceCny;
  if (selectedProduct.wholesaleTiers) {
    const matchedTier = [...selectedProduct.wholesaleTiers]
      .reverse()
      .find((t) => quantity >= t.minQty);
    if (matchedTier) {
      activeTierPriceCny = matchedTier.priceCny;
    }
  }

  const itemsTotalCny = activeTierPriceCny * quantity;
  const itemsConverted = convertPrice(itemsTotalCny);
  const burhanServiceFee =
    currency === 'YER'
      ? Math.round(itemsConverted * 0.05 + 500)
      : Number((itemsConverted * 0.05 + 1).toFixed(2));
  const estShipping =
    currency === 'YER' ? 4500 * Math.max(1, selectedProduct.weightKg) : 8.5;
  const estimatedTotal = itemsConverted + burhanServiceFee + Math.round(estShipping);

  const favorited = isFavorite(selectedProduct.id);

  const handleAddToCart = () => {
    addToCart(selectedProduct, selectedVariantId, quantity);
  };

  const handleBuyNow = () => {
    addToCart(selectedProduct, selectedVariantId, quantity);
    proceedToCheckout();
  };

  return (
    <div className="min-h-screen bg-slate-50 text-right pb-28">
      {/* Top Header */}
      <TopHeader
        title="تفاصيل المنتج"
        showBack={true}
        rightAction={
          <div className="flex items-center gap-1.5">
            <button
              onClick={() => toggleFavorite(selectedProduct.id)}
              className="w-9 h-9 rounded-xl bg-slate-100 flex items-center justify-center text-slate-600 hover:text-rose-500 active-press"
              aria-label="المفضلة"
            >
              <Heart size={18} className={favorited ? 'text-rose-500 fill-rose-500' : ''} />
            </button>
            <button
              onClick={() => {
                if (navigator.clipboard) {
                  navigator.clipboard.writeText(window.location.href);
                }
                showToast('تم نسخ رابط المنتج للمشاركة');
              }}
              className="w-9 h-9 rounded-xl bg-slate-100 flex items-center justify-center text-slate-600 hover:text-slate-900 active-press"
              aria-label="مشاركة"
            >
              <Share2 size={17} />
            </button>
          </div>
        }
      />

      {/* 1. Main Image Gallery */}
      <div className="relative bg-white border-b border-slate-200/80">
        <div className="relative aspect-square w-full max-w-md mx-auto overflow-hidden bg-slate-100">
          <img
            src={selectedProduct.images[activeImageIndex] || selectedProduct.images[0]}
            alt={selectedProduct.title}
            className="w-full h-full object-cover"
          />

          {/* Store & Supplier Floating Badge */}
          <div className="absolute top-3 start-3 flex flex-col gap-1.5 items-start">
            <StoreBadge store={selectedProduct.store} size="md" />
            {selectedProduct.isVerifiedSupplier && (
              <span className="inline-flex items-center gap-1 text-[10px] font-bold bg-[#0B2038]/90 text-white px-2 py-0.5 rounded-md shadow-xs backdrop-blur-xs">
                <CheckCircle2 size={11} className="text-amber-400" />
                مورد معتمد
              </span>
            )}
          </div>

          {/* Original Store Link */}
          {selectedProduct.storeUrl && (
            <a
              href={selectedProduct.storeUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="absolute top-3 end-3 flex items-center gap-1 bg-white/90 backdrop-blur-xs text-slate-700 text-[10px] font-medium px-2 py-1 rounded-lg border border-slate-200 shadow-xs hover:text-[#0B2038]"
            >
              <span>المصدر الأصلي</span>
              <ExternalLink size={11} />
            </a>
          )}
        </div>

        {/* Thumbnails row */}
        {selectedProduct.images.length > 1 && (
          <div className="flex items-center gap-2 p-3 overflow-x-auto no-scrollbar justify-center max-w-md mx-auto">
            {selectedProduct.images.map((img, idx) => (
              <button
                key={idx}
                onClick={() => setActiveImageIndex(idx)}
                className={`relative w-14 h-14 rounded-xl overflow-hidden border-2 transition-all shrink-0 active-press ${
                  activeImageIndex === idx ? 'border-amber-500 scale-105 shadow-xs' : 'border-slate-200 opacity-60'
                }`}
              >
                <img src={img} alt="" className="w-full h-full object-cover" />
              </button>
            ))}
          </div>
        )}
      </div>

      <div className="max-w-md mx-auto px-4 py-4 space-y-4">
        {/* 2. Product Title & Supplier Information */}
        <div className="bg-white rounded-2xl p-4 border border-slate-200/80 shadow-xs space-y-2.5">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-1.5 text-xs text-amber-500 font-bold">
              <Star size={14} className="fill-amber-400 text-amber-400" />
              <span>{selectedProduct.rating}</span>
              <span className="text-slate-400 font-normal">
                ({selectedProduct.salesCount} طلب شراء عبر برهان)
              </span>
            </div>
            <span className="text-[11px] text-slate-500">
              الوزن التقريبي: {selectedProduct.weightKg} كجم
            </span>
          </div>

          <h1 className="text-sm font-bold font-cairo text-slate-900 leading-snug">
            {selectedProduct.title}
          </h1>

          <div className="flex items-center justify-between pt-2 border-t border-slate-100 text-xs text-slate-600">
            <span className="truncate max-w-[220px]">
              المصنع: <strong className="text-slate-800">{selectedProduct.supplierName}</strong>
            </span>
            <span className="text-emerald-700 font-medium bg-emerald-50 px-2 py-0.5 rounded-md">
              تقييم المصنع {selectedProduct.supplierRating} / 5
            </span>
          </div>
        </div>

        {/* 3. Transparent Price Breakdown Card (Burhan Proxy Concept) */}
        <div className="bg-white rounded-2xl border border-slate-200/80 shadow-xs overflow-hidden">
          <div
            onClick={() => setShowPriceBreakdown(!showPriceBreakdown)}
            className="flex items-center justify-between p-4 cursor-pointer hover:bg-slate-50/50 transition-colors"
          >
            <div>
              <span className="text-[10px] text-slate-400 block font-medium">
                إجمالي التكلفة التقديرية لباب بيتك:
              </span>
              <div className="text-lg font-black font-cairo text-[#0B2038]">
                {estimatedTotal.toLocaleString('en-US')} {formatPrice(0).symbol}
              </div>
            </div>

            <div className="flex items-center gap-1 text-xs font-bold font-cairo text-amber-600 bg-amber-50 px-2.5 py-1.5 rounded-xl border border-amber-200/60">
              <Info size={14} />
              <span>تفصيل الرسوم</span>
              {showPriceBreakdown ? <ChevronUp size={14} /> : <ChevronDown size={14} />}
            </div>
          </div>

          {showPriceBreakdown && (
            <div className="px-4 pb-4 pt-1 border-t border-slate-100 space-y-2 text-xs">
              <div className="flex items-center justify-between text-slate-600">
                <span>سعر المنتج من المصنع الصيني:</span>
                <span className="font-bold font-mono dir-ltr">
                  ¥{itemsTotalCny} ({itemsConverted.toLocaleString('en-US')} {formatPrice(0).symbol})
                </span>
              </div>

              <div className="flex items-center justify-between text-slate-600">
                <span className="flex items-center gap-1">
                  <span>رسوم خدمة وفحص برهان (5%):</span>
                  <span className="text-[10px] text-amber-600 font-medium">
                    (فحص جودة وتصوير)
                  </span>
                </span>
                <span className="font-bold font-mono">
                  {burhanServiceFee.toLocaleString('en-US')} {formatPrice(0).symbol}
                </span>
              </div>

              <div className="flex items-center justify-between text-slate-600">
                <span>الشحن الدولي التقديري (جوي موحد):</span>
                <span className="font-bold font-mono">
                  {Math.round(estShipping).toLocaleString('en-US')} {formatPrice(0).symbol}
                </span>
              </div>

              <div className="pt-2 border-t border-dashed border-slate-200 flex items-center justify-between text-[#0B2038] font-bold">
                <span>المجموع المقدر:</span>
                <span className="text-sm font-black font-cairo">
                  {estimatedTotal.toLocaleString('en-US')} {formatPrice(0).symbol}
                </span>
              </div>

              <p className="text-[10px] text-slate-400 pt-1 leading-normal">
                * يتم تأكيد الوزن الفعلي ورسوم الشحن بدقة فور وصول الطرد إلى مستودع قوانغتشو ووزنه على الميزان الإلكتروني.
              </p>
            </div>
          )}
        </div>

        {/* 4. Wholesale Pricing Tiers (Special for 1688) */}
        {selectedProduct.wholesaleTiers && (
          <div className="bg-amber-50/70 border border-amber-200/80 rounded-2xl p-3.5 space-y-2">
            <div className="flex items-center gap-1.5 text-xs font-bold font-cairo text-amber-900">
              <Sparkles size={14} className="text-amber-600" />
              <span>أسعار الجملة المباشرة من المصنع (1688):</span>
            </div>

            <div className="grid grid-cols-3 gap-2">
              {selectedProduct.wholesaleTiers.map((tier, idx) => {
                const isSelectedTier = quantity >= tier.minQty;
                return (
                  <div
                    key={idx}
                    className={`rounded-xl p-2 text-center border transition-all ${
                      isSelectedTier
                        ? 'bg-white border-amber-400 shadow-xs'
                        : 'bg-white/60 border-amber-100 text-slate-400'
                    }`}
                  >
                    <span className="text-[10px] block font-bold text-slate-700">
                      {tier.minQty}+ قطع
                    </span>
                    <span className="text-xs font-black font-cairo text-amber-700">
                      ¥{tier.priceCny}
                    </span>
                  </div>
                );
              })}
            </div>
          </div>
        )}

        {/* 5. Variants Selector */}
        {selectedProduct.variants.length > 0 && (
          <div className="bg-white rounded-2xl p-4 border border-slate-200/80 shadow-xs space-y-3">
            <div className="flex items-center justify-between">
              <h3 className="text-xs font-bold font-cairo text-slate-900">
                الخيارات والمواصفات:
              </h3>
              <span className="text-xs text-amber-600 font-bold">
                {selectedVariant?.name}
              </span>
            </div>

            <div className="flex flex-wrap gap-2">
              {selectedProduct.variants.map((v) => {
                const isCurrent = v.id === selectedVariantId;
                return (
                  <button
                    key={v.id}
                    onClick={() => setSelectedVariantId(v.id)}
                    className={`flex items-center gap-2 px-3 py-2 rounded-xl text-xs font-semibold border transition-all active-press ${
                      isCurrent
                        ? 'bg-[#0B2038] text-white border-[#0B2038] shadow-xs'
                        : 'bg-slate-50 text-slate-700 border-slate-200 hover:bg-slate-100'
                    }`}
                  >
                    {v.colorHex && (
                      <span
                        className="w-3.5 h-3.5 rounded-full border border-white/40 shrink-0"
                        style={{ backgroundColor: v.colorHex }}
                      />
                    )}
                    <span>{v.name}</span>
                    {v.priceModifierCny ? (
                      <span className="text-[10px] opacity-75 dir-ltr">
                        (+¥{v.priceModifierCny})
                      </span>
                    ) : null}
                  </button>
                );
              })}
            </div>
          </div>
        )}

        {/* 6. Quantity Stepper */}
        <div className="bg-white rounded-2xl p-4 border border-slate-200/80 shadow-xs flex items-center justify-between">
          <div>
            <h3 className="text-xs font-bold font-cairo text-slate-900">الكمية المطلوبة</h3>
            <span className="text-[11px] text-slate-400">
              {selectedProduct.wholesaleTiers ? 'الخصم يزداد بزيادة الكمية' : 'متوفر بالمخزون'}
            </span>
          </div>

          <div className="flex items-center gap-3 bg-slate-100 rounded-xl p-1 border border-slate-200">
            <button
              onClick={() => setQuantity((q) => Math.max(1, q - 1))}
              disabled={quantity <= 1}
              className="w-8 h-8 rounded-lg bg-white flex items-center justify-center font-bold text-slate-700 hover:bg-slate-200 disabled:opacity-40 active-press shadow-xs"
              aria-label="إنقاص الكمية"
            >
              −
            </button>
            <span className="w-8 text-center text-sm font-bold font-cairo text-slate-900">
              {quantity}
            </span>
            <button
              onClick={() => setQuantity((q) => q + 1)}
              className="w-8 h-8 rounded-lg bg-white flex items-center justify-center font-bold text-slate-700 hover:bg-slate-200 active-press shadow-xs"
              aria-label="زيادة الكمية"
            >
              +
            </button>
          </div>
        </div>

        {/* 7. Product Specs Accordion */}
        <div className="bg-white rounded-2xl p-4 border border-slate-200/80 shadow-xs space-y-3">
          <h3 className="text-xs font-bold font-cairo text-slate-900">
            المواصفات الفنية المترجمة:
          </h3>
          <div className="divide-y divide-slate-100 text-xs">
            {selectedProduct.specs.map((spec, i) => (
              <div key={i} className="py-2 flex items-center justify-between">
                <span className="text-slate-500">{spec.label}</span>
                <span className="font-semibold text-slate-800">{spec.value}</span>
              </div>
            ))}
          </div>

          <div className="pt-2 border-t border-slate-100 text-xs text-slate-600 leading-relaxed">
            <p>{selectedProduct.description}</p>
          </div>
        </div>

        {/* 8. Burhan Guarantee Checklist */}
        <div className="bg-slate-900 text-white rounded-2xl p-4 text-xs space-y-2">
          <div className="flex items-center gap-1.5 font-bold font-cairo text-amber-400">
            <ShieldCheck size={16} />
            <span>ماذا يحدث بعد أن تطلب هذا المنتج؟</span>
          </div>
          <ol className="list-decimal list-inside space-y-1 text-slate-300 leading-relaxed text-[11px]">
            <li>يقوم فريق برهان في قوانغتشو بشرائه فوراً من المصنع.</li>
            <li>يصل المستودع خلال 2-3 أيام ويتم تصويره وإرسال الصور لك.</li>
            <li>يُشحن بأمان بالطيران أو البحر ويصل إلى عنوانك في اليمن.</li>
          </ol>
        </div>
      </div>

      {/* Sticky Bottom Actions Bar */}
      <div className="fixed bottom-0 left-0 right-0 z-40 bg-white/95 backdrop-blur-md border-t border-slate-200 p-3 shadow-lg">
        <div className="max-w-md mx-auto flex items-center gap-2">
          {/* Add to Cart button */}
          <button
            onClick={handleAddToCart}
            className="flex-1 h-12 rounded-xl bg-slate-100 hover:bg-slate-200 text-[#0B2038] font-bold font-cairo text-xs flex items-center justify-center gap-1.5 transition-colors active-press border border-slate-200 cursor-pointer"
          >
            <ShoppingBag size={16} />
            <span>أضف إلى السلة</span>
          </button>

          {/* Buy Now button */}
          <button
            onClick={handleBuyNow}
            className="flex-1 h-12 rounded-xl bg-[#0B2038] hover:bg-slate-800 text-white font-bold font-cairo text-xs flex items-center justify-center gap-1.5 shadow-md shadow-[#0B2038]/20 transition-all active-press cursor-pointer"
          >
            <span>شراء فوري</span>
          </button>
        </div>
      </div>
    </div>
  );
};
