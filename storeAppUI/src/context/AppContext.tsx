import React, { createContext, useContext, useState, useEffect } from 'react';
import {
  Product,
  CartItem,
  Order,
  User,
  Address,
  ShippingMethod,
  PaymentMethod,
  CurrencyType,
  NotificationItem,
  StoreType,
  OrderStatus,
} from '../types';
import {
  PRODUCTS,
  INITIAL_ADDRESSES,
  INITIAL_ORDERS,
  INITIAL_NOTIFICATIONS,
  EXCHANGE_RATES,
  CURRENCY_SYMBOLS,
  SHIPPING_METHODS,
  PAYMENT_METHODS,
} from '../data/mockData';

export type ActiveTab = 'home' | 'search' | 'cart' | 'orders' | 'profile';
export type ActiveView =
  | 'splash'
  | 'auth'
  | 'main'
  | 'product_details'
  | 'checkout'
  | 'order_success'
  | 'order_details'
  | 'favorites'
  | 'notifications'
  | 'how_it_works'
  | 'address_manager'
  | 'store_view';

interface AppContextType {
  // Navigation & Views
  activeTab: ActiveTab;
  setActiveTab: (tab: ActiveTab) => void;
  currentView: ActiveView;
  setCurrentView: (view: ActiveView) => void;
  viewHistory: ActiveView[];
  navigateBack: () => void;
  navigateToView: (view: ActiveView) => void;

  // Mobile Frame preview toggle
  isMobileDeviceView: boolean;
  setIsMobileDeviceView: (val: boolean) => void;

  // User & Auth
  user: User | null;
  isAuthenticated: boolean;
  loginUser: (phone: string, countryCode: string, name?: string, city?: string) => void;
  logoutUser: () => void;
  updateUserProfile: (profile: Partial<User>) => void;

  // Currency
  currency: CurrencyType;
  setCurrency: (c: CurrencyType) => void;
  formatPrice: (priceCny: number) => { formatted: string; amount: number; symbol: string; text: string };
  convertPrice: (priceCny: number) => number;

  // Catalog & Search
  products: Product[];
  selectedProduct: Product | null;
  openProductDetails: (product: Product) => void;
  selectedStoreForView: StoreType | null;
  openStoreView: (store: StoreType) => void;
  searchQuery: string;
  setSearchQuery: (query: string) => void;
  selectedStoreFilter: StoreType | 'all';
  setSelectedStoreFilter: (store: StoreType | 'all') => void;
  parseExternalUrl: (url: string) => { recognized: boolean; store?: StoreType; productId?: string; message?: string };

  // Cart & Partial Selection
  cart: CartItem[];
  addToCart: (product: Product, variantId?: string, quantity?: number) => void;
  toggleCartItemSelection: (cartItemId: string) => void;
  selectAllCartItems: () => void;
  deselectAllCartItems: () => void;
  updateCartQuantity: (cartItemId: string, delta: number) => void;
  removeCartItem: (cartItemId: string) => void;
  removeSelectedCartItems: () => void;
  moveToFavoritesFromCart: (cartItemId: string) => void;
  selectedCartItems: CartItem[];
  selectedCartTotalCny: number;

  // Favorites
  favoriteProductIds: string[];
  toggleFavorite: (productId: string) => void;
  isFavorite: (productId: string) => boolean;

  // Checkout & Orders
  addresses: Address[];
  addAddress: (addr: Omit<Address, 'id'>) => void;
  selectedAddress: Address | null;
  setSelectedAddress: (addr: Address) => void;
  selectedShipping: ShippingMethod;
  setSelectedShipping: (ship: ShippingMethod) => void;
  selectedPayment: PaymentMethod;
  setSelectedPayment: (pay: PaymentMethod) => void;
  proceedToCheckout: () => void;
  confirmOrder: () => Order;
  lastCreatedOrder: Order | null;
  orders: Order[];
  selectedOrderId: string | null;
  openOrderDetails: (orderId: string) => void;
  advanceOrderStatus: (orderId: string) => void;

  // Notifications
  notifications: NotificationItem[];
  unreadNotificationsCount: number;
  markNotificationAsRead: (id: string) => void;
  markAllNotificationsAsRead: () => void;

  // Quick Toast
  toastMessage: string | null;
  showToast: (msg: string) => void;
}

const AppContext = createContext<AppContextType | undefined>(undefined);

export const AppProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  // Navigation & view states
  const [activeTab, setActiveTabState] = useState<ActiveTab>('home');
  const [currentView, setCurrentViewState] = useState<ActiveView>('splash');
  const [viewHistory, setViewHistory] = useState<ActiveView[]>([]);
  const [isMobileDeviceView, setIsMobileDeviceView] = useState<boolean>(true);

  // User state
  const [user, setUser] = useState<User | null>(() => {
    const saved = localStorage.getItem('burhan_user');
    if (saved) {
      try {
        return JSON.parse(saved);
      } catch (e) {
        return null;
      }
    }
    return {
      id: 'usr-1',
      name: 'مختار غالب',
      phone: '771234567',
      countryCode: '+967',
      country: 'اليمن',
      city: 'صنعاء',
      gender: 'male',
      walletBalanceYer: 32500,
      walletBalanceUsd: 65,
      isLoggedIn: true,
    };
  });

  const isAuthenticated = !!user?.isLoggedIn;

  // Currency
  const [currency, setCurrencyState] = useState<CurrencyType>(() => {
    return (localStorage.getItem('burhan_currency') as CurrencyType) || 'YER';
  });

  // Products & Selected Product
  const [products] = useState<Product[]>(PRODUCTS);
  const [selectedProduct, setSelectedProduct] = useState<Product | null>(PRODUCTS[0]);
  const [selectedStoreForView, setSelectedStoreForView] = useState<StoreType | null>(null);
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [selectedStoreFilter, setSelectedStoreFilter] = useState<StoreType | 'all'>('all');

  const openStoreView = (store: StoreType) => {
    setSelectedStoreForView(store);
    setSelectedStoreFilter(store);
    navigateToView('store_view');
  };

  // Cart: initial state with 2 items to let user experience partial selection immediately
  const [cart, setCart] = useState<CartItem[]>(() => {
    const saved = localStorage.getItem('burhan_cart');
    if (saved) {
      try {
        return JSON.parse(saved);
      } catch (e) {}
    }
    return [
      {
        id: 'cart-1',
        productId: PRODUCTS[0].id,
        product: PRODUCTS[0],
        selectedVariant: PRODUCTS[0].variants[0],
        quantity: 1,
        isSelected: true,
        addedAt: new Date().toISOString(),
      },
      {
        id: 'cart-2',
        productId: PRODUCTS[1].id,
        product: PRODUCTS[1],
        selectedVariant: PRODUCTS[1].variants[0],
        quantity: 1,
        isSelected: true,
        addedAt: new Date().toISOString(),
      },
      {
        id: 'cart-3',
        productId: PRODUCTS[2].id,
        product: PRODUCTS[2],
        selectedVariant: PRODUCTS[2].variants[0],
        quantity: 2,
        isSelected: false, // Notice: unselected by default to showcase partial cart!
        addedAt: new Date().toISOString(),
      },
    ];
  });

  // Favorites
  const [favoriteProductIds, setFavoriteProductIds] = useState<string[]>(() => {
    return ['prod-1', 'prod-4'];
  });

  // Checkout states
  const [addresses, setAddresses] = useState<Address[]>(INITIAL_ADDRESSES);
  const [selectedAddress, setSelectedAddress] = useState<Address | null>(INITIAL_ADDRESSES[0]);
  const [selectedShipping, setSelectedShipping] = useState<ShippingMethod>(SHIPPING_METHODS[0]);
  const [selectedPayment, setSelectedPayment] = useState<PaymentMethod>(PAYMENT_METHODS[0]);
  const [lastCreatedOrder, setLastCreatedOrder] = useState<Order | null>(null);

  // Orders
  const [orders, setOrders] = useState<Order[]>(INITIAL_ORDERS);
  const [selectedOrderId, setSelectedOrderId] = useState<string | null>('ord-8921');

  // Notifications
  const [notifications, setNotifications] = useState<NotificationItem[]>(INITIAL_NOTIFICATIONS);

  // Toast
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => {
      setToastMessage((current) => (current === msg ? null : current));
    }, 3000);
  };

  // Sync state to local storage
  useEffect(() => {
    if (user) {
      localStorage.setItem('burhan_user', JSON.stringify(user));
    }
  }, [user]);

  useEffect(() => {
    localStorage.setItem('burhan_cart', JSON.stringify(cart));
  }, [cart]);

  useEffect(() => {
    localStorage.setItem('burhan_currency', currency);
  }, [currency]);

  // Navigation helpers
  const setActiveTab = (tab: ActiveTab) => {
    setActiveTabState(tab);
    setCurrentViewState('main');
  };

  const navigateToView = (view: ActiveView) => {
    setViewHistory((prev) => [...prev, currentView]);
    setCurrentViewState(view);
  };

  const navigateBack = () => {
    if (viewHistory.length > 0) {
      const prev = viewHistory[viewHistory.length - 1];
      setViewHistory((prevArr) => prevArr.slice(0, -1));
      setCurrentViewState(prev);
    } else {
      setCurrentViewState('main');
    }
  };

  // Currency helpers
  const convertPrice = (priceCny: number): number => {
    const rate = EXCHANGE_RATES[currency] || 1;
    const converted = priceCny * rate;
    return currency === 'YER' ? Math.round(converted) : Number(converted.toFixed(2));
  };

  const formatPrice = (priceCny: number) => {
    const amount = convertPrice(priceCny);
    const symbol = CURRENCY_SYMBOLS[currency];
    const formatted = amount.toLocaleString('en-US');
    return {
      formatted: `${formatted} ${symbol}`,
      amount,
      symbol,
      text: `${formatted} ${symbol}`,
    };
  };

  const setCurrency = (c: CurrencyType) => {
    setCurrencyState(c);
    showToast(`تم تغيير العملة المعروضة إلى ${CURRENCY_SYMBOLS[c]}`);
  };

  // User auth actions
  const loginUser = (phone: string, countryCode: string, name?: string, city?: string) => {
    const newUser: User = {
      id: `usr-${Date.now()}`,
      name: name || 'عميل برهان',
      phone,
      countryCode,
      country: 'اليمن',
      city: city || 'صنعاء',
      gender: 'male',
      walletBalanceYer: 35000,
      walletBalanceUsd: 70,
      isLoggedIn: true,
    };
    setUser(newUser);
    setCurrentViewState('main');
    setActiveTabState('home');
    showToast(`أهلاً بك يا ${newUser.name} في منصة برهان!`);
  };

  const logoutUser = () => {
    if (user) {
      setUser({ ...user, isLoggedIn: false });
    }
    setCurrentViewState('auth');
    showToast('تم تسجيل الخروج بنجاح');
  };

  const updateUserProfile = (profile: Partial<User>) => {
    if (user) {
      setUser({ ...user, ...profile });
      showToast('تم تحديث البيانات بنجاح');
    }
  };

  // Catalog actions
  const openProductDetails = (product: Product) => {
    setSelectedProduct(product);
    navigateToView('product_details');
  };

  const parseExternalUrl = (url: string) => {
    const cleanUrl = url.trim().toLowerCase();
    if (cleanUrl.includes('1688.com')) {
      return { recognized: true, store: '1688' as StoreType, message: 'رابط متجر 1688 لمصانع الجملة' };
    }
    if (cleanUrl.includes('taobao.com') || cleanUrl.includes('tmall.com')) {
      return { recognized: true, store: 'taobao' as StoreType, message: 'رابط متجر تاوباو الصيني' };
    }
    if (cleanUrl.includes('goofish.com') || cleanUrl.includes('2.taobao.com') || cleanUrl.includes('xianyu')) {
      return { recognized: true, store: 'goofish' as StoreType, message: 'رابط منصة جوفيش للمقتنيات والمستعمل' };
    }
    if (cleanUrl.includes('aliexpress.com')) {
      return { recognized: true, store: 'aliexpress' as StoreType, message: 'رابط علي إكسبريس الدولي' };
    }
    return { recognized: false, message: 'يرجى إدخال رابط صحيح من 1688 أو Taobao أو Goofish أو AliExpress' };
  };

  // Cart operations
  const addToCart = (product: Product, variantId?: string, quantity: number = 1) => {
    const variant = variantId
      ? product.variants.find((v) => v.id === variantId) || product.variants[0]
      : product.variants[0];

    setCart((prev) => {
      const existingIndex = prev.findIndex(
        (item) => item.productId === product.id && item.selectedVariant.id === variant.id
      );

      if (existingIndex > -1) {
        const next = [...prev];
        next[existingIndex] = {
          ...next[existingIndex],
          quantity: next[existingIndex].quantity + quantity,
          isSelected: true,
        };
        return next;
      } else {
        const newItem: CartItem = {
          id: `cart-${Date.now()}-${Math.random().toString(36).substr(2, 4)}`,
          productId: product.id,
          product,
          selectedVariant: variant,
          quantity,
          isSelected: true, // Selected by default on addition
          addedAt: new Date().toISOString(),
        };
        return [newItem, ...prev];
      }
    });

    showToast(`تمت إضافة "${product.title.slice(0, 26)}..." إلى السلة`);
  };

  const toggleCartItemSelection = (cartItemId: string) => {
    setCart((prev) =>
      prev.map((item) => (item.id === cartItemId ? { ...item, isSelected: !item.isSelected } : item))
    );
  };

  const selectAllCartItems = () => {
    setCart((prev) => prev.map((item) => ({ ...item, isSelected: true })));
  };

  const deselectAllCartItems = () => {
    setCart((prev) => prev.map((item) => ({ ...item, isSelected: false })));
  };

  const updateCartQuantity = (cartItemId: string, delta: number) => {
    setCart((prev) =>
      prev
        .map((item) => {
          if (item.id === cartItemId) {
            const newQty = item.quantity + delta;
            return newQty > 0 ? { ...item, quantity: newQty } : null;
          }
          return item;
        })
        .filter(Boolean) as CartItem[]
    );
  };

  const removeCartItem = (cartItemId: string) => {
    setCart((prev) => prev.filter((item) => item.id !== cartItemId));
    showToast('تم حذف المنتج من السلة');
  };

  const removeSelectedCartItems = () => {
    const count = cart.filter((i) => i.isSelected).length;
    if (count === 0) return;
    setCart((prev) => prev.filter((item) => !item.isSelected));
    showToast(`تم حذف ${count} منتجات محددة من السلة`);
  };

  const moveToFavoritesFromCart = (cartItemId: string) => {
    const item = cart.find((i) => i.id === cartItemId);
    if (item) {
      if (!favoriteProductIds.includes(item.productId)) {
        setFavoriteProductIds((prev) => [...prev, item.productId]);
      }
      removeCartItem(cartItemId);
      showToast('تم نقل المنتج إلى قائمة المفضلة');
    }
  };

  const selectedCartItems = cart.filter((item) => item.isSelected);

  const selectedCartTotalCny = selectedCartItems.reduce((acc, item) => {
    const unitPrice = item.product.originalPriceCny + (item.selectedVariant.priceModifierCny || 0);
    return acc + unitPrice * item.quantity;
  }, 0);

  // Favorites
  const toggleFavorite = (productId: string) => {
    setFavoriteProductIds((prev) => {
      const exists = prev.includes(productId);
      if (exists) {
        showToast('تمت الإزالة من المفضلة');
        return prev.filter((id) => id !== productId);
      } else {
        showToast('تمت الإضافة إلى المفضلة');
        return [...prev, productId];
      }
    });
  };

  const isFavorite = (productId: string) => favoriteProductIds.includes(productId);

  // Addresses
  const addAddress = (addr: Omit<Address, 'id'>) => {
    const newAddress: Address = {
      ...addr,
      id: `addr-${Date.now()}`,
    };
    setAddresses((prev) => [newAddress, ...prev]);
    setSelectedAddress(newAddress);
    showToast('تمت إضافة العنوان الجديد بنجاح');
  };

  // Checkout & Order creation
  const proceedToCheckout = () => {
    if (selectedCartItems.length === 0) {
      showToast('يرجى تحديد منتج واحد على الأقل من السلة لإكمال الشراء');
      return;
    }
    navigateToView('checkout');
  };

  const confirmOrder = (): Order => {
    const itemsTotalCny = selectedCartTotalCny;
    const itemsConverted = convertPrice(itemsTotalCny);
    // Burhan fee is 5% service fee + inspection
    const burhanFee = currency === 'YER' ? Math.round(itemsConverted * 0.05 + 500) : Number((itemsConverted * 0.05 + 1).toFixed(2));
    const shippingCost = currency === 'YER' ? selectedShipping.priceYer : selectedShipping.priceUsd;
    const taxAndCustoms = currency === 'YER' ? Math.round(itemsConverted * 0.03) : Number((itemsConverted * 0.03).toFixed(2));
    const grandTotal = itemsConverted + burhanFee + shippingCost + taxAndCustoms;

    const orderNum = `BRH-${Math.floor(10000 + Math.random() * 90000)}`;

    const newOrder: Order = {
      id: `ord-${Date.now()}`,
      orderNumber: orderNum,
      createdAt: new Date().toISOString(),
      status: 'pending_payment',
      items: [...selectedCartItems],
      shippingMethod: selectedShipping,
      paymentMethod: selectedPayment,
      address: selectedAddress || addresses[0],
      breakdown: {
        itemsOriginalCny: itemsTotalCny,
        itemsConverted,
        burhanFee,
        shippingCost,
        taxAndCustoms,
        grandTotal,
        currency,
      },
      trackingCode: `CN-YEM-${Math.floor(1000000 + Math.random() * 9000000)}`,
      chinaWarehouseNotes: 'سيتم تصوير المنتجات وفحصها فور استلامها في مستودع قوانغتشو.',
      timeline: [
        {
          status: 'pending_payment',
          title: 'تم إنشاء الطلب',
          description: 'استلم فريق برهان تفاصيل المنتجات وسيتم الشراء فور التأكيد.',
          time: 'الآن',
          location: `${selectedAddress?.city || 'صنعاء'}، اليمن`,
          completed: true,
          current: true,
        },
        {
          status: 'purchased',
          title: 'الشراء من المتجر الصيني',
          description: 'يقوم وكيل الشراء في الصين بالطلب من المتاجر المختارة.',
          completed: false,
          current: false,
        },
        {
          status: 'received_china',
          title: 'الاستلام والفحص في مستودع قوانغتشو',
          description: 'فحص المواصفات، سلامة التغليف، وتصوير عينات للعميل.',
          completed: false,
          current: false,
        },
        {
          status: 'shipped_intl',
          title: 'الشحن الدولي إلى اليمن',
          description: `شحن الطرد عبر ${selectedShipping.nameAr}.`,
          completed: false,
          current: false,
        },
        {
          status: 'customs_local',
          title: 'التخليص الجمركي في اليمن',
          description: 'وصول الطرد للمركز اللوجستي في اليمن والفرز.',
          completed: false,
          current: false,
        },
        {
          status: 'out_for_delivery',
          title: 'في الطريق للتسليم',
          description: 'التنسيق مع مندوب التوصيل للتسليم إلى العنوان المحدد.',
          completed: false,
          current: false,
        },
        {
          status: 'delivered',
          title: 'تم الاستلام بنجاح',
          description: 'اكتملت رحلة الشراء من الصين إلى باب بيتك.',
          completed: false,
          current: false,
        },
      ],
    };

    // CRITICAL: Remove ONLY selected items from cart; unselected items stay!
    setCart((prev) => prev.filter((item) => !item.isSelected));

    // Save order
    setOrders((prev) => [newOrder, ...prev]);
    setLastCreatedOrder(newOrder);

    // Create a new notification
    const orderNotification: NotificationItem = {
      id: `notif-${Date.now()}`,
      title: `تم تأكيد طلبك رقم ${orderNum} بنجاح 🎉`,
      body: `تم اعتماد طلب الشراء من المتاجر الصينية عبر ${selectedShipping.nameAr}.`,
      timestamp: 'الآن',
      type: 'order',
      read: false,
      orderId: newOrder.id,
    };
    setNotifications((prev) => [orderNotification, ...prev]);

    // Navigate to Success view
    setCurrentViewState('order_success');
    return newOrder;
  };

  const openOrderDetails = (orderId: string) => {
    setSelectedOrderId(orderId);
    navigateToView('order_details');
  };

  // Demo tool: Advance order status step-by-step
  const advanceOrderStatus = (orderId: string) => {
    setOrders((prev) =>
      prev.map((order) => {
        if (order.id !== orderId) return order;

        const statuses: OrderStatus[] = [
          'pending_payment',
          'purchased',
          'received_china',
          'shipped_intl',
          'customs_local',
          'out_for_delivery',
          'delivered',
        ];

        const currentIndex = statuses.indexOf(order.status);
        if (currentIndex < statuses.length - 1) {
          const nextStatus = statuses[currentIndex + 1];
          const updatedTimeline = order.timeline.map((step, idx) => {
            if (idx <= currentIndex + 1) {
              return {
                ...step,
                completed: true,
                current: idx === currentIndex + 1,
                time: idx === currentIndex + 1 ? 'محدث للتو' : step.time || 'مكتمل',
              };
            }
            return { ...step, completed: false, current: false };
          });

          showToast(`تم تقدم حالة الطلب إلى: ${updatedTimeline[currentIndex + 1].title}`);
          return {
            ...order,
            status: nextStatus,
            timeline: updatedTimeline,
          };
        }
        showToast('تم تسليم الطلب بالكامل بالفعل!');
        return order;
      })
    );
  };

  // Notifications
  const unreadNotificationsCount = notifications.filter((n) => !n.read).length;

  const markNotificationAsRead = (id: string) => {
    setNotifications((prev) => prev.map((n) => (n.id === id ? { ...n, read: true } : n)));
  };

  const markAllNotificationsAsRead = () => {
    setNotifications((prev) => prev.map((n) => ({ ...n, read: true })));
    showToast('تم تعيين جميع الإشعارات كمقروءة');
  };

  return (
    <AppContext.Provider
      value={{
        activeTab,
        setActiveTab,
        currentView,
        setCurrentView: setCurrentViewState,
        viewHistory,
        navigateBack,
        navigateToView,
        isMobileDeviceView,
        setIsMobileDeviceView,
        user,
        isAuthenticated,
        loginUser,
        logoutUser,
        updateUserProfile,
        currency,
        setCurrency,
        formatPrice,
        convertPrice,
        products,
        selectedProduct,
        openProductDetails,
        selectedStoreForView,
        openStoreView,
        searchQuery,
        setSearchQuery,
        selectedStoreFilter,
        setSelectedStoreFilter,
        parseExternalUrl,
        cart,
        addToCart,
        toggleCartItemSelection,
        selectAllCartItems,
        deselectAllCartItems,
        updateCartQuantity,
        removeCartItem,
        removeSelectedCartItems,
        moveToFavoritesFromCart,
        selectedCartItems,
        selectedCartTotalCny,
        favoriteProductIds,
        toggleFavorite,
        isFavorite,
        addresses,
        addAddress,
        selectedAddress,
        setSelectedAddress,
        selectedShipping,
        setSelectedShipping,
        selectedPayment,
        setSelectedPayment,
        proceedToCheckout,
        confirmOrder,
        lastCreatedOrder,
        orders,
        selectedOrderId,
        openOrderDetails,
        advanceOrderStatus,
        notifications,
        unreadNotificationsCount,
        markNotificationAsRead,
        markAllNotificationsAsRead,
        toastMessage,
        showToast,
      }}
    >
      {children}
    </AppContext.Provider>
  );
};

export const useApp = () => {
  const context = useContext(AppContext);
  if (!context) {
    throw new Error('useApp must be used within an AppProvider');
  }
  return context;
};
