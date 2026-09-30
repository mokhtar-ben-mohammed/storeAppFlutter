import React from 'react';
import {
  CheckCircle2,
  Clock,
  MapPin,
  Truck,
  CreditCard,
  Copy,
  Package,
  Plane,
  Camera,
  Play,
  RotateCcw,
  Sparkles,
} from 'lucide-react';
import { useApp } from '../context/AppContext';
import { TopHeader } from '../components/TopHeader';
import { StoreBadge } from '../components/StoreBadge';

export const OrderDetailsScreen: React.FC = () => {
  const {
    orders,
    selectedOrderId,
    advanceOrderStatus,
    formatPrice,
    showToast,
  } = useApp();

  const order = orders.find((o) => o.id === selectedOrderId) || orders[0];

  if (!order) {
    return (
      <div className="p-8 text-center text-slate-500">
        لم يتم العثور على تفاصيل هذا الطلب.
      </div>
    );
  }

  const handleCopy = (text: string, label: string) => {
    if (navigator.clipboard) {
      navigator.clipboard.writeText(text);
    }
    showToast(`تم نسخ ${label}: ${text}`);
  };

  return (
    <div className="min-h-screen bg-slate-50 text-right pb-28">
      {/* Header */}
      <TopHeader title={`تتبع الطلب ${order.orderNumber}`} showBack={true} />

      <div className="max-w-md mx-auto px-4 pt-3 space-y-4">
        {/* Interactive Demo Control Banner for Reviewers */}
        <div className="bg-gradient-to-r from-amber-500/15 via-amber-500/10 to-transparent border border-amber-300/80 rounded-2xl p-3 flex items-center justify-between">
          <div className="space-y-0.5">
            <span className="text-[11px] font-bold font-cairo text-amber-950 flex items-center gap-1">
              <Sparkles size={14} className="text-amber-600" />
              أداة محاكاة تتبع الشحنة المباشرة:
            </span>
            <p className="text-[10px] text-amber-800">
              اضغط لتقديم حالة الشحنة خطوة وتحديث المسار التفاعلي!
            </p>
          </div>

          <button
            onClick={() => advanceOrderStatus(order.id)}
            className="flex items-center gap-1 bg-[#0B2038] hover:bg-slate-800 text-white text-xs font-bold font-cairo px-3 py-1.5 rounded-xl shadow-xs active-press shrink-0"
          >
            <Play size={12} className="fill-white" />
            <span>قدم الحالة خطوة</span>
          </button>
        </div>

        {/* 1. Status Overview Card */}
        <div className="bg-white rounded-3xl p-5 border border-slate-200/80 shadow-xs space-y-3">
          <div className="flex items-center justify-between pb-3 border-b border-slate-100">
            <div>
              <span className="text-[10px] text-slate-400 block">رقم التتبع الدولي:</span>
              <div className="flex items-center gap-1.5">
                <span className="font-mono font-bold text-xs text-[#0B2038]">
                  {order.trackingCode || 'CN-YEM-892104'}
                </span>
                <button
                  onClick={() => handleCopy(order.trackingCode || 'CN-YEM-892104', 'رقم التتبع')}
                  className="text-slate-400 hover:text-slate-700"
                >
                  <Copy size={13} />
                </button>
              </div>
            </div>

            <div className="text-left">
              <span className="text-[10px] text-slate-400 block">تاريخ الإنشاء:</span>
              <span className="text-[11px] font-semibold text-slate-700">
                {new Date(order.createdAt).toLocaleDateString('ar-YE', {
                  year: 'numeric',
                  month: 'short',
                  day: 'numeric',
                })}
              </span>
            </div>
          </div>

          {/* China Warehouse Note & Quality Check Indicator */}
          {order.chinaWarehouseNotes && (
            <div className="bg-slate-50 border border-slate-200/80 rounded-2xl p-3 flex items-start gap-2 text-xs text-slate-700">
              <Camera size={16} className="text-amber-500 shrink-0 mt-0.5" />
              <div>
                <span className="font-bold block text-slate-900 text-[11px]">
                  تقرير فحص مستودع برهان في الصين:
                </span>
                <p className="text-[11px] text-slate-600 leading-snug mt-0.5">
                  {order.chinaWarehouseNotes}
                </p>
              </div>
            </div>
          )}
        </div>

        {/* 2. Interactive Timeline */}
        <div className="bg-white rounded-3xl p-5 border border-slate-200/80 shadow-xs space-y-4">
          <h3 className="text-xs font-bold font-cairo text-slate-900 border-b border-slate-100 pb-2.5">
            مسار وتاريخ مراحل الطلب:
          </h3>

          <div className="relative pr-6 space-y-6 before:absolute before:top-2 before:bottom-2 before:right-2.5 before:w-0.5 before:bg-slate-200">
            {order.timeline.map((step, idx) => {
              return (
                <div key={idx} className="relative group">
                  {/* Timeline Node Dot */}
                  <div
                    className={`absolute -right-6 top-1 w-5 h-5 rounded-full flex items-center justify-center transition-all ${
                      step.current
                        ? 'bg-amber-500 text-white ring-4 ring-amber-100 shadow-xs'
                        : step.completed
                        ? 'bg-[#0B2038] text-white'
                        : 'bg-white border-2 border-slate-300 text-transparent'
                    }`}
                  >
                    {step.completed && <CheckCircle2 size={12} strokeWidth={2.5} />}
                  </div>

                  <div className="ps-2">
                    <div className="flex items-center justify-between">
                      <h4
                        className={`text-xs font-bold font-cairo ${
                          step.current
                            ? 'text-amber-600'
                            : step.completed
                            ? 'text-slate-900'
                            : 'text-slate-400'
                        }`}
                      >
                        {step.title}
                      </h4>
                      {step.time && (
                        <span className="text-[10px] text-slate-400 font-mono">
                          {step.time}
                        </span>
                      )}
                    </div>

                    <p
                      className={`text-[11px] mt-0.5 leading-relaxed ${
                        step.completed || step.current ? 'text-slate-600' : 'text-slate-400'
                      }`}
                    >
                      {step.description}
                    </p>

                    {step.location && (
                      <span className="inline-flex items-center gap-1 text-[10px] text-slate-400 mt-1">
                        <MapPin size={10} />
                        {step.location}
                      </span>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* 3. Items In This Order */}
        <div className="bg-white rounded-3xl p-5 border border-slate-200/80 shadow-xs space-y-3">
          <h3 className="text-xs font-bold font-cairo text-slate-900 border-b border-slate-100 pb-2">
            محتويات الشحنة ({order.items.length} منتجات):
          </h3>

          <div className="divide-y divide-slate-100">
            {order.items.map((item, i) => {
              const itemUnitCny =
                item.product.originalPriceCny + (item.selectedVariant.priceModifierCny || 0);
              const totalCny = itemUnitCny * item.quantity;
              const priceInfo = formatPrice(totalCny);

              return (
                <div key={i} className="py-2.5 flex items-center gap-3">
                  <div className="relative w-14 h-14 rounded-xl overflow-hidden bg-slate-100 shrink-0">
                    <img
                      src={item.product.images[0]}
                      alt=""
                      className="w-full h-full object-cover"
                    />
                    <div className="absolute top-0.5 start-0.5">
                      <StoreBadge store={item.product.store} size="sm" showLabel={false} />
                    </div>
                  </div>

                  <div className="flex-1 min-w-0">
                    <h4 className="text-xs font-semibold text-slate-900 truncate">
                      {item.product.title}
                    </h4>
                    <div className="flex items-center gap-2 text-[11px] text-slate-500 mt-0.5">
                      <span>{item.selectedVariant.name}</span>
                      <span>·</span>
                      <span>الكمية: {item.quantity}</span>
                    </div>
                    <div className="mt-1 flex items-center justify-between">
                      <span className="text-xs font-bold font-cairo text-[#0B2038]">
                        {priceInfo.formatted}
                      </span>
                      <span className="text-[10px] text-slate-400 dir-ltr">
                        (¥{totalCny})
                      </span>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* 4. Financial & Shipping Summary */}
        <div className="bg-white rounded-3xl p-5 border border-slate-200/80 shadow-xs space-y-2.5 text-xs">
          <h3 className="font-bold font-cairo text-slate-900 border-b border-slate-100 pb-2">
            ملخص الفاتورة والشحن:
          </h3>

          <div className="flex items-center justify-between text-slate-600">
            <span>سعر البضاعة:</span>
            <span className="font-mono">
              {order.breakdown.itemsConverted.toLocaleString('en-US')}{' '}
              {formatPrice(0).symbol}
            </span>
          </div>

          <div className="flex items-center justify-between text-slate-600">
            <span>رسوم فحص وخدمة برهان:</span>
            <span className="font-mono">
              {order.breakdown.burhanFee.toLocaleString('en-US')} {formatPrice(0).symbol}
            </span>
          </div>

          <div className="flex items-center justify-between text-slate-600">
            <span>الشحن الدولي ({order.shippingMethod.nameAr}):</span>
            <span className="font-mono">
              {order.breakdown.shippingCost.toLocaleString('en-US')}{' '}
              {formatPrice(0).symbol}
            </span>
          </div>

          <div className="flex items-center justify-between text-slate-600">
            <span>التخليص والرسوم الجمركية:</span>
            <span className="font-mono">
              {order.breakdown.taxAndCustoms.toLocaleString('en-US')}{' '}
              {formatPrice(0).symbol}
            </span>
          </div>

          <div className="pt-2 border-t border-slate-200 flex items-center justify-between font-bold text-slate-900 text-sm">
            <span>المجموع المدفوع:</span>
            <span className="font-cairo font-black text-amber-600 text-base">
              {order.breakdown.grandTotal.toLocaleString('en-US')} {formatPrice(0).symbol}
            </span>
          </div>
        </div>

        {/* 5. Delivery Address Card */}
        <div className="bg-white rounded-3xl p-4 border border-slate-200/80 shadow-xs text-xs space-y-1.5">
          <div className="flex items-center gap-1.5 font-bold font-cairo text-slate-900">
            <MapPin size={15} className="text-amber-500" />
            <span>عنوان التوصيل المعتمد:</span>
          </div>
          <p className="text-slate-700 font-semibold">{order.address.recipientName}</p>
          <p className="text-slate-500">
            {order.address.country} - {order.address.city} - {order.address.district}
          </p>
          <p className="text-slate-400 text-[11px]">{order.address.street}</p>
          <p className="text-slate-600 font-mono text-[11px] dir-ltr text-right">
            هاتف المستلم: {order.address.phone}
          </p>
        </div>
      </div>
    </div>
  );
};
