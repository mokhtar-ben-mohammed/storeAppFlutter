import React, { useEffect } from 'react';
import { useApp } from '../context/AppContext';
import { BurhanLogo } from '../components/BurhanLogo';
import { ShieldCheck, ArrowLeft, Globe, Truck } from 'lucide-react';

export const SplashScreen: React.FC = () => {
  const { setCurrentView, isAuthenticated } = useApp();

  useEffect(() => {
    const timer = setTimeout(() => {
      if (isAuthenticated) {
        setCurrentView('main');
      } else {
        setCurrentView('auth');
      }
    }, 2400);

    return () => clearTimeout(timer);
  }, [isAuthenticated, setCurrentView]);

  const handleSkip = () => {
    if (isAuthenticated) {
      setCurrentView('main');
    } else {
      setCurrentView('auth');
    }
  };

  return (
    <div className="relative min-h-screen w-full bg-[#0B2038] text-white flex flex-col justify-between p-6 select-none overflow-hidden">
      {/* Decorative background geometry */}
      <div className="absolute -top-24 -right-24 w-80 h-80 rounded-full bg-amber-500/10 blur-3xl pointer-events-none" />
      <div className="absolute -bottom-20 -left-20 w-80 h-80 rounded-full bg-blue-600/15 blur-3xl pointer-events-none" />
      <div className="absolute inset-0 bg-[radial-gradient(#ffffff0a_1px,transparent_1px)] [background-size:16px_16px] pointer-events-none" />

      {/* Top bar with quick skip button */}
      <div className="relative z-10 flex justify-end">
        <button
          onClick={handleSkip}
          className="text-xs font-tajawal text-slate-300 hover:text-white flex items-center gap-1 bg-white/10 hover:bg-white/15 px-3 py-1.5 rounded-full transition-colors active-press"
        >
          <span>تخطي</span>
          <ArrowLeft size={14} />
        </button>
      </div>

      {/* Center Branding */}
      <div className="relative z-10 flex flex-col items-center text-center my-auto">
        <div className="relative p-3 rounded-full bg-gradient-to-b from-white/10 to-transparent border border-white/10 shadow-2xl mb-5 animate-pulse">
          <BurhanLogo size="xl" variant="emblem" />
        </div>

        <h1 className="text-3xl font-black font-cairo tracking-tight text-white mb-2">
          مَنَصَّةُ بُرْهَان
        </h1>
        <p className="text-sm font-medium font-tajawal text-amber-400 max-w-xs mb-6">
          وسيطك الذكي للتسوق المباشر من مصانع وأسواق الصين
        </p>

        {/* Supported Marketplaces row */}
        <div className="flex items-center justify-center gap-2 bg-white/5 border border-white/10 rounded-xl px-4 py-2 text-xs font-cairo">
          <span className="text-orange-400 font-bold">1688</span>
          <span className="text-slate-400">·</span>
          <span className="text-red-400 font-bold">Taobao</span>
          <span className="text-slate-400">·</span>
          <span className="text-yellow-300 font-bold">Goofish</span>
          <span className="text-slate-400">·</span>
          <span className="text-rose-400 font-bold">AliExpress</span>
        </div>
      </div>

      {/* Bottom Features & Trust */}
      <div className="relative z-10 flex flex-col items-center gap-4 text-center">
        <div className="grid grid-cols-3 gap-2 w-full max-w-sm text-center">
          <div className="bg-white/5 rounded-xl p-2.5 border border-white/5 flex flex-col items-center">
            <Globe size={18} className="text-amber-400 mb-1" />
            <span className="text-[11px] font-bold">شراء مباشر</span>
            <span className="text-[9px] text-slate-400">من المصانع</span>
          </div>
          <div className="bg-white/5 rounded-xl p-2.5 border border-white/5 flex flex-col items-center">
            <ShieldCheck size={18} className="text-emerald-400 mb-1" />
            <span className="text-[11px] font-bold">فحص جودة</span>
            <span className="text-[9px] text-slate-400">قبل الشحن</span>
          </div>
          <div className="bg-white/5 rounded-xl p-2.5 border border-white/5 flex flex-col items-center">
            <Truck size={18} className="text-blue-400 mb-1" />
            <span className="text-[11px] font-bold">شحن لليمن</span>
            <span className="text-[9px] text-slate-400">جوي وبحري</span>
          </div>
        </div>

        {/* Loading Indicator */}
        <div className="flex items-center gap-2 text-xs text-slate-400 mt-2">
          <div className="w-2 h-2 rounded-full bg-amber-400 animate-ping" />
          <span>جاري تهيئة منصة برهان...</span>
        </div>
      </div>
    </div>
  );
};
