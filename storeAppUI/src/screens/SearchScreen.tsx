import React, { useState, useMemo } from 'react';
import {
  Search,
  Link as LinkIcon,
  X,
  SlidersHorizontal,
  ArrowUpDown,
  ExternalLink,
  Sparkles,
  CheckCircle2,
  AlertCircle,
} from 'lucide-react';
import { useApp } from '../context/AppContext';
import { ProductCard } from '../components/ProductCard';
import { StoreBadge } from '../components/StoreBadge';
import { StoreType } from '../types';

export const SearchScreen: React.FC = () => {
  const {
    products,
    searchQuery,
    setSearchQuery,
    selectedStoreFilter,
    setSelectedStoreFilter,
    parseExternalUrl,
    openProductDetails,
  } = useApp();

  const [sortBy, setSortBy] = useState<'featured' | 'price_low' | 'price_high' | 'rating' | 'sales'>('featured');
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [showFiltersModal, setShowFiltersModal] = useState(false);

  // Check if current search query is a URL
  const isUrl = useMemo(() => {
    return searchQuery.trim().startsWith('http://') || searchQuery.trim().startsWith('https://');
  }, [searchQuery]);

  const urlParseResult = useMemo(() => {
    if (!isUrl) return null;
    return parseExternalUrl(searchQuery);
  }, [isUrl, searchQuery, parseExternalUrl]);

  // Filtered & sorted results
  const results = useMemo(() => {
    return products
      .filter((p) => {
        // Store filter
        if (selectedStoreFilter !== 'all' && p.store !== selectedStoreFilter) {
          return false;
        }

        // Category filter
        if (selectedCategory !== 'all' && p.category !== selectedCategory) {
          return false;
        }

        // Keyword query
        if (searchQuery.trim() && !isUrl) {
          const q = searchQuery.toLowerCase().trim();
          const matchTitle = p.title.toLowerCase().includes(q);
          const matchDesc = p.description.toLowerCase().includes(q);
          const matchSupplier = p.supplierName.toLowerCase().includes(q);
          const matchStore = p.store.toLowerCase().includes(q);
          if (!matchTitle && !matchDesc && !matchSupplier && !matchStore) {
            return false;
          }
        }

        return true;
      })
      .sort((a, b) => {
        if (sortBy === 'price_low') return a.originalPriceCny - b.originalPriceCny;
        if (sortBy === 'price_high') return b.originalPriceCny - a.originalPriceCny;
        if (sortBy === 'rating') return b.rating - a.rating;
        if (sortBy === 'sales') return b.salesCount - a.salesCount;
        return 0;
      });
  }, [products, searchQuery, selectedStoreFilter, selectedCategory, sortBy, isUrl]);

  const storeOptions: { id: StoreType | 'all'; label: string }[] = [
    { id: 'all', label: 'جميع المتاجر' },
    { id: '1688', label: '1688 (مصانع)' },
    { id: 'taobao', label: 'Taobao' },
    { id: 'goofish', label: 'Goofish' },
    { id: 'aliexpress', label: 'AliExpress' },
  ];

  return (
    <div className="pb-36 text-right space-y-5 px-4 pt-4 max-w-md mx-auto min-h-[85vh]">
      {/* 1. Search & URL Input Box */}
      <div className="relative">
        <div className="flex items-center bg-white rounded-2xl p-2 border border-slate-200/90 shadow-xs focus-within:border-[#0B2038] focus-within:ring-2 focus-within:ring-[#0B2038]/10 transition-all">
          <div className="w-8 h-8 rounded-xl bg-slate-100 text-slate-500 flex items-center justify-center shrink-0">
            {isUrl ? <LinkIcon size={16} className="text-amber-500" /> : <Search size={16} />}
          </div>

          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="ابحث بالاسم أو الصق رابط منتج من الصين..."
            className="w-full bg-transparent px-2.5 text-xs font-medium text-slate-900 placeholder:text-slate-400 focus:outline-none"
          />

          {searchQuery && (
            <button
              onClick={() => setSearchQuery('')}
              className="w-7 h-7 rounded-lg text-slate-400 hover:text-slate-600 flex items-center justify-center active-press"
            >
              <X size={15} />
            </button>
          )}
        </div>
      </div>

      {/* 2. Detected External Link Card (If User Pasted a Chinese URL) */}
      {isUrl && urlParseResult && (
        <div className="bg-amber-50/80 border border-amber-200 rounded-2xl p-3.5 space-y-2.5 transition-all">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-1.5">
              <CheckCircle2 size={16} className="text-amber-600" />
              <span className="text-xs font-bold font-cairo text-amber-900">
                تم التعرف على رابط المتجر الصيني!
              </span>
            </div>
            {urlParseResult.store && <StoreBadge store={urlParseResult.store} size="sm" />}
          </div>

          <p className="text-[11px] text-amber-800 leading-relaxed">
            {urlParseResult.message}
          </p>

          <div className="bg-white rounded-xl p-2.5 border border-amber-200/60 flex items-center justify-between">
            <div className="flex items-center gap-2 truncate max-w-[220px]">
              <ExternalLink size={14} className="text-slate-400 shrink-0" />
              <span className="text-[11px] font-mono text-slate-600 truncate dir-ltr">
                {searchQuery}
              </span>
            </div>

            <button
              onClick={() => {
                // If it's a URL, open the first matching product or demo product
                const matched = products.find((p) => p.store === urlParseResult.store) || products[0];
                openProductDetails(matched);
              }}
              className="bg-[#0B2038] text-white text-[11px] font-bold font-cairo px-3 py-1.5 rounded-lg active-press shrink-0 shadow-xs"
            >
              استيراد وحساب السعر
            </button>
          </div>
        </div>
      )}

      {/* 3. Stores Filter Horizontal Bar */}
      <div className="flex items-center gap-1.5 overflow-x-auto no-scrollbar pb-1">
        {storeOptions.map((opt) => {
          const isSelected = selectedStoreFilter === opt.id;
          return (
            <button
              key={opt.id}
              onClick={() => setSelectedStoreFilter(opt.id)}
              className={`px-3 py-1.5 rounded-xl text-xs font-cairo font-bold whitespace-nowrap transition-all active-press ${
                isSelected
                  ? 'bg-[#0B2038] text-white shadow-xs'
                  : 'bg-white text-slate-600 border border-slate-200/80 hover:bg-slate-50'
              }`}
            >
              {opt.label}
            </button>
          );
        })}
      </div>

      {/* 4. Controls: Results count & Sort dropdown */}
      <div className="flex items-center justify-between text-xs pt-1 border-b border-slate-200/60 pb-2">
        <span className="text-slate-500 font-medium">
          عثرنا على <strong className="text-slate-900">{results.length}</strong> منتج
          {selectedStoreFilter !== 'all' && ` في متجر ${selectedStoreFilter}`}
        </span>

        {/* Sort selector */}
        <div className="flex items-center gap-1">
          <ArrowUpDown size={13} className="text-slate-400" />
          <select
            value={sortBy}
            onChange={(e) => setSortBy(e.target.value as any)}
            className="bg-transparent text-xs font-semibold text-slate-700 cursor-pointer focus:outline-none"
          >
            <option value="featured">المقترحة</option>
            <option value="price_low">الأقل سعراً</option>
            <option value="price_high">الأعلى سعراً</option>
            <option value="rating">الأعلى تقييماً</option>
            <option value="sales">الأكثر طلباً</option>
          </select>
        </div>
      </div>

      {/* 5. Results Grid or Empty State */}
      {results.length > 0 ? (
        <div className="grid grid-cols-2 gap-3">
          {results.map((product) => (
            <ProductCard key={product.id} product={product} layout="grid" />
          ))}
        </div>
      ) : (
        <div className="bg-white rounded-3xl p-8 border border-slate-200/80 text-center space-y-3 my-6">
          <div className="w-14 h-14 rounded-2xl bg-amber-50 text-amber-600 flex items-center justify-center mx-auto">
            <AlertCircle size={28} />
          </div>
          <h3 className="text-base font-bold font-cairo text-slate-900">
            لم نجد نتائج مطابقة لبحثك
          </h3>
          <p className="text-xs text-slate-500 max-w-xs mx-auto leading-relaxed">
            تأكد من كتابة الكلمات بشكل صحيح، أو جرب تغيير المتجر الصيني المحدد، أو الصق رابط المنتج المباشر من 1688 أو Taobao.
          </p>
          <div className="pt-2">
            <button
              onClick={() => {
                setSearchQuery('');
                setSelectedStoreFilter('all');
                setSelectedCategory('all');
              }}
              className="bg-slate-100 hover:bg-slate-200 text-slate-800 text-xs font-bold font-cairo px-4 py-2 rounded-xl active-press"
            >
              إعادة ضبط الفلاتر
            </button>
          </div>
        </div>
      )}
    </div>
  );
};
