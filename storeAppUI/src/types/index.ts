export type StoreType = '1688' | 'taobao' | 'goofish' | 'aliexpress';

export type CurrencyType = 'YER' | 'USD' | 'SAR' | 'CNY';

export interface ProductVariant {
  id: string;
  name: string; // e.g. "أسود تيتانيوم" or "أبيض عاجي"
  colorHex?: string;
  priceModifierCny?: number;
  inStock: boolean;
  image?: string;
}

export interface WholesaleTier {
  minQty: number;
  priceCny: number;
}

export interface Product {
  id: string;
  title: string;
  store: StoreType;
  storeUrl?: string;
  supplierName: string;
  supplierRating: number;
  originalPriceCny: number;
  marketPriceCny?: number;
  rating: number;
  salesCount: number;
  images: string[];
  category: string;
  description: string;
  variants: ProductVariant[];
  wholesaleTiers?: WholesaleTier[];
  weightKg: number;
  estimatedDeliveryDays: string;
  specs: { label: string; value: string }[];
  isVerifiedSupplier: boolean;
  featured?: boolean;
}

export interface CartItem {
  id: string; // unique cart item id
  productId: string;
  product: Product;
  selectedVariant: ProductVariant;
  quantity: number;
  isSelected: boolean; // For partial selection!
  addedAt: string;
}

export interface Address {
  id: string;
  recipientName: string;
  phone: string;
  country: string;
  city: string;
  district: string;
  street: string;
  isDefault: boolean;
  note?: string;
}

export interface ShippingMethod {
  id: string;
  nameAr: string;
  nameEn: string;
  estimatedDays: string;
  priceYer: number;
  priceUsd: number;
  icon: string;
  description: string;
  type: 'air_express' | 'air_standard' | 'sea_freight';
}

export interface PaymentMethod {
  id: string;
  nameAr: string;
  category: 'wallet' | 'exchange' | 'card' | 'burhan_balance';
  icon: string;
  description: string;
  provider: string;
}

export type OrderStatus =
  | 'pending_payment'
  | 'processing'
  | 'purchased'
  | 'received_china'
  | 'shipped_intl'
  | 'customs_local'
  | 'out_for_delivery'
  | 'delivered'
  | 'cancelled';

export interface OrderTimelineStep {
  status: OrderStatus;
  title: string;
  description: string;
  time?: string;
  location?: string;
  completed: boolean;
  current: boolean;
}

export interface Order {
  id: string;
  orderNumber: string;
  createdAt: string;
  status: OrderStatus;
  items: CartItem[];
  shippingMethod: ShippingMethod;
  paymentMethod: PaymentMethod;
  address: Address;
  breakdown: {
    itemsOriginalCny: number;
    itemsConverted: number;
    burhanFee: number;
    shippingCost: number;
    taxAndCustoms: number;
    grandTotal: number;
    currency: CurrencyType;
  };
  trackingCode?: string;
  chinaWarehouseNotes?: string;
  timeline: OrderTimelineStep[];
}

export interface User {
  id: string;
  name: string;
  phone: string;
  countryCode: string;
  country: string;
  city: string;
  gender: 'male' | 'female' | 'other';
  walletBalanceYer: number;
  walletBalanceUsd: number;
  isLoggedIn: boolean;
}

export interface NotificationItem {
  id: string;
  title: string;
  body: string;
  timestamp: string;
  type: 'order' | 'shipping' | 'promo' | 'system';
  read: boolean;
  orderId?: string;
}

export interface CategoryItem {
  id: string;
  nameAr: string;
  nameEn: string;
  iconName: string;
  count: number;
}
