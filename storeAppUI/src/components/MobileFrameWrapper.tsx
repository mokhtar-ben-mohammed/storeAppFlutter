import React, { useState, useEffect } from 'react';
import { useApp } from '../context/AppContext';
import {
  Wifi,
  Battery,
  Smartphone,
  Maximize2,
  Minimize2,
  RotateCcw,
  Sparkles,
} from 'lucide-react';
import { BurhanLogo } from './BurhanLogo';

interface MobileFrameWrapperProps {
  children: React.ReactNode;
}

export const MobileFrameWrapper: React.FC<MobileFrameWrapperProps> = ({ children }) => {
  const {
    isMobileDeviceView,
    setIsMobileDeviceView,
    setCurrentView,
    currency,
    setCurrency,
    cart,
    orders,
  } = useApp();

  const [currentTime, setCurrentTime] = useState('09:41');

  useEffect(() => {
    const updateTime = () => {
      const now = new Date();
      const hours = String(now.getHours()).padStart(2, '0');
      const minutes = String(now.getMinutes()).padStart(2, '0');
      setCurrentTime(`${hours}:${minutes}`);
    };
    updateTime();
    const interval = setInterval(updateTime, 30000);
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="min-h-screen bg-slate-900 text-slate-100 flex flex-col items-center justify-start antialiased">
      {/* Top Desktop Presentation Bar */}
      <div className="w-full bg-[#071526] border-b border-slate-800 px-4 py-2 flex items-center justify-between text-xs z-50">
        <div className="flex items-center gap-3">
          <BurhanLogo size="sm" textColor="light" />
          <span className="hidden sm:inline-block text-[11px] text-slate-400 border-s border-slate-700 ps-3">
            نسخة تجريبية متكاملة لرحلة العميل (End-to-End Mobile Prototype)
          </span>
        </div>

        <div className="flex items-center gap-2">
          {/* Quick actions for evaluator */}
          <button
            onClick={() => setCurrentView('splash')}
            className="flex items-center gap-1 bg-slate-800 hover:bg-slate-700 text-slate-300 hover:text-white px-2.5 py-1.5 rounded-lg text-xs transition-colors active-press"
            title="إعادة تشغيل شاشة البداية"
          >
            <RotateCcw size={13} />
            <span className="hidden md:inline">Splash Screen</span>
          </button>

          <button
            onClick={() => setIsMobileDeviceView(!isMobileDeviceView)}
            className="flex items-center gap-1.5 bg-amber-500/20 text-amber-300 hover:bg-amber-500/30 px-3 py-1.5 rounded-lg text-xs font-bold font-cairo transition-colors active-press border border-amber-500/30"
          >
            {isMobileDeviceView ? <Maximize2 size={13} /> : <Minimize2 size={13} />}
            <span>{isMobileDeviceView ? 'عرض الشاشة الكامل' : 'إطار الهاتف'}</span>
          </button>
        </div>
      </div>

      {/* Main Container */}
      <div
        className={`w-full flex justify-center items-start transition-all duration-300 ${
          isMobileDeviceView ? 'py-4 md:py-8' : 'p-0'
        }`}
      >
        {isMobileDeviceView ? (
          /* Sleek iPhone-style Mobile Frame */
          <div className="relative w-full max-w-[412px] min-h-[844px] max-h-[92vh] bg-slate-50 text-slate-900 rounded-[44px] shadow-[0_25px_70px_rgba(0,0,0,0.6)] border-[9px] border-slate-800 overflow-hidden flex flex-col">
            {/* Phone Top Notch / Dynamic Island */}
            <div className="sticky top-0 z-50 w-full bg-slate-900 text-white px-6 pt-2 pb-1.5 flex items-center justify-between text-xs select-none">
              <span className="font-mono font-bold text-[11px]">{currentTime}</span>

              {/* Dynamic Island Pill */}
              <div className="w-24 h-4 bg-black rounded-full flex items-center justify-center">
                <div className="w-2 h-2 rounded-full bg-slate-800 me-2" />
              </div>

              <div className="flex items-center gap-1.5 text-slate-300">
                <Wifi size={12} />
                <span className="text-[10px] font-mono">5G</span>
                <Battery size={14} className="fill-slate-300" />
              </div>
            </div>

            {/* Scrollable Mobile App Body */}
            <div className="flex-1 overflow-y-auto no-scrollbar relative flex flex-col bg-slate-50">
              {children}
            </div>

            {/* Home Indicator Bar */}
            <div className="w-full bg-white pb-2 pt-1 flex justify-center border-t border-slate-100 z-50">
              <div className="w-32 h-1 bg-slate-300 rounded-full" />
            </div>
          </div>
        ) : (
          /* Fluid Responsive Full View */
          <div className="w-full max-w-xl min-h-screen bg-slate-50 text-slate-900 shadow-2xl flex flex-col">
            {children}
          </div>
        )}
      </div>
    </div>
  );
};
