import React, { useState } from 'react';
import {
  User,
  MapPin,
  Heart,
  PackageCheck,
  ShoppingBag,
  Bell,
  Globe,
  Moon,
  Sun,
  ShieldCheck,
  Headphones,
  FileText,
  LogOut,
  ChevronLeft,
  Edit2,
  Check,
  Trash2,
  HelpCircle,
  AlertTriangle,
  X,
  CreditCard,
  MessageCircle,
  Phone,
  Send,
  Sparkles,
} from 'lucide-react';
import { useApp } from '../context/AppContext';
import { CurrencyType } from '../types';

type ActiveSheet =
  | null
  | 'edit_profile'
  | 'currency'
  | 'language'
  | 'theme'
  | 'support'
  | 'guarantee'
  | 'delete_account';

export const ProfileScreen: React.FC = () => {
  const {
    user,
    logoutUser,
    updateUserProfile,
    navigateToView,
    setActiveTab,
    currency,
    setCurrency,
    favoriteProductIds,
    cart,
    orders,
    showToast,
  } = useApp();

  const [activeSheet, setActiveSheet] = useState<ActiveSheet>(null);

  // Profile edit fields
  const [editName, setEditName] = useState(user?.name || '');
  const [editCity, setEditCity] = useState(user?.city || 'صنعاء');

  // App preferences
  const [appLanguage, setAppLanguage] = useState<'ar' | 'en'>('ar');
  const [appTheme, setAppTheme] = useState<'light' | 'dark' | 'system'>('light');
  const [notificationsEnabled, setNotificationsEnabled] = useState(true);

  const cartTotalItems = cart.reduce((acc, item) => acc + item.quantity, 0);

  const handleSaveProfile = () => {
    if (!editName.trim()) {
      showToast('يرجى كتابة الاسم الكريم');
      return;
    }
    updateUserProfile({ name: editName, city: editCity });
    setActiveSheet(null);
    showToast('تم تحديث بيانات الملف الشخصي بنجاح');
  };

  const handleDeleteAccount = () => {
    setActiveSheet(null);
    logoutUser();
    showToast('تم حذف الحساب والبيانات نهائياً');
  };

  const currencyOptions: { id: CurrencyType; label: string; code: string; flag: string; desc: string }[] = [
    { id: 'YER', label: 'ريال يمني', code: 'YER', flag: '🇾🇪', desc: 'العملة الرسمية للتسوق والتوصيل في اليمن' },
    { id: 'SAR', label: 'ريال سعودي', code: 'SAR', flag: '🇸🇦', desc: 'الريال السعودي المعتمد للحوالات' },
    { id: 'USD', label: 'دولار أمريكي', code: 'USD', flag: '🇺🇸', desc: 'الدولار الأمريكي المعتمد دولياً' },
    { id: 'CNY', label: 'يوان صيني', code: 'CNY', flag: '🇨🇳', desc: 'سعر التكلفة الأصلي في مصانع الصين' },
  ];

  const languageOptions = [
    { id: 'ar', label: 'العربية (Arabic)', desc: 'واجهة استخدام عربية كاملة من اليمين لليسار' },
    { id: 'en', label: 'English', desc: 'English interface and international layout' },
  ];

  const themeOptions = [
    { id: 'light', label: 'المظهر الفاتح (Light Mode)', icon: Sun, desc: 'تصميم ناصع وواضح لمختلف ظروف الإضاءة' },
    { id: 'dark', label: 'المظهر الداكن (Dark Mode)', icon: Moon, desc: 'توفير لطاقة البطارية وراحة إضافية للعين' },
    { id: 'system', label: 'تلقائي حسب النظام (System Default)', icon: Sparkles, desc: 'يتبع الإعداد المفضل لجهازك الذكي' },
  ];

  return (
    <div className="pb-36 text-right max-w-md mx-auto px-4 pt-3 space-y-4 min-h-[85vh]">
      {/* 1. User Profile Glass Card (No Wallet Strip as Requested) */}
      <div className="bg-white/85 backdrop-blur-md rounded-xl p-4 border border-slate-200/70 shadow-xs">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            {/* Avatar with initial */}
            <div className="relative w-12 h-12 rounded-xl bg-gradient-to-br from-[#0B2038] to-[#163B66] text-amber-400 flex items-center justify-center font-black text-lg shadow-xs">
              {user?.name ? user.name.slice(0, 1) : 'ب'}
              <span className="absolute -bottom-1 -end-1 w-3.5 h-3.5 bg-emerald-500 rounded-full border-2 border-white" />
            </div>

            <div>
              <div className="flex items-center gap-1.5">
                <h2 className="text-sm font-bold text-slate-900">
                  {user?.name || 'عميل برهان'}
                </h2>
                <span className="text-[9px] font-bold bg-amber-500/10 text-amber-700 px-1.5 py-0.2 rounded border border-amber-500/20">
                  موثق
                </span>
              </div>
              <p className="text-[11px] text-slate-500 font-mono mt-0.5 dir-ltr text-right">
                {user?.countryCode} {user?.phone}
              </p>
              <div className="flex items-center gap-1 text-[11px] text-slate-400 mt-0.5">
                <MapPin size={11} className="text-amber-500" />
                <span>
                  {user?.country} - {user?.city}
                </span>
              </div>
            </div>
          </div>

          <button
            onClick={() => {
              setEditName(user?.name || '');
              setEditCity(user?.city || 'صنعاء');
              setActiveSheet('edit_profile');
            }}
            className="w-8 h-8 rounded-lg bg-slate-100/90 hover:bg-slate-200 text-slate-700 flex items-center justify-center transition-colors active-press border border-slate-200/60"
            aria-label="تعديل بيانات الملف الشخصي"
          >
            <Edit2 size={13} />
          </button>
        </div>
      </div>

      {/* SECTION 1: نشاطي ومشترياتي (My Activity & Orders) */}
      <div className="space-y-1.5">
        <h3 className="text-xs font-bold text-slate-500 px-1">
          المشتريات والنشاط
        </h3>

        <div className="bg-white/85 backdrop-blur-md rounded-xl border border-slate-200/70 shadow-xs divide-y divide-slate-100 overflow-hidden">
          {/* Tile: Orders */}
          <div
            onClick={() => setActiveTab('orders')}
            className="flex items-center justify-between p-3 hover:bg-slate-50/80 transition-colors cursor-pointer active-press"
          >
            <div className="flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center shrink-0">
                <PackageCheck size={16} />
              </div>
              <div>
                <span className="text-xs font-bold text-slate-800 block">سجل طلباتي</span>
                <span className="text-[10px] text-slate-400">متابعة مسار الشحنات ومراحل التوصيل</span>
              </div>
            </div>

            <div className="flex items-center gap-1.5">
              <span className="text-[10px] font-bold bg-blue-50 text-blue-700 px-2 py-0.5 rounded-md">
                {orders.length} طلبات
              </span>
              <ChevronLeft size={15} className="text-slate-400" />
            </div>
          </div>

          {/* Tile: Cart */}
          <div
            onClick={() => setActiveTab('cart')}
            className="flex items-center justify-between p-3 hover:bg-slate-50/80 transition-colors cursor-pointer active-press"
          >
            <div className="flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-lg bg-amber-50 text-amber-600 flex items-center justify-center shrink-0">
                <ShoppingBag size={16} />
              </div>
              <div>
                <span className="text-xs font-bold text-slate-800 block">سلة التسوق والشراء الجزئي</span>
                <span className="text-[10px] text-slate-400">إدارة المنتجات وتحديد ما تريد شراءه</span>
              </div>
            </div>

            <div className="flex items-center gap-1.5">
              {cartTotalItems > 0 && (
                <span className="text-[10px] font-bold bg-amber-50 text-amber-700 px-2 py-0.5 rounded-md">
                  {cartTotalItems} عناصر
                </span>
              )}
              <ChevronLeft size={15} className="text-slate-400" />
            </div>
          </div>

          {/* Tile: Favorites */}
          <div
            onClick={() => navigateToView('favorites')}
            className="flex items-center justify-between p-3 hover:bg-slate-50/80 transition-colors cursor-pointer active-press"
          >
            <div className="flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-lg bg-rose-50 text-rose-500 flex items-center justify-center shrink-0">
                <Heart size={16} />
              </div>
              <div>
                <span className="text-xs font-bold text-slate-800 block">المنتجات المفضلة</span>
                <span className="text-[10px] text-slate-400">المنتجات المحفوظة للطلب لاحقاً</span>
              </div>
            </div>

            <div className="flex items-center gap-1.5">
              <span className="text-[10px] font-bold bg-rose-50 text-rose-700 px-2 py-0.5 rounded-md">
                {favoriteProductIds.length} منتجات
              </span>
              <ChevronLeft size={15} className="text-slate-400" />
            </div>
          </div>

          {/* Tile: Saved Addresses */}
          <div
            onClick={() => showToast('العنوان الافتراضي: صنعاء - شارع حدة')}
            className="flex items-center justify-between p-3 hover:bg-slate-50/80 transition-colors cursor-pointer active-press"
          >
            <div className="flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center shrink-0">
                <MapPin size={16} />
              </div>
              <div>
                <span className="text-xs font-bold text-slate-800 block">عناوين التوصيل المسجلة</span>
                <span className="text-[10px] text-slate-400">إدارة مواقع الاستلام في محافظات اليمن</span>
              </div>
            </div>

            <ChevronLeft size={15} className="text-slate-400" />
          </div>
        </div>
      </div>

      {/* SECTION 2: إعدادات التطبيق والمظهر (Preferences via BottomSheet) */}
      <div className="space-y-1.5">
        <h3 className="text-xs font-bold text-slate-500 px-1">
          إعدادات التطبيق والمظهر
        </h3>

        <div className="bg-white/85 backdrop-blur-md rounded-xl border border-slate-200/70 shadow-xs divide-y divide-slate-100 overflow-hidden">
          {/* Tile: Currency (Opens BottomSheet) */}
          <div
            onClick={() => setActiveSheet('currency')}
            className="flex items-center justify-between p-3 hover:bg-slate-50/80 transition-colors cursor-pointer active-press"
          >
            <div className="flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-lg bg-slate-100 text-slate-700 flex items-center justify-center shrink-0">
                <CreditCard size={16} />
              </div>
              <div>
                <span className="text-xs font-bold text-slate-800 block">العملة المعروضة</span>
                <span className="text-[10px] text-slate-400">تحويل فوري لأسعار المصانع الصينية</span>
              </div>
            </div>

            <div className="flex items-center gap-1.5">
              <span className="text-xs font-bold bg-slate-100 px-2 py-0.5 rounded-md text-slate-800">
                {currencyOptions.find((c) => c.id === currency)?.flag}{' '}
                {currencyOptions.find((c) => c.id === currency)?.code}
              </span>
              <ChevronLeft size={15} className="text-slate-400" />
            </div>
          </div>

          {/* Tile: Language (Opens BottomSheet) */}
          <div
            onClick={() => setActiveSheet('language')}
            className="flex items-center justify-between p-3 hover:bg-slate-50/80 transition-colors cursor-pointer active-press"
          >
            <div className="flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-lg bg-slate-100 text-slate-700 flex items-center justify-center shrink-0">
                <Globe size={16} />
              </div>
              <div>
                <span className="text-xs font-bold text-slate-800 block">لغة التطبيق</span>
                <span className="text-[10px] text-slate-400">واجهة المستخدم واتجاه العرض</span>
              </div>
            </div>

            <div className="flex items-center gap-1.5">
              <span className="text-xs font-bold bg-slate-100 px-2 py-0.5 rounded-md text-slate-800">
                {appLanguage === 'ar' ? 'العربية' : 'English'}
              </span>
              <ChevronLeft size={15} className="text-slate-400" />
            </div>
          </div>

          {/* Tile: Theme (Opens BottomSheet) */}
          <div
            onClick={() => setActiveSheet('theme')}
            className="flex items-center justify-between p-3 hover:bg-slate-50/80 transition-colors cursor-pointer active-press"
          >
            <div className="flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-lg bg-slate-100 text-slate-700 flex items-center justify-center shrink-0">
                {appTheme === 'dark' ? <Moon size={16} /> : <Sun size={16} />}
              </div>
              <div>
                <span className="text-xs font-bold text-slate-800 block">المظهر والثيم</span>
                <span className="text-[10px] text-slate-400">نمط الألوان وراحة العين</span>
              </div>
            </div>

            <div className="flex items-center gap-1.5">
              <span className="text-xs font-bold bg-slate-100 px-2 py-0.5 rounded-md text-slate-800">
                {appTheme === 'light' ? 'فاتح' : appTheme === 'dark' ? 'داكن' : 'تلقائي'}
              </span>
              <ChevronLeft size={15} className="text-slate-400" />
            </div>
          </div>

          {/* Tile: Notifications Toggle */}
          <div className="flex items-center justify-between p-3">
            <div className="flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-lg bg-slate-100 text-slate-700 flex items-center justify-center shrink-0">
                <Bell size={16} />
              </div>
              <div>
                <span className="text-xs font-bold text-slate-800 block">إشعارات الشحنات والعروض</span>
                <span className="text-[10px] text-slate-400">تنبيهات حالة الشحن وتصوير الفحص</span>
              </div>
            </div>

            <button
              onClick={() => {
                setNotificationsEnabled(!notificationsEnabled);
                showToast(
                  !notificationsEnabled
                    ? 'تم تفعيل إشعارات الشحن'
                    : 'تم كتم إشعارات التطبيق مؤقتاً'
                );
              }}
              className={`w-10 h-5 rounded-full transition-colors relative active-press ${
                notificationsEnabled ? 'bg-[#0B2038]' : 'bg-slate-300'
              }`}
            >
              <span
                className={`absolute top-0.5 w-4 h-4 rounded-full bg-white transition-transform ${
                  notificationsEnabled ? 'start-5.5' : 'start-0.5'
                }`}
              />
            </button>
          </div>
        </div>
      </div>

      {/* SECTION 3: الدعم والضمانات (Support via BottomSheet) */}
      <div className="space-y-1.5">
        <h3 className="text-xs font-bold text-slate-500 px-1">
          الدعم والضمانات
        </h3>

        <div className="bg-white/85 backdrop-blur-md rounded-xl border border-slate-200/70 shadow-xs divide-y divide-slate-100 overflow-hidden">
          {/* Tile: How Burhan Works */}
          <div
            onClick={() => navigateToView('how_it_works')}
            className="flex items-center justify-between p-3 hover:bg-slate-50/80 transition-colors cursor-pointer active-press"
          >
            <div className="flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-lg bg-amber-50 text-amber-700 flex items-center justify-center shrink-0">
                <HelpCircle size={16} />
              </div>
              <div>
                <span className="text-xs font-bold text-slate-800 block">دليل عمل منصة برهان</span>
                <span className="text-[10px] text-slate-400">خطوات الشراء، الفحص، والشحن لبابك</span>
              </div>
            </div>

            <ChevronLeft size={15} className="text-slate-400" />
          </div>

          {/* Tile: Customer Service (Opens BottomSheet) */}
          <div
            onClick={() => setActiveSheet('support')}
            className="flex items-center justify-between p-3 hover:bg-slate-50/80 transition-colors cursor-pointer active-press"
          >
            <div className="flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center shrink-0">
                <Headphones size={16} />
              </div>
              <div>
                <span className="text-xs font-bold text-slate-800 block">خدمة العملاء والمساعدة</span>
                <span className="text-[10px] text-slate-400">فريق الدعم المباشر عبر واتساب وتيليجرام</span>
              </div>
            </div>

            <ChevronLeft size={15} className="text-slate-400" />
          </div>

          {/* Tile: Guarantees (Opens BottomSheet) */}
          <div
            onClick={() => setActiveSheet('guarantee')}
            className="flex items-center justify-between p-3 hover:bg-slate-50/80 transition-colors cursor-pointer active-press"
          >
            <div className="flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center shrink-0">
                <ShieldCheck size={16} />
              </div>
              <div>
                <span className="text-xs font-bold text-slate-800 block">الضمانات وسياسة الاسترجاع</span>
                <span className="text-[10px] text-slate-400">فحص عيني 100% واسترداد عند عدم المطابقة</span>
              </div>
            </div>

            <ChevronLeft size={15} className="text-slate-400" />
          </div>
        </div>
      </div>

      {/* SECTION 4: إدارة الحساب والأمان (Account & Security) */}
      <div className="space-y-1.5">
        <h3 className="text-xs font-bold text-slate-500 px-1">
          إدارة الحساب والأمان
        </h3>

        <div className="bg-white/85 backdrop-blur-md rounded-xl border border-slate-200/70 shadow-xs divide-y divide-slate-100 overflow-hidden">
          {/* Tile: Logout */}
          <div
            onClick={logoutUser}
            className="flex items-center justify-between p-3 hover:bg-amber-50/50 transition-colors cursor-pointer active-press"
          >
            <div className="flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-lg bg-amber-50 text-amber-700 flex items-center justify-center shrink-0">
                <LogOut size={16} />
              </div>
              <div>
                <span className="text-xs font-bold text-slate-800 block">تسجيل الخروج</span>
                <span className="text-[10px] text-slate-400">الخروج من هذا الجهاز أو التبديل لحساب آخر</span>
              </div>
            </div>

            <ChevronLeft size={15} className="text-slate-400" />
          </div>

          {/* Tile: Delete Account (Opens BottomSheet) */}
          <div
            onClick={() => setActiveSheet('delete_account')}
            className="flex items-center justify-between p-3 hover:bg-rose-50/60 transition-colors cursor-pointer active-press"
          >
            <div className="flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-lg bg-rose-50 text-rose-600 flex items-center justify-center shrink-0">
                <Trash2 size={16} />
              </div>
              <div>
                <span className="text-xs font-bold text-rose-600 block">حذف الحساب نهائياً</span>
                <span className="text-[10px] text-slate-400">مسح كافة البيانات وسجل الطلبات من الخوادم</span>
              </div>
            </div>

            <ChevronLeft size={15} className="text-rose-400" />
          </div>
        </div>
      </div>

      {/* App Version Info */}
      <div className="text-center text-[10px] text-slate-400 pt-2 pb-2">
        <span>منصة برهان (Burhan) · الإصدار 2.4.0</span>
        <br />
        <span>بوابتك الموثوقة للشراء المباشر من مصانع الصين</span>
      </div>

      {/* ========================================================================= */}
      {/* PROFESSIONAL BOTTOM SHEETS (Smooth Native Experience) */}
      {/* ========================================================================= */}

      {/* 1. CURRENCY BOTTOM SHEET */}
      {activeSheet === 'currency' && (
        <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-xs flex items-end justify-center p-0 animate-in fade-in">
          <div
            onClick={(e) => e.stopPropagation()}
            className="w-full max-w-md bg-white rounded-t-2xl p-5 space-y-4 shadow-2xl border-t border-slate-200 animate-in slide-in-from-bottom duration-200"
          >
            <div className="w-10 h-1 bg-slate-300 rounded-full mx-auto" />
            <div className="flex items-center justify-between pb-2 border-b border-slate-100">
              <h3 className="text-sm font-bold text-slate-900">اختر عملة التسوق والعرض</h3>
              <button
                onClick={() => setActiveSheet(null)}
                className="w-7 h-7 rounded-lg bg-slate-100 flex items-center justify-center text-slate-500 hover:text-slate-800"
              >
                <X size={15} />
              </button>
            </div>

            <div className="space-y-2">
              {currencyOptions.map((opt) => {
                const isSelected = currency === opt.id;
                return (
                  <div
                    key={opt.id}
                    onClick={() => {
                      setCurrency(opt.id);
                      setActiveSheet(null);
                      showToast(`تم تغيير العملة إلى ${opt.label} (${opt.code})`);
                    }}
                    className={`flex items-center justify-between p-3 rounded-xl border transition-all cursor-pointer active-press ${
                      isSelected
                        ? 'border-[#0B2038] bg-slate-50 ring-1 ring-[#0B2038]/20'
                        : 'border-slate-200 hover:border-slate-300'
                    }`}
                  >
                    <div className="flex items-center gap-3">
                      <span className="text-xl">{opt.flag}</span>
                      <div>
                        <span className="text-xs font-bold text-slate-900 block">{opt.label} ({opt.code})</span>
                        <span className="text-[10px] text-slate-500">{opt.desc}</span>
                      </div>
                    </div>

                    <div
                      className={`w-5 h-5 rounded-full border flex items-center justify-center ${
                        isSelected ? 'border-[#0B2038] bg-[#0B2038] text-white' : 'border-slate-300'
                      }`}
                    >
                      {isSelected && <Check size={12} strokeWidth={3} />}
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      )}

      {/* 2. LANGUAGE BOTTOM SHEET */}
      {activeSheet === 'language' && (
        <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-xs flex items-end justify-center p-0 animate-in fade-in">
          <div
            onClick={(e) => e.stopPropagation()}
            className="w-full max-w-md bg-white rounded-t-2xl p-5 space-y-4 shadow-2xl border-t border-slate-200 animate-in slide-in-from-bottom duration-200"
          >
            <div className="w-10 h-1 bg-slate-300 rounded-full mx-auto" />
            <div className="flex items-center justify-between pb-2 border-b border-slate-100">
              <h3 className="text-sm font-bold text-slate-900">لغة واجهة التطبيق</h3>
              <button
                onClick={() => setActiveSheet(null)}
                className="w-7 h-7 rounded-lg bg-slate-100 flex items-center justify-center text-slate-500 hover:text-slate-800"
              >
                <X size={15} />
              </button>
            </div>

            <div className="space-y-2">
              {languageOptions.map((opt) => {
                const isSelected = appLanguage === opt.id;
                return (
                  <div
                    key={opt.id}
                    onClick={() => {
                      setAppLanguage(opt.id as 'ar' | 'en');
                      setActiveSheet(null);
                      showToast(opt.id === 'ar' ? 'تم اختيار اللغة العربية' : 'English selected');
                    }}
                    className={`flex items-center justify-between p-3 rounded-xl border transition-all cursor-pointer active-press ${
                      isSelected
                        ? 'border-[#0B2038] bg-slate-50 ring-1 ring-[#0B2038]/20'
                        : 'border-slate-200 hover:border-slate-300'
                    }`}
                  >
                    <div>
                      <span className="text-xs font-bold text-slate-900 block">{opt.label}</span>
                      <span className="text-[10px] text-slate-500">{opt.desc}</span>
                    </div>

                    <div
                      className={`w-5 h-5 rounded-full border flex items-center justify-center ${
                        isSelected ? 'border-[#0B2038] bg-[#0B2038] text-white' : 'border-slate-300'
                      }`}
                    >
                      {isSelected && <Check size={12} strokeWidth={3} />}
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      )}

      {/* 3. THEME BOTTOM SHEET */}
      {activeSheet === 'theme' && (
        <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-xs flex items-end justify-center p-0 animate-in fade-in">
          <div
            onClick={(e) => e.stopPropagation()}
            className="w-full max-w-md bg-white rounded-t-2xl p-5 space-y-4 shadow-2xl border-t border-slate-200 animate-in slide-in-from-bottom duration-200"
          >
            <div className="w-10 h-1 bg-slate-300 rounded-full mx-auto" />
            <div className="flex items-center justify-between pb-2 border-b border-slate-100">
              <h3 className="text-sm font-bold text-slate-900">مظهر وثيم التطبيق</h3>
              <button
                onClick={() => setActiveSheet(null)}
                className="w-7 h-7 rounded-lg bg-slate-100 flex items-center justify-center text-slate-500 hover:text-slate-800"
              >
                <X size={15} />
              </button>
            </div>

            <div className="space-y-2">
              {themeOptions.map((opt) => {
                const isSelected = appTheme === opt.id;
                const Icon = opt.icon;
                return (
                  <div
                    key={opt.id}
                    onClick={() => {
                      setAppTheme(opt.id as 'light' | 'dark' | 'system');
                      setActiveSheet(null);
                      showToast(`تم تطبيق ${opt.label}`);
                    }}
                    className={`flex items-center justify-between p-3 rounded-xl border transition-all cursor-pointer active-press ${
                      isSelected
                        ? 'border-[#0B2038] bg-slate-50 ring-1 ring-[#0B2038]/20'
                        : 'border-slate-200 hover:border-slate-300'
                    }`}
                  >
                    <div className="flex items-center gap-3">
                      <div className="w-8 h-8 rounded-lg bg-slate-100 text-slate-700 flex items-center justify-center">
                        <Icon size={16} />
                      </div>
                      <div>
                        <span className="text-xs font-bold text-slate-900 block">{opt.label}</span>
                        <span className="text-[10px] text-slate-500">{opt.desc}</span>
                      </div>
                    </div>

                    <div
                      className={`w-5 h-5 rounded-full border flex items-center justify-center ${
                        isSelected ? 'border-[#0B2038] bg-[#0B2038] text-white' : 'border-slate-300'
                      }`}
                    >
                      {isSelected && <Check size={12} strokeWidth={3} />}
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      )}

      {/* 4. EDIT PROFILE BOTTOM SHEET */}
      {activeSheet === 'edit_profile' && (
        <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-xs flex items-end justify-center p-0 animate-in fade-in">
          <div
            onClick={(e) => e.stopPropagation()}
            className="w-full max-w-md bg-white rounded-t-2xl p-5 space-y-4 shadow-2xl border-t border-slate-200 animate-in slide-in-from-bottom duration-200"
          >
            <div className="w-10 h-1 bg-slate-300 rounded-full mx-auto" />
            <div className="flex items-center justify-between pb-2 border-b border-slate-100">
              <h3 className="text-sm font-bold text-slate-900">تعديل بيانات الملف الشخصي</h3>
              <button
                onClick={() => setActiveSheet(null)}
                className="w-7 h-7 rounded-lg bg-slate-100 flex items-center justify-center text-slate-500 hover:text-slate-800"
              >
                <X size={15} />
              </button>
            </div>

            <div className="space-y-3">
              <div>
                <label className="block text-slate-600 text-xs mb-1 font-semibold">
                  الاسم الكامل
                </label>
                <input
                  type="text"
                  value={editName}
                  onChange={(e) => setEditName(e.target.value)}
                  placeholder="الاسم الكريم"
                  className="w-full h-10 bg-slate-50 border border-slate-200 rounded-xl px-3 text-xs font-medium text-slate-900 focus:outline-none focus:border-[#0B2038]"
                />
              </div>

              <div>
                <label className="block text-slate-600 text-xs mb-1 font-semibold">
                  المدينة الرئيسية في اليمن
                </label>
                <select
                  value={editCity}
                  onChange={(e) => setEditCity(e.target.value)}
                  className="w-full h-10 bg-slate-50 border border-slate-200 rounded-xl px-3 text-xs font-medium text-slate-900 focus:outline-none focus:border-[#0B2038]"
                >
                  <option value="صنعاء">صنعاء</option>
                  <option value="عدن">عدن</option>
                  <option value="تعز">تعز</option>
                  <option value="المكلا">المكلا</option>
                  <option value="إب">إب</option>
                  <option value="الحديدة">الحديدة</option>
                  <option value="سيئون">سيئون</option>
                  <option value="مأرب">مأرب</option>
                </select>
              </div>

              <div className="bg-slate-50 rounded-xl p-2.5 border border-slate-200/80 flex items-center justify-between text-xs">
                <span className="text-slate-500">رقم الهاتف المسجل:</span>
                <span className="font-mono font-bold text-slate-800 dir-ltr">
                  {user?.countryCode} {user?.phone}
                </span>
              </div>

              <button
                onClick={handleSaveProfile}
                className="w-full h-10 rounded-xl bg-[#0B2038] hover:bg-slate-800 text-white font-bold text-xs flex items-center justify-center gap-1.5 active-press transition-colors shadow-xs"
              >
                <Check size={14} />
                <span>حفظ التعديلات</span>
              </button>
            </div>
          </div>
        </div>
      )}

      {/* 5. CUSTOMER SUPPORT BOTTOM SHEET */}
      {activeSheet === 'support' && (
        <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-xs flex items-end justify-center p-0 animate-in fade-in">
          <div
            onClick={(e) => e.stopPropagation()}
            className="w-full max-w-md bg-white rounded-t-2xl p-5 space-y-4 shadow-2xl border-t border-slate-200 animate-in slide-in-from-bottom duration-200"
          >
            <div className="w-10 h-1 bg-slate-300 rounded-full mx-auto" />
            <div className="flex items-center justify-between pb-2 border-b border-slate-100">
              <h3 className="text-sm font-bold text-slate-900">خدمة العملاء والدعم الفني</h3>
              <button
                onClick={() => setActiveSheet(null)}
                className="w-7 h-7 rounded-lg bg-slate-100 flex items-center justify-center text-slate-500 hover:text-slate-800"
              >
                <X size={15} />
              </button>
            </div>

            <p className="text-xs text-slate-500 leading-relaxed">
              فريق دعم منصة برهان متواجد على مدار الساعة في اليمن ومستودع قوانغتشو للإجابة على استفساراتكم ومتابعة شحناتكم.
            </p>

            <div className="space-y-2.5">
              <a
                href="https://wa.me/967770000000"
                target="_blank"
                rel="noopener noreferrer"
                onClick={() => setActiveSheet(null)}
                className="flex items-center justify-between p-3 rounded-xl border border-emerald-200 bg-emerald-50/60 hover:bg-emerald-50 transition-colors active-press"
              >
                <div className="flex items-center gap-3">
                  <div className="w-8 h-8 rounded-lg bg-emerald-500 text-white flex items-center justify-center">
                    <MessageCircle size={17} />
                  </div>
                  <div>
                    <span className="text-xs font-bold text-emerald-950 block">محادثة واتساب الفورية</span>
                    <span className="text-[10px] text-emerald-700">رد فوري من ممثلي خدمة العملاء</span>
                  </div>
                </div>
                <ChevronLeft size={15} className="text-emerald-600" />
              </a>

              <a
                href="https://t.me/burhan_platform"
                target="_blank"
                rel="noopener noreferrer"
                onClick={() => setActiveSheet(null)}
                className="flex items-center justify-between p-3 rounded-xl border border-sky-200 bg-sky-50/60 hover:bg-sky-50 transition-colors active-press"
              >
                <div className="flex items-center gap-3">
                  <div className="w-8 h-8 rounded-lg bg-sky-500 text-white flex items-center justify-center">
                    <Send size={16} />
                  </div>
                  <div>
                    <span className="text-xs font-bold text-sky-950 block">قناة ومجتمع تيليجرام</span>
                    <span className="text-[10px] text-sky-700">تحديثات الشحن ومواعيد مغادرة الرحلات</span>
                  </div>
                </div>
                <ChevronLeft size={15} className="text-sky-600" />
              </a>

              <div
                onClick={() => {
                  showToast('ساعات العمل: 24/7 طوال أيام الأسبوع');
                  setActiveSheet(null);
                }}
                className="flex items-center justify-between p-3 rounded-xl border border-slate-200 bg-slate-50/60 transition-colors active-press"
              >
                <div className="flex items-center gap-3">
                  <div className="w-8 h-8 rounded-lg bg-[#0B2038] text-white flex items-center justify-center">
                    <Phone size={15} />
                  </div>
                  <div>
                    <span className="text-xs font-bold text-slate-900 block">رقم الاتصال الموحد</span>
                    <span className="text-[10px] text-slate-500 font-mono dir-ltr text-right">+967 1 234567</span>
                  </div>
                </div>
                <span className="text-[10px] font-bold text-emerald-600 bg-emerald-100/80 px-2 py-0.5 rounded">متاح الآن</span>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* 6. GUARANTEES & RETURN POLICY BOTTOM SHEET */}
      {activeSheet === 'guarantee' && (
        <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-xs flex items-end justify-center p-0 animate-in fade-in">
          <div
            onClick={(e) => e.stopPropagation()}
            className="w-full max-w-md bg-white rounded-t-2xl p-5 space-y-4 shadow-2xl border-t border-slate-200 animate-in slide-in-from-bottom duration-200 max-h-[85vh] overflow-y-auto no-scrollbar"
          >
            <div className="w-10 h-1 bg-slate-300 rounded-full mx-auto" />
            <div className="flex items-center justify-between pb-2 border-b border-slate-100">
              <div className="flex items-center gap-1.5">
                <ShieldCheck size={18} className="text-emerald-600" />
                <h3 className="text-sm font-bold text-slate-900">وثيقة ضمانات برهان وسياسة الاسترجاع</h3>
              </div>
              <button
                onClick={() => setActiveSheet(null)}
                className="w-7 h-7 rounded-lg bg-slate-100 flex items-center justify-center text-slate-500 hover:text-slate-800"
              >
                <X size={15} />
              </button>
            </div>

            <div className="space-y-3 text-xs leading-relaxed text-slate-600">
              <div className="bg-emerald-50/70 border border-emerald-200 rounded-xl p-3 space-y-1">
                <span className="font-bold text-emerald-950 block">1. الفحص العيني الشامل في قوانغتشو</span>
                <p className="text-[11px] text-emerald-900">
                  فور استلام بضائعك من مصانع 1688 أو Taobao، يقوم فريقنا بفتح الطرد والتأكد من مطابقة اللون والمقاس وعدم وجود عيوب مصنعية ظاهرة.
                </p>
              </div>

              <div className="bg-slate-50 border border-slate-200 rounded-xl p-3 space-y-1">
                <span className="font-bold text-slate-900 block">2. التصوير التوثيقي قبل الشحن الدولي</span>
                <p className="text-[11px] text-slate-600">
                  نرسل صوراً حقيقية عالية الدقة للمنتج في المستودع الصيني، وفي حال عدم رضاك يتم إرجاعه فوراً للبائع الصيني واسترداد المبلغ.
                </p>
              </div>

              <div className="bg-slate-50 border border-slate-200 rounded-xl p-3 space-y-1">
                <span className="font-bold text-slate-900 block">3. ضمان التعويض عن التلف والفقدان</span>
                <p className="text-[11px] text-slate-600">
                  كافة الشحنات مؤمنة ضد مخاطر النقل والشحن الدولي؛ وفي حال حدوث أي ضرر يتم تعويض العميل دون تأخير.
                </p>
              </div>

              <div className="bg-slate-50 border border-slate-200 rounded-xl p-3 space-y-1">
                <span className="font-bold text-slate-900 block">4. سياسة استرداد الأموال</span>
                <p className="text-[11px] text-slate-600">
                  تتم إعادة المبالغ فوراً إلى حساب العميل بنفس طريقة الدفع الأصلية في حال إلغاء الطلب قبل الشحن الدولي.
                </p>
              </div>
            </div>

            <button
              onClick={() => setActiveSheet(null)}
              className="w-full h-10 rounded-xl bg-[#0B2038] text-white font-bold text-xs active-press"
            >
              فهمت الشروط والضمانات
            </button>
          </div>
        </div>
      )}

      {/* 7. DELETE ACCOUNT BOTTOM SHEET (Replaces the Center Modal) */}
      {activeSheet === 'delete_account' && (
        <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-xs flex items-end justify-center p-0 animate-in fade-in">
          <div
            onClick={(e) => e.stopPropagation()}
            className="w-full max-w-md bg-white rounded-t-2xl p-5 space-y-4 shadow-2xl border-t border-rose-200 animate-in slide-in-from-bottom duration-200 text-center"
          >
            <div className="w-10 h-1 bg-slate-300 rounded-full mx-auto" />

            <div className="w-12 h-12 rounded-xl bg-rose-50 text-rose-600 flex items-center justify-center mx-auto shadow-xs">
              <AlertTriangle size={24} />
            </div>

            <div className="space-y-1">
              <h3 className="text-base font-bold text-slate-900">
                تأكيد حذف الحساب نهائياً
              </h3>
              <p className="text-xs text-slate-500 leading-relaxed max-w-xs mx-auto">
                هذا الإجراء لا يمكن التراجع عنه. سيؤدي إلى حذف كافة سجلاتك وطلباتك الجارية وبياناتك الشخصية من منصة برهان.
              </p>
            </div>

            <div className="flex items-center gap-2 pt-2">
              <button
                onClick={handleDeleteAccount}
                className="flex-1 h-10 rounded-xl bg-rose-600 hover:bg-rose-700 text-white text-xs font-bold active-press transition-colors shadow-xs"
              >
                تأكيد الحذف النهائي
              </button>
              <button
                onClick={() => setActiveSheet(null)}
                className="flex-1 h-10 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 text-xs font-bold active-press transition-colors"
              >
                إلغاء وتراجع
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
