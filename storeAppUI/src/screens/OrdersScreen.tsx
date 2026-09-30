import React, { useState } from 'react';
import {
  Package,
  Clock,
  CheckCircle2,
  Plane,
  Truck,
  ChevronLeft,
  ShoppingBag,
  AlertCircle,
  Sparkles,
} from 'lucide-react';
import { useApp } from '../context/AppContext';
import { OrderStatus } from '../types';
import { StoreBadge } from '../components/StoreBadge';

export const OrdersScreen: React.FC = () => {
  const { orders, openOrderDetails, setActiveTab, formatPrice } = useApp();
  const [selectedStatusTab, setSelectedStatusTab] = useState<string>('all');

  const statusTabs: { id: string; label: string }[] = [
    { id: 'all', label: 'الكل' },
    { id: 'processing', label: 'قيد المعالجة' },
    { id: 'purchased', label: 'تم الشراء' },
    { id: 'shipped_intl', label: 'قيد الشحن' },
    { id: 'delivered', label: 'تم التسليم' },
  ];

  const filteredOrders = orders.filter((order) => {
    if (selectedStatusTab === 'all') return true;
    if (selectedStatusTab === 'processing') {
      return ['pending_payment', 'processing'].includes(order.status);
    }
    if (selectedStatusTab === 'purchased') {
      return ['purchased', 'received_china'].includes(order.status);
    }
    if (selectedStatusTab === 'shipped_intl') {
      return ['shipped_intl', 'customs_local', 'out_for_delivery'].includes(order.status);
    }
    if (selectedStatusTab === 'delivered') {
      return order.status === 'delivered';
    }
    return true;
  });

  const getStatusBadge = (status: OrderStatus) => {
    switch (status) {
      case 'pending_payment':
      case 'processing':
        return (
          <span className="inline-flex items-center gap-1 text-[11px] font-bold text-amber-700 bg-amber-50 border border-amber-200 px-2 py-0.5 rounded-lg">
            <Clock size={12} />
            قيد المراجعة والشراء
          </span>
        );
      case 'purchased':
        return (
          <span className="inline-flex items-center gap-1 text-[11px] font-bold text-blue-700 bg-blue-50 border border-blue-200 px-2 py-0.5 rounded-lg">
            <CheckCircle2 size={12} />
            تم الشراء من المصنع
          </span>
        );
      case 'received_china':
        return (
          <span className="inline-flex items-center gap-1 text-[11px] font-bold text-purple-700 bg-purple-50 border border-purple-200 px-2 py-0.5 rounded-lg">
            <Package size={12} />
            تم الفحص بمستودع الصين
          </span>
        );
      case 'shipped_intl':
        return (
          <span className="inline-flex items-center gap-1 text-[11px] font-bold text-sky-700 bg-sky-50 border border-sky-200 px-2 py-0.5 rounded-lg">
            <Plane size={12} />
            غادرت جوياً إلى اليمن
          </span>
        );
      case 'customs_local':
      case 'out_for_delivery':
        return (
          <span className="inline-flex items-center gap-1 text-[11px] font-bold text-indigo-700 bg-indigo-50 border border-indigo-200 px-2 py-0.5 rounded-lg">
            <Truck size={12} />
            في التوصيل المحلي
          </span>
        );
      case 'delivered':
        return (
          <span className="inline-flex items-center gap-1 text-[11px] font-bold text-emerald-700 bg-emerald-50 border border-emerald-200 px-2 py-0.5 rounded-lg">
            <CheckCircle2 size={12} />
            تم التسليم للعميل
          </span>
        );
      default:
        return (
          <span className="inline-flex items-center gap-1 text-[11px] font-bold text-slate-700 bg-slate-100 px-2 py-0.5 rounded-lg">
            ملغي
          </span>
        );
    }
  };

  return (
    <div className="pb-36 text-right max-w-md mx-auto px-4 pt-4 space-y-5 min-h-[85vh]">
      {/* Page Title */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-base font-black font-cairo text-slate-900">
            سجل طلباتي وتتبع الشحنات
          </h1>
          <p className="text-[11px] text-slate-500">
            تابع مسار مشترياتك خطوة بخطوة من مستودعات الصين حتى اليمن
          </p>
        </div>
      </div>

      {/* Status Filter Tabs */}
      <div className="flex items-center gap-1.5 overflow-x-auto no-scrollbar pb-1">
        {statusTabs.map((tab) => {
          const isActive = selectedStatusTab === tab.id;
          return (
            <button
              key={tab.id}
              onClick={() => setSelectedStatusTab(tab.id)}
              className={`px-3 py-1.5 rounded-xl text-xs font-cairo font-bold whitespace-nowrap transition-all active-press ${
                isActive
                  ? 'bg-[#0B2038] text-white shadow-xs'
                  : 'bg-white text-slate-600 border border-slate-200/80 hover:bg-slate-50'
              }`}
            >
              {tab.label}
            </button>
          );
        })}
      </div>

      {/* Orders List */}
      {filteredOrders.length > 0 ? (
        <div className="space-y-3">
          {filteredOrders.map((order) => {
            const formattedDate = new Date(order.createdAt).toLocaleDateString('ar-YE', {
              month: 'short',
              day: 'numeric',
            });

            return (
              <div
                key={order.id}
                onClick={() => openOrderDetails(order.id)}
                className="bg-white rounded-3xl p-4 border border-slate-200/80 shadow-xs hover:border-amber-300 transition-all cursor-pointer active-press space-y-3"
              >
                {/* Header: Order Number & Status */}
                <div className="flex items-center justify-between pb-2.5 border-b border-slate-100">
                  <div>
                    <span className="font-mono font-bold text-xs text-[#0B2038] block tracking-wide">
                      {order.orderNumber}
                    </span>
                    <span className="text-[10px] text-slate-400">
                      بتاريخ: {formattedDate}
                    </span>
                  </div>

                  {getStatusBadge(order.status)}
                </div>

                {/* Products Thumbnails Preview */}
                <div className="flex items-center gap-2 overflow-x-auto no-scrollbar py-1">
                  {order.items.map((item, idx) => (
                    <div
                      key={idx}
                      className="relative w-14 h-14 rounded-xl overflow-hidden bg-slate-100 border border-slate-100 shrink-0"
                    >
                      <img
                        src={item.product.images[0]}
                        alt=""
                        className="w-full h-full object-cover"
                      />
                      <div className="absolute top-0.5 start-0.5">
                        <StoreBadge store={item.product.store} size="sm" showLabel={false} />
                      </div>
                    </div>
                  ))}

                  {order.items.length > 1 && (
                    <div className="text-[11px] text-slate-500 font-semibold px-2">
                      +{order.items.length - 1} منتج إضافي
                    </div>
                  )}
                </div>

                {/* Bottom Row: Total & Action */}
                <div className="flex items-center justify-between pt-2.5 border-t border-slate-100">
                  <div>
                    <span className="text-[10px] text-slate-400 block">الإجمالي:</span>
                    <span className="text-sm font-black font-cairo text-[#0B2038]">
                      {order.breakdown.grandTotal.toLocaleString('en-US')}{' '}
                      {formatPrice(0).symbol}
                    </span>
                  </div>

                  <div className="flex items-center gap-1 text-xs font-bold font-cairo text-amber-600 hover:text-amber-700">
                    <span>عرض التفاصيل والتتبع</span>
                    <ChevronLeft size={15} />
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      ) : (
        <div className="bg-white rounded-3xl p-8 border border-slate-200/80 text-center space-y-3 my-6">
          <div className="w-16 h-16 rounded-2xl bg-slate-100 text-slate-400 flex items-center justify-center mx-auto">
            <Package size={32} />
          </div>
          <h3 className="text-sm font-bold font-cairo text-slate-900">
            لا توجد طلبات في هذا القسم
          </h3>
          <p className="text-xs text-slate-500 max-w-xs mx-auto leading-relaxed">
            عندما تقوم بإنشاء طلبات شراء جديدة من 1688 أو Taobao، ستظهر تفاصيلها وحالات شحنها هنا فوراً.
          </p>
          <button
            onClick={() => setActiveTab('home')}
            className="bg-[#0B2038] hover:bg-slate-800 text-white text-xs font-bold font-cairo px-5 py-2.5 rounded-xl active-press mt-2"
          >
            تصفح المنتجات وأنشئ أول طلب
          </button>
        </div>
      )}
    </div>
  );
};
