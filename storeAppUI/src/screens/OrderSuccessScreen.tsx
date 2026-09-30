import React from 'react';
import {
  CheckCircle,
  PackageCheck,
  Home,
  ArrowRight,
  ShieldCheck,
  Copy,
  Clock,
  MapPin,
  Truck,
} from 'lucide-react';
import { useApp } from '../context/AppContext';

export const OrderSuccessScreen: React.FC = () => {
  const { lastCreatedOrder, openOrderDetails, setActiveTab, showToast, formatPrice } =
    useApp();

  if (!lastCreatedOrder) {
    return (
      <div className="p-8 text-center text-slate-500">
        لم يتم العثور على بيانات الطلب.
      </div>
    );
  }

  const handleCopyOrderNumber = () => {
    if (navigator.clipboard) {
      navigator.clipboard.writeText(lastCreatedOrder.orderNumber);
    }
    showToast(`تم نسخ رقم الطلب: ${lastCreatedOrder.orderNumber}`);
  };

  return (
    <div className="min-h-screen bg-slate-50 text-right p-4 pb-20 flex flex-col justify-between max-w-md mx-auto">
      <div className="pt-6 space-y-5">
        {/* Animated Celebration Icon */}
        <div className="text-center">
          <div className="w-20 h-20 rounded-full bg-emerald-100 text-emerald-600 flex items-center justify-center mx-auto mb-3 shadow-lg shadow-emerald-500/10">
            <CheckCircle size={44} strokeWidth={2.4} />
          </div>

          <span className="text-xs font-bold text-amber-600 font-cairo bg-amber-50 border border-amber-200 px-3 py-1 rounded-full">
            عملية شراء ناجحة ومضمونة
          </span>

          <h1 className="text-xl font-black font-cairo text-slate-900 mt-2">
            تم استلام وتأكيد طلبك بنجاح! 🎉
          </h1>
          <p className="text-xs text-slate-500 max-w-xs mx-auto mt-1 leading-relaxed">
            سيقوم وكيل برهان في الصين بالبدء بإجراءات الشراء من المتاجر الصينية المحددة فوراً.
          </p>
        </div>

        {/* Order Info Card */}
        <div className="bg-white rounded-3xl p-5 border border-slate-200/80 shadow-xs space-y-3.5 text-xs">
          {/* Order Number Row */}
          <div className="flex items-center justify-between pb-3 border-b border-slate-100">
            <div>
              <span className="text-slate-400 text-[11px] block">رقم طلب برهان:</span>
              <span className="font-mono font-black text-sm text-[#0B2038] tracking-wider">
                {lastCreatedOrder.orderNumber}
              </span>
            </div>

            <button
              onClick={handleCopyOrderNumber}
              className="flex items-center gap-1 text-[11px] font-bold text-[#0B2038] bg-slate-100 hover:bg-slate-200 px-2.5 py-1.5 rounded-xl transition-colors active-press"
            >
              <Copy size={13} />
              <span>نسخ الرقم</span>
            </button>
          </div>

          {/* Details Rows */}
          <div className="space-y-2">
            <div className="flex items-center justify-between text-slate-600">
              <span className="flex items-center gap-1 text-slate-400">
                <Truck size={14} />
                <span>طريقة الشحن:</span>
              </span>
              <span className="font-bold text-slate-900">
                {lastCreatedOrder.shippingMethod.nameAr}
              </span>
            </div>

            <div className="flex items-center justify-between text-slate-600">
              <span className="flex items-center gap-1 text-slate-400">
                <MapPin size={14} />
                <span>الوجهة:</span>
              </span>
              <span className="font-bold text-slate-900">
                {lastCreatedOrder.address.city} - {lastCreatedOrder.address.district}
              </span>
            </div>

            <div className="flex items-center justify-between text-slate-600">
              <span className="flex items-center gap-1 text-slate-400">
                <Clock size={14} />
                <span>المدة المتوقعة:</span>
              </span>
              <span className="font-bold text-amber-600">
                {lastCreatedOrder.shippingMethod.estimatedDays}
              </span>
            </div>

            <div className="pt-2 border-t border-slate-100 flex items-center justify-between text-slate-900 font-bold">
              <span>إجمالي الفاتورة:</span>
              <span className="text-base font-black font-cairo text-[#0B2038]">
                {lastCreatedOrder.breakdown.grandTotal.toLocaleString('en-US')}{' '}
                {formatPrice(0).symbol}
              </span>
            </div>
          </div>
        </div>

        {/* Step Guide */}
        <div className="bg-amber-50/80 border border-amber-200/80 rounded-2xl p-4 text-xs text-amber-900 space-y-1.5">
          <div className="flex items-center gap-1.5 font-bold font-cairo">
            <ShieldCheck size={16} className="text-amber-600" />
            <span>ما هي الخطوة القادمة؟</span>
          </div>
          <p className="text-[11px] leading-relaxed text-amber-800">
            يمكنك متابعة حالة الشحنة في أي وقت عبر تبويب «طلباتي». سنرسل لك إشعاراً مصوراً فور وصول المنتجات إلى مستودع قوانغتشو وفحصها.
          </p>
        </div>
      </div>

      {/* Action Buttons */}
      <div className="space-y-2.5 pt-6">
        <button
          onClick={() => openOrderDetails(lastCreatedOrder.id)}
          className="w-full h-12 rounded-xl bg-[#0B2038] hover:bg-slate-800 text-white font-bold font-cairo text-xs flex items-center justify-center gap-2 shadow-md shadow-[#0B2038]/20 active-press transition-all cursor-pointer"
        >
          <PackageCheck size={17} />
          <span>متابعة مسار وتتبع الطلب</span>
        </button>

        <button
          onClick={() => setActiveTab('home')}
          className="w-full h-12 rounded-xl bg-white hover:bg-slate-100 text-slate-700 font-bold font-cairo text-xs flex items-center justify-center gap-2 border border-slate-200 active-press transition-all cursor-pointer"
        >
          <Home size={17} />
          <span>العودة للصفحة الرئيسية</span>
        </button>
      </div>
    </div>
  );
};
