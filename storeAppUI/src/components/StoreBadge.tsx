import React from 'react';
import { StoreType } from '../types';

interface StoreBadgeProps {
  store: StoreType;
  size?: 'sm' | 'md' | 'lg';
  showLabel?: boolean;
  className?: string;
}

export const StoreBadge: React.FC<StoreBadgeProps> = ({
  store,
  size = 'md',
  showLabel = true,
  className = '',
}) => {
  const storeConfig: Record<
    StoreType,
    {
      name: string;
      cnName: string;
      bg: string;
      text: string;
      border: string;
      subtitle: string;
    }
  > = {
    '1688': {
      name: '1688',
      cnName: '阿里巴巴',
      bg: 'bg-orange-50 text-orange-700',
      text: 'text-orange-600',
      border: 'border-orange-200',
      subtitle: 'سعر المصنع الصيني',
    },
    taobao: {
      name: 'Taobao',
      cnName: '淘宝网',
      bg: 'bg-red-50 text-red-700',
      text: 'text-red-600',
      border: 'border-red-200',
      subtitle: 'سوق تاوباو الشامل',
    },
    goofish: {
      name: 'Goofish',
      cnName: '闲鱼',
      bg: 'bg-amber-50 text-amber-900',
      text: 'text-amber-800',
      border: 'border-amber-300',
      subtitle: 'مقتنيات ومستعمل مضمون',
    },
    aliexpress: {
      name: 'AliExpress',
      cnName: '速卖通',
      bg: 'bg-rose-50 text-rose-700',
      text: 'text-rose-600',
      border: 'border-rose-200',
      subtitle: 'علي إكسبريس',
    },
  };

  const config = storeConfig[store];

  const sizeClasses = {
    sm: 'text-[10px] px-1.5 py-0.5 gap-1',
    md: 'text-xs px-2 py-0.5 gap-1.5',
    lg: 'text-sm px-2.5 py-1 gap-2',
  };

  return (
    <span
      className={`inline-flex items-center font-cairo font-bold rounded-md border ${config.bg} ${config.border} ${sizeClasses[size]} ${className}`}
    >
      <span className="font-black tracking-tight">{config.name}</span>
      {showLabel && (
        <span className="text-[10px] opacity-75 font-normal">
          {config.cnName}
        </span>
      )}
    </span>
  );
};
