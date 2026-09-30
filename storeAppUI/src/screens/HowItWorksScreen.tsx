import React from 'react';
import {
  ShieldCheck,
  Search,
  ShoppingCart,
  Camera,
  Plane,
  Home,
  CheckCircle2,
  DollarSign,
  AlertCircle,
} from 'lucide-react';
import { TopHeader } from '../components/TopHeader';

export const HowItWorksScreen: React.FC = () => {
  const steps = [
    {
      step: '1',
      title: 'اختر منتجك أو الصق رابطه',
      desc: 'تصفح كتالوج برهان المباشر أو انسخ رابط أي منتج يعجبك من 1688 أو Taobao أو Goofish أو AliExpress والصقه في برهان.',
      icon: Search,
      badge: 'حرية اختيار غير محدودة',
    },
    {
      step: '2',
      title: 'حساب شفاف ومفصل للتكلفة',
      desc: 'نعرض لك سعر المنتج الأصلي باليوان الصيني (¥)، ثم نحسب عمولة برهان (5%) والشحن الدولي التقديري بوضوح تام دون أي تكاليف خفية.',
      icon: DollarSign,
      badge: 'شفافية 100%',
    },
    {
      step: '3',
      title: 'الدفع بالريال اليمني أو المحافظ المحلية',
      desc: 'لا تحتاج لحسابات بنكية صينية أو بطاقات دولية. ادفع براحة عبر جوالي، الكريمي، النجم، أو محفظة برهان.',
      icon: ShoppingCart,
      badge: 'وسائل دفع يمنية وعربية',
    },
    {
      step: '4',
      title: 'الشراء والفحص في مستودع قوانغتشو',
      desc: 'يقوم وكيل الشراء المعتمد لدينا في الصين بالطلب من المصنع. فور وصول الطرد، يفحص مفتشونا سلامة القطع وتصويرها وإرسال التقرير لك.',
      icon: Camera,
      badge: 'فحص عيني وتصوير حقيقي',
    },
    {
      step: '5',
      title: 'شحن وتخليص وتوصيل حتى منزلك',
      desc: 'نشحن الطرد عبر أسرع خطوط الشحن الجوي والبحري مع استكمال التخليص الجمركي وتوصيلها لمحافظتك في اليمن.',
      icon: Plane,
      badge: 'تغطية لكافة المحافظات',
    },
  ];

  return (
    <div className="min-h-screen bg-slate-50 text-right pb-28">
      <TopHeader title="كيف تعمل منصة برهان؟" showBack={true} />

      <div className="max-w-md mx-auto px-4 pt-3 space-y-4">
        {/* Hero concept banner */}
        <div className="bg-[#0B2038] text-white rounded-3xl p-5 shadow-sm space-y-2">
          <span className="text-[10px] text-amber-400 font-bold bg-amber-400/20 px-2 py-0.5 rounded border border-amber-400/30">
            مفهوم الوسيط الذكي الموثوق
          </span>
          <h2 className="text-base font-bold font-cairo text-white">
            برهان: جسرك المباشر إلى مصانع الصين
          </h2>
          <p className="text-xs text-slate-300 leading-relaxed">
            برهان ليست متجراً محلياً تقليدياً يخزن البضائع؛ نحن وسيطك المالي واللوجستي الرسمي الذي يشتري لك مباشرة بأسعار المصنع الأصلية مع ضمان الفحص والتوصيل.
          </p>
        </div>

        {/* 5 Steps Timeline */}
        <div className="space-y-3">
          {steps.map((st) => {
            const Icon = st.icon;
            return (
              <div
                key={st.step}
                className="bg-white rounded-2xl p-4 border border-slate-200/80 shadow-xs flex items-start gap-3.5"
              >
                <div className="w-10 h-10 rounded-xl bg-amber-500/10 text-amber-600 flex items-center justify-center font-black font-cairo text-sm shrink-0">
                  {st.step}
                </div>

                <div className="flex-1 min-w-0">
                  <div className="flex items-center justify-between mb-1">
                    <h3 className="text-xs font-bold font-cairo text-slate-900">
                      {st.title}
                    </h3>
                    <span className="text-[9px] bg-slate-100 text-slate-600 px-1.5 py-0.5 rounded font-medium">
                      {st.badge}
                    </span>
                  </div>

                  <p className="text-[11px] text-slate-600 leading-relaxed">
                    {st.desc}
                  </p>
                </div>
              </div>
            );
          })}
        </div>

        {/* Guarantees Box */}
        <div className="bg-emerald-50 border border-emerald-200 rounded-3xl p-4 text-xs text-emerald-950 space-y-2">
          <div className="flex items-center gap-1.5 font-bold font-cairo text-emerald-900">
            <ShieldCheck size={18} className="text-emerald-600" />
            <span>ضمانات برهان للمشتري:</span>
          </div>

          <ul className="space-y-1 text-[11px] text-emerald-800 list-disc list-inside leading-relaxed">
            <li>في حال لم يشحن البائع الصيني المنتج، يُسترد المبلغ فوراً.</li>
            <li>في حال وجد مفتشنا في الصين عيباً مصنعياً، نرفض الاستلام ونعيد المبلغ لك.</li>
            <li>تتبع مباشر لكل خطوة من المستودع الصيني حتى بابك.</li>
          </ul>
        </div>
      </div>
    </div>
  );
};
