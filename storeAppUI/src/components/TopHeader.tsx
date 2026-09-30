import React from 'react';
import { ArrowRight, Bell } from 'lucide-react';
import { useApp } from '../context/AppContext';
import { BurhanLogo } from './BurhanLogo';

interface TopHeaderProps {
  title?: string;
  showBack?: boolean;
  onBack?: () => void;
  rightAction?: React.ReactNode;
}

export const TopHeader: React.FC<TopHeaderProps> = ({
  title,
  showBack = false,
  onBack,
  rightAction,
}) => {
  const {
    currentView,
    navigateBack,
    navigateToView,
    unreadNotificationsCount,
  } = useApp();

  const handleBack = () => {
    if (onBack) {
      onBack();
    } else {
      navigateBack();
    }
  };

  const isDeepView = currentView !== 'main';

  return (
    <header className="sticky top-0 z-30 w-full bg-white/85 backdrop-blur-md border-b border-slate-200/60 px-4 py-2.5 transition-all">
      <div className="flex items-center justify-between gap-2 max-w-md mx-auto">
        {/* Left Slot: Back button or Logo */}
        {isDeepView || showBack ? (
          <div className="flex items-center gap-2">
            <button
              onClick={handleBack}
              aria-label="الرجوع"
              className="w-8 h-8 rounded-lg flex items-center justify-center bg-slate-100 hover:bg-slate-200 text-slate-800 transition-colors active-press border border-slate-200/60"
            >
              <ArrowRight size={17} />
            </button>
            {title && (
              <h1 className="text-xs font-bold text-slate-900 truncate max-w-[220px]">
                {title}
              </h1>
            )}
          </div>
        ) : (
          <div className="flex items-center">
            <BurhanLogo size="sm" variant="horizontal" />
          </div>
        )}

        {/* Right Slot: Notifications Bell only */}
        <div className="flex items-center gap-1.5">
          {rightAction ? (
            rightAction
          ) : (
            <button
              onClick={() => navigateToView('notifications')}
              aria-label="الإشعارات"
              className="relative w-8 h-8 rounded-lg flex items-center justify-center bg-slate-100/80 hover:bg-slate-200 text-slate-700 border border-slate-200/60 transition-colors active-press shadow-2xs"
            >
              <Bell size={16} />
              {unreadNotificationsCount > 0 && (
                <span className="absolute top-1 end-1 w-2 h-2 bg-amber-500 rounded-full ring-2 ring-white" />
              )}
            </button>
          )}
        </div>
      </div>
    </header>
  );
};


