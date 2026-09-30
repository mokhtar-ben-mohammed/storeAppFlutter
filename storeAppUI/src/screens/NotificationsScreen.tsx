import React, { useState } from 'react';
import { Bell, CheckCheck, Truck, Sparkles, Package, Info, ChevronLeft } from 'lucide-react';
import { useApp } from '../context/AppContext';
import { TopHeader } from '../components/TopHeader';
import { NotificationItem } from '../types';

export const NotificationsScreen: React.FC = () => {
  const {
    notifications,
    markNotificationAsRead,
    markAllNotificationsAsRead,
    openOrderDetails,
  } = useApp();

  const [activeFilter, setActiveFilter] = useState<'all' | 'unread'>('all');

  const filteredNotifs = notifications.filter((n) => {
    if (activeFilter === 'unread') return !n.read;
    return true;
  });

  const getNotifIcon = (type: NotificationItem['type']) => {
    switch (type) {
      case 'shipping':
        return (
          <div className="w-10 h-10 rounded-2xl bg-blue-50 text-blue-600 flex items-center justify-center shrink-0">
            <Truck size={18} />
          </div>
        );
      case 'order':
        return (
          <div className="w-10 h-10 rounded-2xl bg-amber-50 text-amber-600 flex items-center justify-center shrink-0">
            <Package size={18} />
          </div>
        );
      case 'promo':
        return (
          <div className="w-10 h-10 rounded-2xl bg-emerald-50 text-emerald-600 flex items-center justify-center shrink-0">
            <Sparkles size={18} />
          </div>
        );
      default:
        return (
          <div className="w-10 h-10 rounded-2xl bg-slate-100 text-slate-600 flex items-center justify-center shrink-0">
            <Info size={18} />
          </div>
        );
    }
  };

  const handleNotificationClick = (item: NotificationItem) => {
    markNotificationAsRead(item.id);
    if (item.orderId) {
      openOrderDetails(item.orderId);
    }
  };

  return (
    <div className="min-h-screen bg-slate-50 text-right pb-28">
      <TopHeader
        title="مركز الإشعارات"
        showBack={true}
        rightAction={
          <button
            onClick={markAllNotificationsAsRead}
            className="flex items-center gap-1 text-[11px] font-bold text-[#0B2038] hover:text-amber-600 px-2 py-1 bg-slate-100 rounded-lg active-press"
          >
            <CheckCheck size={14} />
            <span>تعيين الكل كمقروء</span>
          </button>
        }
      />

      <div className="max-w-md mx-auto px-4 pt-3 space-y-3">
        {/* Filter tabs */}
        <div className="flex bg-white p-1 rounded-2xl border border-slate-200/80">
          <button
            onClick={() => setActiveFilter('all')}
            className={`flex-1 py-1.5 rounded-xl text-xs font-bold font-cairo transition-all ${
              activeFilter === 'all'
                ? 'bg-[#0B2038] text-white shadow-xs'
                : 'text-slate-500 hover:text-slate-900'
            }`}
          >
            جميع الإشعارات ({notifications.length})
          </button>
          <button
            onClick={() => setActiveFilter('unread')}
            className={`flex-1 py-1.5 rounded-xl text-xs font-bold font-cairo transition-all ${
              activeFilter === 'unread'
                ? 'bg-[#0B2038] text-white shadow-xs'
                : 'text-slate-500 hover:text-slate-900'
            }`}
          >
            غير المقروءة ({notifications.filter((n) => !n.read).length})
          </button>
        </div>

        {/* Notifications List */}
        {filteredNotifs.length > 0 ? (
          <div className="space-y-2.5">
            {filteredNotifs.map((item) => (
              <div
                key={item.id}
                onClick={() => handleNotificationClick(item)}
                className={`bg-white rounded-2xl p-3.5 border transition-all cursor-pointer active-press flex items-start gap-3 ${
                  !item.read
                    ? 'border-amber-300 bg-amber-50/20 ring-1 ring-amber-300/50 shadow-xs'
                    : 'border-slate-200/80 hover:border-slate-300'
                }`}
              >
                {getNotifIcon(item.type)}

                <div className="flex-1 min-w-0">
                  <div className="flex items-center justify-between">
                    <h4 className="text-xs font-bold font-cairo text-slate-900 truncate">
                      {item.title}
                    </h4>
                    <span className="text-[10px] text-slate-400 font-mono shrink-0">
                      {item.timestamp}
                    </span>
                  </div>

                  <p className="text-[11px] text-slate-600 mt-1 leading-relaxed">
                    {item.body}
                  </p>

                  {item.orderId && (
                    <div className="mt-2 flex items-center gap-1 text-[10px] font-bold text-amber-600">
                      <span>عرض تفاصيل ومسار الشحنة</span>
                      <ChevronLeft size={13} />
                    </div>
                  )}
                </div>

                {!item.read && (
                  <span className="w-2 h-2 rounded-full bg-amber-500 shrink-0 mt-1.5" />
                )}
              </div>
            ))}
          </div>
        ) : (
          <div className="bg-white rounded-3xl p-8 border border-slate-200/80 text-center space-y-3 my-8">
            <div className="w-14 h-14 rounded-2xl bg-slate-100 text-slate-400 flex items-center justify-center mx-auto">
              <Bell size={28} />
            </div>
            <h3 className="text-sm font-bold font-cairo text-slate-900">
              لا توجد إشعارات جديدة
            </h3>
            <p className="text-xs text-slate-500 max-w-xs mx-auto leading-relaxed">
              ستصلك هنا إشعارات بكل خطوة: عند الشراء من الصين، وتصوير الفحص في قوانغتشو، وخروج الشحنة للتوصيل.
            </p>
          </div>
        )}
      </div>
    </div>
  );
};
