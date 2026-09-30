import React, { useState } from 'react';
import {
  Check,
  ChevronLeft,
  MapPin,
  Truck,
  CreditCard,
  ShieldCheck,
  Package,
  Plus,
  ArrowRight,
  PlaneTakeoff,
  Plane,
  Ship,
  Smartphone,
  Building2,
  Wallet,
  Sparkles,
} from 'lucide-react';
import { useApp } from '../context/AppContext';
import { TopHeader } from '../components/TopHeader';
import { StoreBadge } from '../components/StoreBadge';
import { SHIPPING_METHODS, PAYMENT_METHODS } from '../data/mockData';
import { Address, ShippingMethod, PaymentMethod } from '../types';

export const CheckoutScreen: React.FC = () => {
  const {
    selectedCartItems,
    selectedCartTotalCny,
    addresses,
    selectedAddress,
    setSelectedAddress,
    addAddress,
    selectedShipping,
    setSelectedShipping,
    selectedPayment,
    setSelectedPayment,
    confirmOrder,
    formatPrice,
    convertPrice,
    currency,
    navigateBack,
    showToast,
  } = useApp();

  const [activeStep, setActiveStep] = useState<number>(1);
  const [showAddAddressModal, setShowAddAddressModal] = useState(false);

  // New Address form states
  const [newRecipient, setNewRecipient] = useState('');
  const [newPhone, setNewPhone] = useState('+967 7');
  const [newCity, setNewCity] = useState('صنعاء');
  const [newDistrict, setNewDistrict] = useState('');
  const [newStreet, setNewStreet] = useState('');

  // Cost calculations
  const itemsConverted = convertPrice(selectedCartTotalCny);
  const burhanFee =
    currency === 'YER'
      ? Math.round(itemsConverted * 0.05 + 500)
      : Number((itemsConverted * 0.05 + 1).toFixed(2));
  const shippingCost =
    currency === 'YER' ? selectedShipping.priceYer : selectedShipping.priceUsd;
  const customsEstimated =
    currency === 'YER'
      ? Math.round(itemsConverted * 0.03)
      : Number((itemsConverted * 0.03).toFixed(2));
  const grandTotal = itemsConverted + burhanFee + shippingCost + customsEstimated;

  const steps = [
    { number: 1, title: 'المنتجات', icon: Package },
    { number: 2, title: 'العنوان', icon: MapPin },
    { number: 3, title: 'الشحن', icon: Truck },
    { number: 4, title: 'الدفع', icon: CreditCard },
    { number: 5, title: 'المراجعة', icon: ShieldCheck },
  ];

  const handleCreateNewAddress = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newRecipient || !newPhone || !newStreet) {
      showToast('يرجى تعبئة الحقول الأساسية للعنوان');
      return;
    }
    const newAddr: Omit<Address, 'id'> = {
      recipientName: newRecipient,
      phone: newPhone,
      country: 'اليمن',
      city: newCity,
      district: newDistrict || 'الوسط',
      street: newStreet,
      isDefault: false,
    };
    addAddress(newAddr);
    setShowAddAddressModal(false);
  };

  const getShippingIcon = (type: string) => {
    switch (type) {
      case 'air_express':
        return <PlaneTakeoff size={20} className="text-amber-500" />;
      case 'air_standard':
        return <Plane size={20} className="text-blue-500" />;
      case 'sea_freight':
        return <Ship size={20} className="text-emerald-500" />;
      default:
        return <Truck size={20} className="text-slate-500" />;
    }
  };

  const getPaymentIcon = (category: string) => {
    switch (category) {
      case 'wallet':
        return <Smartphone size={20} className="text-blue-600" />;
      case 'exchange':
        return <Building2 size={20} className="text-amber-600" />;
      case 'burhan_balance':
        return <Wallet size={20} className="text-emerald-600" />;
      default:
        return <CreditCard size={20} className="text-purple-600" />;
    }
  };

  return (
    <div className="min-h-screen bg-slate-50 text-right pb-32">
      {/* Header */}
      <TopHeader
        title="إتمام عملية الشراء"
        showBack={true}
        onBack={() => {
          if (activeStep > 1) {
            setActiveStep((s) => s - 1);
          } else {
            navigateBack();
          }
        }}
      />

      <div className="max-w-md mx-auto px-4 pt-3 space-y-4">
        {/* Step Progress Bar */}
        <div className="bg-white rounded-2xl p-3 border border-slate-200/80 shadow-xs">
          <div className="flex items-center justify-between">
            {steps.map((st, idx) => {
              const isPast = activeStep > st.number;
              const isCurrent = activeStep === st.number;

              return (
                <React.Fragment key={st.number}>
                  <button
                    onClick={() => {
                      if (st.number < activeStep) setActiveStep(st.number);
                    }}
                    disabled={st.number > activeStep}
                    className="flex flex-col items-center gap-1 active-press"
                  >
                    <div
                      className={`w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold font-cairo transition-all ${
                        isPast
                          ? 'bg-emerald-500 text-white'
                          : isCurrent
                          ? 'bg-[#0B2038] text-white ring-2 ring-amber-400 ring-offset-2'
                          : 'bg-slate-100 text-slate-400'
                      }`}
                    >
                      {isPast ? <Check size={14} strokeWidth={3} /> : st.number}
                    </div>
                    <span
                      className={`text-[10px] font-bold font-cairo ${
                        isCurrent ? 'text-[#0B2038]' : isPast ? 'text-slate-600' : 'text-slate-400'
                      }`}
                    >
                      {st.title}
                    </span>
                  </button>

                  {idx < steps.length - 1 && (
                    <div
                      className={`flex-1 h-0.5 mx-1 transition-all ${
                        activeStep > idx + 1 ? 'bg-emerald-500' : 'bg-slate-200'
                      }`}
                    />
                  )}
                </React.Fragment>
              );
            })}
          </div>
        </div>

        {/* STEP 1: SELECTED ITEMS ONLY */}
        {activeStep === 1 && (
          <div className="space-y-3">
            <div className="flex items-center justify-between">
              <h2 className="text-xs font-bold font-cairo text-slate-800">
                المنتجات المحددة للشراء ({selectedCartItems.length})
              </h2>
              <span className="text-[11px] text-amber-600 font-medium">
                بقية عناصر السلة محفوظة
              </span>
            </div>

            <div className="space-y-2.5">
              {selectedCartItems.map((item) => {
                const itemUnitCny =
                  item.product.originalPriceCny + (item.selectedVariant.priceModifierCny || 0);
                const itemTotalCny = itemUnitCny * item.quantity;
                const priceItem = formatPrice(itemTotalCny);

                return (
                  <div
                    key={item.id}
                    className="bg-white rounded-2xl p-3 border border-slate-200/80 shadow-xs flex items-center gap-3"
                  >
                    <div className="relative w-16 h-16 rounded-xl overflow-hidden bg-slate-100 shrink-0">
                      <img
                        src={item.product.images[0]}
                        alt={item.product.title}
                        className="w-full h-full object-cover"
                      />
                      <div className="absolute top-1 start-1">
                        <StoreBadge store={item.product.store} size="sm" showLabel={false} />
                      </div>
                    </div>

                    <div className="flex-1 min-w-0">
                      <h4 className="text-xs font-semibold text-slate-900 truncate">
                        {item.product.title}
                      </h4>
                      <div className="mt-1 flex items-center gap-2 text-[11px] text-slate-500">
                        <span className="bg-slate-100 px-1.5 py-0.5 rounded text-slate-700">
                          {item.selectedVariant.name}
                        </span>
                        <span>الكمية: {item.quantity}</span>
                      </div>
                      <div className="mt-1.5 flex items-center justify-between">
                        <span className="text-xs font-bold font-cairo text-[#0B2038]">
                          {priceItem.formatted}
                        </span>
                        <span className="text-[10px] text-slate-400 dir-ltr">
                          (¥{itemTotalCny})
                        </span>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>

            <button
              onClick={() => setActiveStep(2)}
              className="w-full h-12 rounded-xl bg-[#0B2038] hover:bg-slate-800 text-white font-bold font-cairo text-xs flex items-center justify-center gap-2 shadow-md shadow-[#0B2038]/15 active-press cursor-pointer mt-4"
            >
              <span>المتابعة إلى عنوان التوصيل</span>
              <ChevronLeft size={16} />
            </button>
          </div>
        )}

        {/* STEP 2: DELIVERY ADDRESS */}
        {activeStep === 2 && (
          <div className="space-y-3">
            <div className="flex items-center justify-between">
              <h2 className="text-xs font-bold font-cairo text-slate-800">
                اختر عنوان استلام الشحنة في اليمن
              </h2>
              <button
                onClick={() => setShowAddAddressModal(true)}
                className="flex items-center gap-1 text-[11px] font-bold text-amber-600 hover:text-amber-700 active-press"
              >
                <Plus size={14} />
                <span>إضافة عنوان جديد</span>
              </button>
            </div>

            <div className="space-y-2.5">
              {addresses.map((addr) => {
                const isSelected = selectedAddress?.id === addr.id;
                return (
                  <div
                    key={addr.id}
                    onClick={() => setSelectedAddress(addr)}
                    className={`bg-white rounded-2xl p-4 border transition-all cursor-pointer active-press ${
                      isSelected
                        ? 'border-amber-400 ring-2 ring-amber-400/20 shadow-xs'
                        : 'border-slate-200/80 hover:border-slate-300'
                    }`}
                  >
                    <div className="flex items-start justify-between">
                      <div className="flex items-center gap-2">
                        <div
                          className={`w-4 h-4 rounded-full border-2 flex items-center justify-center ${
                            isSelected ? 'border-amber-500 bg-amber-500' : 'border-slate-300'
                          }`}
                        >
                          {isSelected && <div className="w-1.5 h-1.5 rounded-full bg-white" />}
                        </div>
                        <span className="text-xs font-bold text-slate-900 font-cairo">
                          {addr.recipientName}
                        </span>
                        {addr.isDefault && (
                          <span className="text-[10px] bg-slate-100 text-slate-600 px-1.5 py-0.2 rounded font-medium">
                            افتراضي
                          </span>
                        )}
                      </div>

                      <span className="text-[11px] font-mono font-semibold text-slate-600 dir-ltr">
                        {addr.phone}
                      </span>
                    </div>

                    <div className="mt-2 text-xs text-slate-600 leading-relaxed ps-6">
                      <p>
                        {addr.country} - {addr.city} - {addr.district}
                      </p>
                      <p className="text-slate-500 text-[11px] mt-0.5">{addr.street}</p>
                    </div>
                  </div>
                );
              })}
            </div>

            {/* Add Address Modal Inline */}
            {showAddAddressModal && (
              <div className="bg-white rounded-2xl p-4 border-2 border-amber-300 shadow-sm space-y-3">
                <h3 className="text-xs font-bold font-cairo text-slate-900">
                  إضافة عنوان جديد للتوصيل
                </h3>
                <form onSubmit={handleCreateNewAddress} className="space-y-3 text-xs">
                  <div>
                    <label className="block text-slate-600 mb-1">اسم المستلم</label>
                    <input
                      type="text"
                      value={newRecipient}
                      onChange={(e) => setNewRecipient(e.target.value)}
                      placeholder="الاسم الكامل"
                      className="w-full h-10 bg-slate-50 border border-slate-200 rounded-xl px-3 focus:outline-none focus:border-[#0B2038]"
                      required
                    />
                  </div>

                  <div className="grid grid-cols-2 gap-2">
                    <div>
                      <label className="block text-slate-600 mb-1">رقم الهاتف</label>
                      <input
                        type="text"
                        value={newPhone}
                        onChange={(e) => setNewPhone(e.target.value)}
                        placeholder="+967 7..."
                        className="w-full h-10 bg-slate-50 border border-slate-200 rounded-xl px-3 focus:outline-none focus:border-[#0B2038] dir-ltr text-left"
                        required
                      />
                    </div>
                    <div>
                      <label className="block text-slate-600 mb-1">المدينة</label>
                      <select
                        value={newCity}
                        onChange={(e) => setNewCity(e.target.value)}
                        className="w-full h-10 bg-slate-50 border border-slate-200 rounded-xl px-2 focus:outline-none focus:border-[#0B2038]"
                      >
                        <option value="صنعاء">صنعاء</option>
                        <option value="عدن">عدن</option>
                        <option value="تعز">تعز</option>
                        <option value="المكلا">المكلا</option>
                        <option value="إب">إب</option>
                        <option value="الحديدة">الحديدة</option>
                        <option value="مأرب">مأرب</option>
                      </select>
                    </div>
                  </div>

                  <div>
                    <label className="block text-slate-600 mb-1">المنطقة أو الحي</label>
                    <input
                      type="text"
                      value={newDistrict}
                      onChange={(e) => setNewDistrict(e.target.value)}
                      placeholder="مثال: حدة، المعلا، الحصبة"
                      className="w-full h-10 bg-slate-50 border border-slate-200 rounded-xl px-3 focus:outline-none focus:border-[#0B2038]"
                    />
                  </div>

                  <div>
                    <label className="block text-slate-600 mb-1">تفاصيل الشارع والعمارة</label>
                    <input
                      type="text"
                      value={newStreet}
                      onChange={(e) => setNewStreet(e.target.value)}
                      placeholder="الشارع، أقرب معلم بارز، رقم الشقة"
                      className="w-full h-10 bg-slate-50 border border-slate-200 rounded-xl px-3 focus:outline-none focus:border-[#0B2038]"
                      required
                    />
                  </div>

                  <div className="flex items-center gap-2 pt-1">
                    <button
                      type="submit"
                      className="flex-1 h-10 rounded-xl bg-[#0B2038] text-white font-bold font-cairo active-press"
                    >
                      حفظ العنوان
                    </button>
                    <button
                      type="button"
                      onClick={() => setShowAddAddressModal(false)}
                      className="h-10 px-4 rounded-xl bg-slate-100 text-slate-700 font-bold active-press"
                    >
                      إلغاء
                    </button>
                  </div>
                </form>
              </div>
            )}

            <button
              onClick={() => setActiveStep(3)}
              className="w-full h-12 rounded-xl bg-[#0B2038] hover:bg-slate-800 text-white font-bold font-cairo text-xs flex items-center justify-center gap-2 shadow-md shadow-[#0B2038]/15 active-press cursor-pointer mt-4"
            >
              <span>المتابعة إلى طريقة الشحن</span>
              <ChevronLeft size={16} />
            </button>
          </div>
        )}

        {/* STEP 3: SHIPPING METHOD */}
        {activeStep === 3 && (
          <div className="space-y-3">
            <h2 className="text-xs font-bold font-cairo text-slate-800">
              اختر طريقة الشحن من مستودع الصين إلى اليمن
            </h2>

            <div className="space-y-2.5">
              {SHIPPING_METHODS.map((method) => {
                const isSelected = selectedShipping.id === method.id;
                const shippingPriceFormatted =
                  currency === 'YER'
                    ? `${method.priceYer.toLocaleString('en-US')} ر.ي`
                    : `$${method.priceUsd}`;

                return (
                  <div
                    key={method.id}
                    onClick={() => setSelectedShipping(method)}
                    className={`bg-white rounded-2xl p-4 border transition-all cursor-pointer active-press ${
                      isSelected
                        ? 'border-amber-400 ring-2 ring-amber-400/20 shadow-xs'
                        : 'border-slate-200/80 hover:border-slate-300'
                    }`}
                  >
                    <div className="flex items-start justify-between">
                      <div className="flex items-center gap-2.5">
                        <div className="w-10 h-10 rounded-xl bg-slate-50 border border-slate-200 flex items-center justify-center shrink-0">
                          {getShippingIcon(method.type)}
                        </div>
                        <div>
                          <h4 className="text-xs font-bold font-cairo text-slate-900">
                            {method.nameAr}
                          </h4>
                          <span className="text-[11px] text-amber-600 font-semibold block">
                            المدة التقديرية: {method.estimatedDays}
                          </span>
                        </div>
                      </div>

                      <div className="text-left">
                        <span className="text-xs font-black font-cairo text-[#0B2038] block">
                          {shippingPriceFormatted}
                        </span>
                        <span className="text-[10px] text-slate-400">لأول كيلو</span>
                      </div>
                    </div>

                    <p className="mt-2 text-[11px] text-slate-500 leading-relaxed ps-12">
                      {method.description}
                    </p>
                  </div>
                );
              })}
            </div>

            <button
              onClick={() => setActiveStep(4)}
              className="w-full h-12 rounded-xl bg-[#0B2038] hover:bg-slate-800 text-white font-bold font-cairo text-xs flex items-center justify-center gap-2 shadow-md shadow-[#0B2038]/15 active-press cursor-pointer mt-4"
            >
              <span>المتابعة إلى طريقة الدفع</span>
              <ChevronLeft size={16} />
            </button>
          </div>
        )}

        {/* STEP 4: PAYMENT METHOD */}
        {activeStep === 4 && (
          <div className="space-y-3">
            <h2 className="text-xs font-bold font-cairo text-slate-800">
              اختر طريقة الدفع المناسبة لك
            </h2>

            <div className="space-y-2.5">
              {PAYMENT_METHODS.map((pay) => {
                const isSelected = selectedPayment.id === pay.id;

                return (
                  <div
                    key={pay.id}
                    onClick={() => setSelectedPayment(pay)}
                    className={`bg-white rounded-2xl p-4 border transition-all cursor-pointer active-press ${
                      isSelected
                        ? 'border-amber-400 ring-2 ring-amber-400/20 shadow-xs'
                        : 'border-slate-200/80 hover:border-slate-300'
                    }`}
                  >
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-2.5">
                        <div className="w-10 h-10 rounded-xl bg-slate-50 border border-slate-200 flex items-center justify-center shrink-0">
                          {getPaymentIcon(pay.category)}
                        </div>
                        <div>
                          <h4 className="text-xs font-bold font-cairo text-slate-900">
                            {pay.nameAr}
                          </h4>
                          <span className="text-[10px] text-slate-500 block">
                            {pay.provider}
                          </span>
                        </div>
                      </div>

                      <div
                        className={`w-4 h-4 rounded-full border-2 flex items-center justify-center ${
                          isSelected ? 'border-amber-500 bg-amber-500' : 'border-slate-300'
                        }`}
                      >
                        {isSelected && <div className="w-1.5 h-1.5 rounded-full bg-white" />}
                      </div>
                    </div>

                    <p className="mt-2 text-[11px] text-slate-600 ps-12 leading-relaxed">
                      {pay.description}
                    </p>
                  </div>
                );
              })}
            </div>

            <button
              onClick={() => setActiveStep(5)}
              className="w-full h-12 rounded-xl bg-[#0B2038] hover:bg-slate-800 text-white font-bold font-cairo text-xs flex items-center justify-center gap-2 shadow-md shadow-[#0B2038]/15 active-press cursor-pointer mt-4"
            >
              <span>المتابعة لمراجعة الفاتورة النهائية</span>
              <ChevronLeft size={16} />
            </button>
          </div>
        )}

        {/* STEP 5: FINAL ORDER REVIEW */}
        {activeStep === 5 && (
          <div className="space-y-3">
            <h2 className="text-xs font-bold font-cairo text-slate-800">
              مراجعة وتأكيد طلب الشراء النهائي
            </h2>

            {/* Selected summary */}
            <div className="bg-white rounded-2xl p-4 border border-slate-200/80 shadow-xs space-y-2 text-xs">
              <div className="flex items-center justify-between pb-2 border-b border-slate-100">
                <span className="text-slate-500">عنوان الاستلام:</span>
                <span className="font-bold text-slate-800">
                  {selectedAddress?.city} - {selectedAddress?.district}
                </span>
              </div>
              <div className="flex items-center justify-between pb-2 border-b border-slate-100">
                <span className="text-slate-500">خيار الشحن الدولي:</span>
                <span className="font-bold text-slate-800">
                  {selectedShipping.nameAr}
                </span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-slate-500">طريقة الدفع:</span>
                <span className="font-bold text-slate-800">
                  {selectedPayment.nameAr}
                </span>
              </div>
            </div>

            {/* Price breakdown card */}
            <div className="bg-white rounded-2xl p-4 border border-slate-200/80 shadow-xs space-y-2.5 text-xs">
              <h3 className="font-bold font-cairo text-slate-900 border-b border-slate-100 pb-2">
                تفاصيل الفاتورة الشفافة:
              </h3>

              <div className="flex items-center justify-between text-slate-600">
                <span>سعر المنتجات من المتاجر الصينية:</span>
                <span className="font-bold font-mono">
                  {itemsConverted.toLocaleString('en-US')} {formatPrice(0).symbol}
                </span>
              </div>

              <div className="flex items-center justify-between text-slate-600">
                <span>عمولة فحص وتغليف برهان (5%):</span>
                <span className="font-bold font-mono">
                  {burhanFee.toLocaleString('en-US')} {formatPrice(0).symbol}
                </span>
              </div>

              <div className="flex items-center justify-between text-slate-600">
                <span>رسوم الشحن الدولي ({selectedShipping.nameAr}):</span>
                <span className="font-bold font-mono">
                  {shippingCost.toLocaleString('en-US')} {formatPrice(0).symbol}
                </span>
              </div>

              <div className="flex items-center justify-between text-slate-600">
                <span>التخليص الجمركي والرسوم المحلية (تقديري 3%):</span>
                <span className="font-bold font-mono">
                  {customsEstimated.toLocaleString('en-US')} {formatPrice(0).symbol}
                </span>
              </div>

              <div className="pt-2 border-t border-slate-200 flex items-center justify-between text-base font-black font-cairo text-[#0B2038]">
                <span>المبلغ الإجمالي النهائي:</span>
                <span className="text-lg text-amber-600">
                  {grandTotal.toLocaleString('en-US')} {formatPrice(0).symbol}
                </span>
              </div>
            </div>

            {/* Guarantee note */}
            <div className="bg-emerald-50 border border-emerald-200 rounded-2xl p-3 flex items-start gap-2 text-xs text-emerald-900">
              <ShieldCheck size={18} className="text-emerald-600 shrink-0 mt-0.5" />
              <p className="text-[11px] leading-relaxed">
                ضمان برهان: في حال عدم مطابقة المنتج للصور أو وجود تلف من المصنع الصيني، يتم استرداد المبلغ بالكامل إلى محفظتك.
              </p>
            </div>

            {/* Confirm CTA */}
            <button
              onClick={() => confirmOrder()}
              className="w-full h-13 rounded-xl bg-amber-500 hover:bg-amber-600 text-white font-bold font-cairo text-sm flex items-center justify-center gap-2 shadow-lg shadow-amber-500/25 active-press transition-all cursor-pointer mt-4"
            >
              <span>تأكيد الطلب وبدء الشراء الآن</span>
              <Sparkles size={16} />
            </button>
          </div>
        )}
      </div>
    </div>
  );
};
