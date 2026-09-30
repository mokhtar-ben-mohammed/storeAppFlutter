import React from 'react';
import { Home, Search, ShoppingBag, PackageCheck, User } from 'lucide-react';
import { useApp, ActiveTab } from '../context/AppContext';

export const BottomNav: React.FC = () => {
  const { activeTab, setActiveTab, cart, orders, currentView } = useApp();

  // Hide bottom nav in checkout, splash, or order success to maximize focus
  if (['checkout', 'order_success', 'splash', 'auth'].includes(currentView)) {
    return null;
  }

  const cartTotalCount = cart.reduce((acc, item) => acc + item.quantity, 0);
  const activeOrdersCount = orders.filter(
    (o) => !['delivered', 'cancelled'].includes(o.status)
  ).length;

  const navItems: { id: ActiveTab; label: string; icon: React.ElementType; badge?: number }[] = [
    { id: 'home', label: 'الرئيسية', icon: Home },
    { id: 'search', label: 'البحث والرابط', icon: Search },
    { id: 'cart', label: 'السلة', icon: ShoppingBag, badge: cartTotalCount },
    { id: 'orders', label: 'طلباتي', icon: PackageCheck, badge: activeOrdersCount > 0 ? activeOrdersCount : undefined },
    { id: 'profile', label: 'حسابي', icon: User },
  ];

  return (
    <nav
      className="sticky bottom-0 z-40 w-full bg-white/80 backdrop-blur-md border-t border-slate-200/60 shadow-[0_-4px_16px_rgba(0,0,0,0.03)]"
      aria-label="التنقل الرئيسي"
    >
      <div className="grid grid-cols-5 items-center h-15 max-w-md mx-auto px-1">
        {navItems.map((item) => {
          const isActive = activeTab === item.id && currentView === 'main';
          const Icon = item.icon;

          return (
            <button
              key={item.id}
              onClick={() => setActiveTab(item.id)}
              className={`relative flex flex-col items-center justify-center py-1 transition-all duration-200 active-press min-h-[46px] ${
                isActive ? 'text-[#0B2038]' : 'text-slate-500 hover:text-slate-800'
              }`}
            >
              <div className="relative">
                <Icon
                  size={20}
                  strokeWidth={isActive ? 2.4 : 1.8}
                  className={`transition-transform duration-200 ${
                    isActive ? 'scale-105 text-[#0B2038]' : ''
                  }`}
                />

                {item.badge !== undefined && item.badge > 0 && (
                  <span
                    className={`absolute -top-1.5 -end-2.5 min-w-[16px] h-[16px] px-1 rounded-full text-[9px] font-bold flex items-center justify-center text-white ${
                      item.id === 'cart' ? 'bg-amber-500' : 'bg-[#0B2038]'
                    }`}
                  >
                    {item.badge > 99 ? '99+' : item.badge}
                  </span>
                )}
              </div>

              <span
                className={`text-[11px] mt-1 tracking-tight truncate ${
                  isActive ? 'font-bold text-[#0B2038]' : 'font-medium text-slate-500'
                }`}
              >
                {item.label}
              </span>

              {isActive && (
                <span className="absolute bottom-1 w-3.5 h-0.5 rounded-full bg-amber-500" />
              )}
            </button>
          );
        })}
      </div>
    </nav>
  );
};
