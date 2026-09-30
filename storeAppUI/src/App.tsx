import React from 'react';
import { AppProvider, useApp } from './context/AppContext';
import { MobileFrameWrapper } from './components/MobileFrameWrapper';
import { TopHeader } from './components/TopHeader';
import { BottomNav } from './components/BottomNav';

// Screens
import { SplashScreen } from './screens/SplashScreen';
import { AuthScreen } from './screens/AuthScreen';
import { HomeScreen } from './screens/HomeScreen';
import { SearchScreen } from './screens/SearchScreen';
import { CartScreen } from './screens/CartScreen';
import { OrdersScreen } from './screens/OrdersScreen';
import { ProfileScreen } from './screens/ProfileScreen';
import { ProductDetailsScreen } from './screens/ProductDetailsScreen';
import { CheckoutScreen } from './screens/CheckoutScreen';
import { OrderSuccessScreen } from './screens/OrderSuccessScreen';
import { OrderDetailsScreen } from './screens/OrderDetailsScreen';
import { FavoritesScreen } from './screens/FavoritesScreen';
import { NotificationsScreen } from './screens/NotificationsScreen';
import { HowItWorksScreen } from './screens/HowItWorksScreen';
import { StoreProductsScreen } from './screens/StoreProductsScreen';

const MainAppContent: React.FC = () => {
  const { currentView, activeTab, toastMessage } = useApp();

  // Route to the appropriate view
  const renderCurrentView = () => {
    switch (currentView) {
      case 'splash':
        return <SplashScreen />;

      case 'auth':
        return <AuthScreen />;

      case 'product_details':
        return <ProductDetailsScreen />;

      case 'store_view':
        return <StoreProductsScreen />;

      case 'checkout':
        return <CheckoutScreen />;

      case 'order_success':
        return <OrderSuccessScreen />;

      case 'order_details':
        return <OrderDetailsScreen />;

      case 'favorites':
        return <FavoritesScreen />;

      case 'notifications':
        return <NotificationsScreen />;

      case 'how_it_works':
        return <HowItWorksScreen />;

      case 'main':
      default:
        return (
          <div className="flex-1 flex flex-col min-h-full">
            <TopHeader />
            <main className="flex-1">
              {activeTab === 'home' && <HomeScreen />}
              {activeTab === 'search' && <SearchScreen />}
              {activeTab === 'cart' && <CartScreen />}
              {activeTab === 'orders' && <OrdersScreen />}
              {activeTab === 'profile' && <ProfileScreen />}
            </main>
            <BottomNav />
          </div>
        );
    }
  };

  return (
    <div className="relative flex-1 flex flex-col w-full h-full min-h-screen bg-slate-50 text-slate-900 font-tajawal select-none">
      {renderCurrentView()}

      {/* Global Interactive Toast Notification */}
      {toastMessage && (
        <div className="fixed top-14 left-1/2 -translate-x-1/2 z-50 max-w-[90%] bg-slate-900/95 backdrop-blur-md text-white px-4 py-2.5 rounded-2xl shadow-xl border border-slate-700/60 text-xs font-semibold font-cairo flex items-center gap-2 animate-bounce">
          <span className="w-2 h-2 rounded-full bg-amber-400" />
          <span>{toastMessage}</span>
        </div>
      )}
    </div>
  );
};

export default function App() {
  return (
    <AppProvider>
      <MobileFrameWrapper>
        <MainAppContent />
      </MobileFrameWrapper>
    </AppProvider>
  );
}
