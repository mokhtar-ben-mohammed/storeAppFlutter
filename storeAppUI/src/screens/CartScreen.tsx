import React from 'react';
import {
  Trash2,
  Heart,
  ShoppingBag,
  CheckSquare,
  Square,
  ArrowRight,
  ShieldCheck,
  AlertCircle,
  Sparkles,
} from 'lucide-react';
import { useApp } from '../context/AppContext';
import { StoreBadge } from '../components/StoreBadge';

export const CartScreen: React.FC = () => {
  const {
    cart,
    toggleCartItemSelection,
    selectAllCartItems,
    deselectAllCartItems,
    updateCartQuantity,
    removeCartItem,
    removeSelectedCartItems,
    moveToFavoritesFromCart,
    selectedCartItems,
    selectedCartTotalCny,
    formatPrice,
    convertPrice,
    proceedToCheckout,
    setActiveTab,
    openProductDetails,
  } = useApp();

  const allSelected = cart.length > 0 && cart.every((item) => item.isSelected);
  const noneSelected = selectedCartItems.length === 0;

  // Selected totals
  const selectedItemsConverted = convertPrice(selectedCartTotalCny);
  const priceInfo = formatPrice(selectedCartTotalCny);

  if (cart.length === 0) {
    return (
      <div className="min-h-[75vh] flex flex-col items-center justify-center p-6 text-center text-right">
        <div className="w-22 h-22 rounded-3xl bg-amber-50 text-amber-600 flex items-center justify-center mb-5 shadow-xs">
          <ShoppingBag size={40} />
        </div>
        <h2 className="text-xl font-black font-cairo text-slate-900 mb-1.5">
          سلة التسوق فارغة حالياً
        </h2>
        <p className="text-xs text-slate-500 max-w-xs mb-6 leading-relaxed">
          تصفح آلاف المنتجات من 1688، تاوباو، جوفيش وعلي إكسبريس وأضف ما يعجبك لنشتريه ونفحصه لك!
        </p>
        <button
          onClick={() => setActiveTab('home')}
          className="bg-[#0B2038] hover:bg-slate-800 text-white font-bold font-cairo text-xs px-7 py-3.5 rounded-2xl shadow-md shadow-[#0B2038]/15 active-press transition-all cursor-pointer"
        >
          ابدأ التسوق واستكشاف المنتجات
        </button>
      </div>
    );
  }

  return (
    <div className="pb-40 px-4 pt-4 text-right max-w-md mx-auto space-y-4 min-h-[85vh]">
      {/* 1. Header Toolbar with Select All & Delete Selected */}
      <div className="bg-white rounded-2xl p-3 border border-slate-200/80 shadow-xs flex items-center justify-between">
        {/* Select All Toggle */}
        <button
          onClick={() => (allSelected ? deselectAllCartItems() : selectAllCartItems())}
          className="flex items-center gap-2 text-xs font-bold font-cairo text-slate-800 hover:text-[#0B2038] active-press cursor-pointer"
        >
          {allSelected ? (
            <CheckSquare size={19} className="text-amber-500" />
          ) : (
            <Square size={19} className="text-slate-400" />
          )}
          <span>تحديد الكل ({cart.length})</span>
        </button>

        {/* Delete Selected Action */}
        {!noneSelected && (
          <button
            onClick={removeSelectedCartItems}
            className="flex items-center gap-1 text-[11px] font-semibold text-rose-600 hover:text-rose-700 bg-rose-50 hover:bg-rose-100 px-2.5 py-1.5 rounded-xl transition-colors active-press"
          >
            <Trash2 size={13} />
            <span>حذف المحدد ({selectedCartItems.length})</span>
          </button>
        )}
      </div>

      {/* Partial Selection Notice Banner */}
      <div className="bg-amber-50/70 border border-amber-200/80 rounded-2xl p-3 flex items-start gap-2.5 text-xs text-amber-900">
        <Sparkles size={16} className="text-amber-600 shrink-0 mt-0.5" />
        <div className="space-y-0.5">
          <span className="font-bold font-cairo block">
            خاصية الشراء الجزئي الذكي (Partial Checkout)
          </span>
          <p className="text-[11px] text-amber-800 leading-snug">
            حدد المنتجات التي ترغب بشرائها الآن، وستبقى بقية المنتجات غير المحددة محفوظة في سلتك بأمان للطلبات القادمة.
          </p>
        </div>
      </div>

      {/* 2. Cart Items List */}
      <div className="space-y-3">
        {cart.map((item) => {
          const itemUnitCny =
            item.product.originalPriceCny + (item.selectedVariant.priceModifierCny || 0);
          const itemTotalCny = itemUnitCny * item.quantity;
          const itemPriceInfo = formatPrice(itemTotalCny);

          return (
            <div
              key={item.id}
              className={`relative bg-white rounded-2xl p-3.5 border transition-all ${
                item.isSelected
                  ? 'border-amber-300 shadow-xs ring-1 ring-amber-300/40'
                  : 'border-slate-200/80 opacity-80'
              }`}
            >
              <div className="flex items-start gap-3">
                {/* Custom Checkbox */}
                <button
                  type="button"
                  onClick={() => toggleCartItemSelection(item.id)}
                  aria-label={item.isSelected ? 'إلغاء تحديد المنتج' : 'تحديد المنتج للشراء'}
                  className="mt-6 text-slate-400 hover:text-amber-500 active-press cursor-pointer shrink-0"
                >
                  {item.isSelected ? (
                    <CheckSquare size={20} className="text-amber-500" />
                  ) : (
                    <Square size={20} className="text-slate-400" />
                  )}
                </button>

                {/* Product Thumbnail */}
                <div
                  onClick={() => openProductDetails(item.product)}
                  className="relative w-20 h-20 rounded-xl overflow-hidden bg-slate-100 border border-slate-100 shrink-0 cursor-pointer"
                >
                  <img
                    src={item.product.images[0]}
                    alt={item.product.title}
                    className="w-full h-full object-cover"
                  />
                  <div className="absolute top-1 start-1">
                    <StoreBadge store={item.product.store} size="sm" showLabel={false} />
                  </div>
                </div>

                {/* Item Details */}
                <div className="flex-1 min-w-0">
                  <div className="flex items-start justify-between gap-1">
                    <h3
                      onClick={() => openProductDetails(item.product)}
                      className="text-xs font-semibold text-slate-900 line-clamp-2 leading-snug cursor-pointer hover:text-amber-600 transition-colors"
                    >
                      {item.product.title}
                    </h3>

                    {/* Delete single button */}
                    <button
                      onClick={() => removeCartItem(item.id)}
                      className="text-slate-400 hover:text-rose-500 p-1 rounded-lg transition-colors active-press shrink-0"
                      aria-label="حذف"
                    >
                      <Trash2 size={15} />
                    </button>
                  </div>

                  {/* Variant info */}
                  <div className="mt-1 flex items-center gap-1.5 text-[11px] text-slate-500">
                    <span className="bg-slate-100 px-2 py-0.5 rounded text-slate-700 font-medium">
                      {item.selectedVariant.name}
                    </span>
                    <button
                      onClick={() => moveToFavoritesFromCart(item.id)}
                      className="text-slate-400 hover:text-rose-500 flex items-center gap-0.5 text-[10px]"
                    >
                      <Heart size={11} />
                      <span>للمفضلة</span>
                    </button>
                  </div>

                  {/* Price & Stepper Row */}
                  <div className="mt-3 flex items-center justify-between pt-2 border-t border-slate-100">
                    <div>
                      <span className="text-[10px] text-slate-400 block line-through">
                        ¥{itemTotalCny} (سعر الصين)
                      </span>
                      <div className="text-xs font-bold font-cairo text-[#0B2038]">
                        {itemPriceInfo.formatted}
                      </div>
                    </div>

                    {/* Stepper */}
                    <div className="flex items-center gap-2 bg-slate-100 rounded-xl p-0.5 border border-slate-200">
                      <button
                        onClick={() => updateCartQuantity(item.id, -1)}
                        className="w-7 h-7 rounded-lg bg-white flex items-center justify-center font-bold text-slate-700 hover:bg-slate-200 active-press shadow-xs"
                        aria-label="إنقاص"
                      >
                        −
                      </button>
                      <span className="w-6 text-center text-xs font-bold font-cairo text-slate-900">
                        {item.quantity}
                      </span>
                      <button
                        onClick={() => updateCartQuantity(item.id, 1)}
                        className="w-7 h-7 rounded-lg bg-white flex items-center justify-center font-bold text-slate-700 hover:bg-slate-200 active-press shadow-xs"
                        aria-label="زيادة"
                      >
                        +
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {/* 3. Sticky Bottom Checkout Bar (Respects 15% Cap) */}
      <div className="fixed bottom-16 left-0 right-0 z-40 bg-white/95 backdrop-blur-md border-t border-slate-200 p-3 shadow-[0_-4px_16px_rgba(0,0,0,0.06)]">
        <div className="max-w-md mx-auto flex items-center justify-between gap-3">
          {/* Price Summary */}
          <div>
            <div className="flex items-center gap-1.5 text-xs text-slate-500">
              <span>المحدد للشراء:</span>
              <strong className="text-amber-600 font-bold font-cairo">
                {selectedCartItems.length} من أصل {cart.length}
              </strong>
            </div>

            <div className="text-base font-black font-cairo text-[#0B2038]">
              {noneSelected ? '0' : priceInfo.formatted}
            </div>
          </div>

          {/* Checkout CTA */}
          <button
            onClick={proceedToCheckout}
            disabled={noneSelected}
            className="flex-1 max-w-[200px] h-12 rounded-xl bg-[#0B2038] hover:bg-slate-800 disabled:bg-slate-300 disabled:cursor-not-allowed text-white font-bold font-cairo text-xs flex items-center justify-center gap-1.5 shadow-md shadow-[#0B2038]/20 transition-all active-press cursor-pointer"
          >
            <span>إكمال الشراء ({selectedCartItems.length})</span>
            <ArrowRight size={16} className="rotate-180" />
          </button>
        </div>
      </div>
    </div>
  );
};
