import React from 'react';
import { StoreType } from '../types';
import { useApp } from '../context/AppContext';

interface StoreItem {
  id: StoreType | 'tmall';
  nameAr: string;
  bgGradient: string;
  shadowColor: string;
  iconSvg: React.ReactNode;
}

export const MarketplaceAppIcons: React.FC = () => {
  const { openStoreView, selectedStoreForView } = useApp();

  const storesList: StoreItem[] = [
    {
      id: '1688',
      nameAr: '1688',
      bgGradient: 'from-[#FF6A00] to-[#FF4E00]',
      shadowColor: 'shadow-orange-500/25',
      iconSvg: (
        <svg viewBox="0 0 48 48" className="w-8 h-8 text-white fill-current">
          <text
            x="50%"
            y="60%"
            textAnchor="middle"
            dominantBaseline="middle"
            fontFamily="system-ui, -apple-system, sans-serif"
            fontWeight="900"
            fontSize="18"
            letterSpacing="-0.5"
          >
            1688
          </text>
        </svg>
      ),
    },
    {
      id: 'taobao',
      nameAr: 'تاوباو',
      bgGradient: 'from-[#FF5000] to-[#E02E00]',
      shadowColor: 'shadow-red-500/25',
      iconSvg: (
        <svg viewBox="0 0 48 48" className="w-7 h-7 text-white fill-current">
          {/* Authentic Stylized Taobao Character "淘" */}
          <path d="M12 16h6v4h-6v-4zm0 8h6v12h-6V24zm10-10h16v4H22v-4zm3 8h10v3H25v-3zm0 7h10v3H25v-3zm0 7h10v3H25v-3zm14-11v18h-4V18h4z" />
          <circle cx="15" cy="18" r="2.5" fill="currentColor" opacity="0.3" />
        </svg>
      ),
    },
    {
      id: 'goofish',
      nameAr: 'جوفيش',
      bgGradient: 'from-[#FFD200] to-[#FFB700]',
      shadowColor: 'shadow-amber-400/25',
      iconSvg: (
        <svg viewBox="0 0 48 48" className="w-7 h-7 text-slate-950 fill-current">
          {/* Goofish stylized fish mascot */}
          <path d="M36 24c-4-4-10-6-16-4-4 1.3-8 4.7-10 9 4 1 9 1 14-1 4-1.6 8-4.5 12-4zm-8-9c-2-3-6-5-10-4-3 .8-6 3-7 6 4 0 8 1 12 1.5 2 .2 3.5-.8 5-3.5z" />
          <circle cx="16" cy="22" r="2.5" fill="currentColor" />
          <path d="M38 18c1.5 3 2.5 7 1.5 11l-3-3c.5-2.5 0-5.5-1.5-8h3z" />
        </svg>
      ),
    },
    {
      id: 'aliexpress',
      nameAr: 'علي إكسبريس',
      bgGradient: 'from-[#E62E04] to-[#C41C00]',
      shadowColor: 'shadow-rose-500/25',
      iconSvg: (
        <svg viewBox="0 0 48 48" className="w-7 h-7 text-white fill-current">
          {/* AliExpress shopping bag */}
          <path d="M14 18h20v18H14V18zm4-6c0-3.3 2.7-6 6-6s6 2.7 6 6v3h-3v-3c0-1.7-1.3-3-3-3s-3 1.3-3 3v3h-3v-3z" />
          <path d="M20 25h8v3h-8v-3z" fill="#FFF" />
        </svg>
      ),
    },
    {
      id: '1688', // Can link to direct factories filter
      nameAr: 'المصانع',
      bgGradient: 'from-[#0B2038] to-[#163B66]',
      shadowColor: 'shadow-slate-800/25',
      iconSvg: (
        <svg viewBox="0 0 24 24" className="w-6 h-6 text-amber-400 fill-current">
          <path d="M12 3L2 12h3v8h14v-8h3L12 3zm0 4.5l5 4.5h-2v6h-6v-6H7l5-4.5z" />
        </svg>
      ),
    },
  ];

  return (
    <div className="w-full">
      {/* Horizontal Smooth Slider for Chinese Marketplace Circles without any enclosing card */}
      <div className="flex items-center gap-4 overflow-x-auto no-scrollbar py-1 px-1">
        {storesList.map((store, index) => {
          const isSelected = selectedStoreForView === store.id;

          return (
            <button
              key={`${store.id}-${index}`}
              onClick={() => openStoreView(store.id as StoreType)}
              className="flex flex-col items-center shrink-0 cursor-pointer active-press group focus:outline-none"
            >
              {/* Perfectly round circle container with vibrant store color */}
              <div
                className={`w-16 h-16 rounded-full bg-gradient-to-br ${
                  store.bgGradient
                } ${store.shadowColor} shadow-md flex items-center justify-center transition-all duration-200 group-hover:scale-105 active:scale-95 ${
                  isSelected ? 'ring-4 ring-amber-400 ring-offset-2' : ''
                }`}
              >
                {store.iconSvg}
              </div>

              {/* Store Name label under circle */}
              <span className="text-xs font-bold font-cairo text-slate-800 mt-2 block tracking-tight">
                {store.nameAr}
              </span>
            </button>
          );
        })}
      </div>
    </div>
  );
};
