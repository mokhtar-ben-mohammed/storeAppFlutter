import React from 'react';

interface BurhanLogoProps {
  size?: 'sm' | 'md' | 'lg' | 'xl';
  showText?: boolean;
  textColor?: 'dark' | 'light';
  className?: string;
  variant?: 'emblem' | 'full' | 'horizontal';
}

export const BurhanLogo: React.FC<BurhanLogoProps> = ({
  size = 'md',
  showText = true,
  textColor = 'dark',
  className = '',
  variant = 'horizontal',
}) => {
  const sizeMap = {
    sm: { emblem: 28, text: 'text-sm', sub: 'text-[9px]' },
    md: { emblem: 40, text: 'text-lg', sub: 'text-[11px]' },
    lg: { emblem: 56, text: 'text-2xl', sub: 'text-xs' },
    xl: { emblem: 84, text: 'text-3xl', sub: 'text-sm' },
  };

  const { emblem: dim, text: textClass, sub: subClass } = sizeMap[size];

  // SVG representation of the official Burhan emblem:
  // Circular badge with dark navy blue foundation, inner disk, and intertwined ribbons with central upward golden arrow.
  const emblemSvg = (
    <svg
      width={dim}
      height={dim}
      viewBox="0 0 100 100"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className="shrink-0 drop-shadow-sm transition-transform duration-300"
    >
      {/* Outer Circle Container */}
      <circle cx="50" cy="50" r="48" fill="#0B2038" stroke="#16345A" strokeWidth="1.5" />
      {/* Inner White Round Plaque */}
      <circle cx="50" cy="50" r="41" fill="#FFFFFF" />

      {/* Center Upward Arrow (Gold) */}
      <path
        d="M50 15L62 33H54V41H46V33H38L50 15Z"
        fill="#E69806"
      />

      {/* Gold Ribbon Left Loop */}
      <path
        d="M50 38C42 32 30 35 24 43C18 52 20 64 30 71C38 76 46 71 50 63C45 56 36 54 31 59C28 62 26 57 28 53C31 46 40 45 47 50L50 38Z"
        fill="#F59E0B"
      />

      {/* Navy Blue Right Loop */}
      <path
        d="M50 38C58 32 70 35 76 43C82 52 80 64 70 71C62 76 54 71 50 63C55 56 64 54 69 59C72 62 74 57 72 53C69 46 60 45 53 50L50 38Z"
        fill="#0F294A"
      />

      {/* Intertwined Gold Arc Right */}
      <path
        d="M50 63C56 71 67 73 73 66C78 60 76 52 71 47C66 42 57 44 52 50C54 53 58 52 61 54C65 57 65 62 61 65C57 68 52 66 50 63Z"
        fill="#E69806"
      />

      {/* Intertwined Navy Arc Left */}
      <path
        d="M50 63C44 71 33 73 27 66C22 60 24 52 29 47C34 42 43 44 48 50C46 53 42 52 39 54C35 57 35 62 39 65C43 68 48 66 50 63Z"
        fill="#0B2038"
      />
    </svg>
  );

  if (variant === 'emblem' || !showText) {
    return <div className={`inline-flex items-center ${className}`}>{emblemSvg}</div>;
  }

  const isLight = textColor === 'light';

  return (
    <div
      className={`inline-flex items-center gap-2.5 ${
        variant === 'full' ? 'flex-col text-center' : 'flex-row'
      } ${className}`}
    >
      {emblemSvg}
      <div className="flex flex-col text-right">
        <div className="flex items-center gap-1.5">
          <span
            className={`font-tajawal font-black tracking-tight ${textClass} ${
              isLight ? 'text-white' : 'text-slate-900'
            }`}
          >
            بُرهان
          </span>
          <span className="font-tajawal font-bold text-amber-500 text-[10px] bg-amber-500/10 px-1.5 py-0.5 rounded border border-amber-500/20">
            BURHAN
          </span>
        </div>
        <span
          className={`font-tajawal font-medium leading-none ${subClass} ${
            isLight ? 'text-slate-300' : 'text-slate-500'
          }`}
        >
          وسيط الشراء الموثوق من الصين
        </span>
      </div>
    </div>
  );
};
