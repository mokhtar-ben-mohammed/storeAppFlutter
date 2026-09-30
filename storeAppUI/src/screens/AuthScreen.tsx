import React, { useState, useRef, useEffect } from 'react';
import { useApp } from '../context/AppContext';
import { BurhanLogo } from '../components/BurhanLogo';
import { Phone, ArrowRight, ShieldCheck, CheckCircle2, User, MapPin } from 'lucide-react';

const COUNTRY_CODES = [
  { code: '+967', country: 'اليمن', flag: '🇾🇪', example: '77XXXXXXX' },
  { code: '+966', country: 'السعودية', flag: '🇸🇦', example: '50XXXXXXX' },
  { code: '+971', country: 'الإمارات', flag: '🇦🇪', example: '50XXXXXXX' },
  { code: '+968', country: 'عُمان', flag: '🇴🇲', example: '9XXXXXXX' },
  { code: '+20', country: 'مصر', flag: '🇪🇬', example: '10XXXXXXXX' },
  { code: '+965', country: 'الكويت', flag: '🇰🇼', example: '9XXXXXXX' },
  { code: '+974', country: 'قطر', flag: '🇶🇦', example: '5XXXXXXX' },
];

const YEMEN_CITIES = ['صنعاء', 'عدن', 'تعز', 'المكلا', 'إب', 'الحديدة', 'ذمار', 'سيئون', 'مأرب'];

export const AuthScreen: React.FC = () => {
  const { loginUser, showToast, setCurrentView } = useApp();

  const [activeTab, setActiveTab] = useState<'login' | 'register'>('login');
  const [step, setStep] = useState<'phone' | 'otp' | 'profile_completion'>('phone');

  // Phone Form
  const [selectedCountryCode, setSelectedCountryCode] = useState('+967');
  const [phoneNumber, setPhoneNumber] = useState('771234567');

  // OTP Form (6 digits)
  const [otp, setOtp] = useState<string[]>(['', '', '', '', '', '']);
  const [timer, setTimer] = useState(60);
  const [isResendActive, setIsResendActive] = useState(false);
  const otpInputRefs = useRef<(HTMLInputElement | null)[]>([]);

  // Registration Extra Info
  const [fullName, setFullName] = useState('مختار غالب');
  const [gender, setGender] = useState<'male' | 'female'>('male');
  const [city, setCity] = useState('صنعاء');

  // Timer countdown
  useEffect(() => {
    let interval: NodeJS.Timeout;
    if (step === 'otp' && timer > 0) {
      interval = setInterval(() => {
        setTimer((t) => t - 1);
      }, 1000);
    } else if (timer === 0) {
      setIsResendActive(true);
    }
    return () => clearInterval(interval);
  }, [step, timer]);

  // Handle phone submit
  const handlePhoneSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!phoneNumber || phoneNumber.trim().length < 6) {
      showToast('يرجى إدخال رقم هاتف صحيح');
      return;
    }
    setStep('otp');
    setTimer(60);
    setIsResendActive(false);
    // Autofill demo OTP helper
    setTimeout(() => {
      setOtp(['4', '8', '2', '9', '1', '0']);
      showToast('تم إرسال رمز التحقق: 482910');
    }, 800);
  };

  // OTP digit change
  const handleOtpChange = (index: number, value: string) => {
    if (!/^\d*$/.test(value)) return;

    const newOtp = [...otp];
    newOtp[index] = value.slice(-1);
    setOtp(newOtp);

    // Auto advance
    if (value && index < 5) {
      otpInputRefs.current[index + 1]?.focus();
    }
  };

  // Handle backspace navigation in OTP
  const handleKeyDown = (index: number, e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Backspace' && !otp[index] && index > 0) {
      otpInputRefs.current[index - 1]?.focus();
    }
  };

  // Handle paste OTP
  const handleOtpPaste = (e: React.ClipboardEvent<HTMLInputElement>) => {
    e.preventDefault();
    const pastedData = e.clipboardData.getData('text').trim().slice(0, 6);
    if (/^\d+$/.test(pastedData)) {
      const digits = pastedData.split('');
      const newOtp = [...otp];
      digits.forEach((d, idx) => {
        if (idx < 6) newOtp[idx] = d;
      });
      setOtp(newOtp);
      otpInputRefs.current[Math.min(digits.length, 5)]?.focus();
    }
  };

  // Resend OTP
  const handleResendOtp = () => {
    setTimer(60);
    setIsResendActive(false);
    setOtp(['', '', '', '', '', '']);
    showToast('تم إعادة إرسال رمز التحقق: 894321');
    setTimeout(() => {
      setOtp(['8', '9', '4', '3', '2', '1']);
    }, 600);
  };

  // Verify OTP
  const handleVerifyOtp = () => {
    const enteredCode = otp.join('');
    if (enteredCode.length < 6) {
      showToast('يرجى إدخال جميع خانات رمز التحقق (6 أرقام)');
      return;
    }

    if (activeTab === 'register') {
      setStep('profile_completion');
    } else {
      loginUser(phoneNumber, selectedCountryCode);
    }
  };

  // Complete Registration
  const handleCompleteRegistration = () => {
    if (!fullName.trim()) {
      showToast('يرجى كتابة الاسم الكريم');
      return;
    }
    loginUser(phoneNumber, selectedCountryCode, fullName, city);
  };

  return (
    <div className="min-h-screen w-full bg-slate-50 flex flex-col justify-between p-4 sm:p-6 text-right font-tajawal">
      {/* Top Bar */}
      <div className="w-full max-w-md mx-auto flex items-center justify-between py-2">
        {step !== 'phone' ? (
          <button
            onClick={() => setStep(step === 'profile_completion' ? 'otp' : 'phone')}
            className="flex items-center gap-1.5 text-xs font-semibold text-slate-600 hover:text-slate-900 bg-white border border-slate-200 px-3 py-1.5 rounded-xl shadow-xs transition-colors active-press"
          >
            <ArrowRight size={16} />
            <span>تغيير الرقم</span>
          </button>
        ) : (
          <button
            onClick={() => {
              // Allow guest access directly
              loginUser('770000000', '+967', 'زائر برهان', 'صنعاء');
            }}
            className="text-xs font-semibold text-slate-500 hover:text-[#0B2038] underline"
          >
            تصفح كزائر
          </button>
        )}

        <BurhanLogo size="sm" variant="horizontal" />
      </div>

      {/* Main Form Box */}
      <div className="w-full max-w-md mx-auto my-auto bg-white rounded-3xl p-6 shadow-sm border border-slate-200/80 transition-all">
        {step === 'phone' && (
          <div>
            {/* Tabs Header: تسجيل الدخول / إنشاء حساب */}
            <div className="flex bg-slate-100 p-1 rounded-2xl mb-6">
              <button
                type="button"
                onClick={() => setActiveTab('login')}
                className={`flex-1 py-2.5 rounded-xl text-xs font-bold font-cairo transition-all ${
                  activeTab === 'login'
                    ? 'bg-white text-[#0B2038] shadow-xs'
                    : 'text-slate-500 hover:text-slate-800'
                }`}
              >
                تسجيل الدخول
              </button>
              <button
                type="button"
                onClick={() => setActiveTab('register')}
                className={`flex-1 py-2.5 rounded-xl text-xs font-bold font-cairo transition-all ${
                  activeTab === 'register'
                    ? 'bg-white text-[#0B2038] shadow-xs'
                    : 'text-slate-500 hover:text-slate-800'
                }`}
              >
                إنشاء حساب جديد
              </button>
            </div>

            <div className="mb-5">
              <h2 className="text-xl font-black font-cairo text-slate-900 mb-1">
                {activeTab === 'login' ? 'مرحباً بعودتك! 👋' : 'انضم إلى منصة برهان ✨'}
              </h2>
              <p className="text-xs text-slate-500 leading-relaxed">
                {activeTab === 'login'
                  ? 'أدخل رقم هاتفك لتسجيل الدخول ومتابعة طلباتك من المتاجر الصينية.'
                  : 'أنشئ حسابك وتسوّق مباشرة من 1688، تاوباو، جوفيش مع فحص وضمان برهان.'}
              </p>
            </div>

            <form onSubmit={handlePhoneSubmit} className="space-y-4">
              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1.5">
                  رقم الهاتف المحمول
                </label>
                <div className="flex items-center gap-2" dir="ltr">
                  {/* Country Code Selector */}
                  <div className="relative">
                    <select
                      value={selectedCountryCode}
                      onChange={(e) => setSelectedCountryCode(e.target.value)}
                      className="h-12 bg-slate-100 hover:bg-slate-200 border border-slate-200 rounded-xl px-2.5 text-xs font-bold text-slate-800 focus:outline-none focus:ring-2 focus:ring-amber-500 cursor-pointer"
                    >
                      {COUNTRY_CODES.map((item) => (
                        <option key={item.code} value={item.code}>
                          {item.flag} {item.code}
                        </option>
                      ))}
                    </select>
                  </div>

                  {/* Phone Input */}
                  <div className="relative flex-1">
                    <input
                      type="tel"
                      value={phoneNumber}
                      onChange={(e) => setPhoneNumber(e.target.value)}
                      placeholder="771234567"
                      className="w-full h-12 bg-slate-50 border border-slate-200 focus:border-[#0B2038] focus:bg-white rounded-xl px-3 text-sm font-semibold text-slate-900 tracking-wider focus:outline-none focus:ring-2 focus:ring-[#0B2038]/10 transition-all text-left"
                      required
                    />
                  </div>
                </div>
                <span className="block text-[11px] text-slate-400 mt-1.5 text-right">
                  مثال في اليمن: 77XXXXXXX أو 73XXXXXXX أو 71XXXXXXX
                </span>
              </div>

              <button
                type="submit"
                className="w-full h-12 rounded-xl bg-[#0B2038] hover:bg-slate-800 text-white font-bold font-cairo text-sm flex items-center justify-center gap-2 shadow-md shadow-[#0B2038]/15 active-press transition-all cursor-pointer"
              >
                <span>{activeTab === 'login' ? 'إرسال رمز الدخول' : 'المتابعة للتحقق'}</span>
                <ArrowRight size={16} className="rotate-180" />
              </button>
            </form>
          </div>
        )}

        {step === 'otp' && (
          <div>
            <div className="mb-5 text-center">
              <div className="w-12 h-12 rounded-2xl bg-amber-50 text-amber-600 flex items-center justify-center mx-auto mb-3">
                <ShieldCheck size={26} />
              </div>
              <h2 className="text-xl font-black font-cairo text-slate-900 mb-1">
                أدخل رمز التحقق
              </h2>
              <p className="text-xs text-slate-500">
                تم إرسال رمز التحقق المكون من 6 أرقام عبر رسالة SMS إلى:
              </p>
              <div className="mt-1 font-bold text-slate-800 text-sm dir-ltr">
                {selectedCountryCode} {phoneNumber}
              </div>
            </div>

            {/* 6 Digit OTP inputs */}
            <div className="flex items-center justify-between gap-1.5 mb-6" dir="ltr">
              {otp.map((digit, index) => (
                <input
                  key={index}
                  ref={(el) => {
                    otpInputRefs.current[index] = el;
                  }}
                  type="text"
                  inputMode="numeric"
                  maxLength={1}
                  value={digit}
                  onChange={(e) => handleOtpChange(index, e.target.value)}
                  onKeyDown={(e) => handleKeyDown(index, e)}
                  onPaste={index === 0 ? handleOtpPaste : undefined}
                  className="w-11 h-13 text-center text-lg font-bold font-cairo bg-slate-50 border border-slate-200 focus:border-amber-500 focus:bg-white rounded-xl focus:outline-none focus:ring-2 focus:ring-amber-500/20 text-slate-900 transition-all"
                />
              ))}
            </div>

            <button
              type="button"
              onClick={handleVerifyOtp}
              className="w-full h-12 rounded-xl bg-[#0B2038] hover:bg-slate-800 text-white font-bold font-cairo text-sm flex items-center justify-center gap-2 shadow-md shadow-[#0B2038]/15 active-press transition-all cursor-pointer mb-4"
            >
              <span>تأكيد الرمز والدخول</span>
              <CheckCircle2 size={16} />
            </button>

            {/* Countdown & Resend */}
            <div className="text-center text-xs text-slate-500">
              {timer > 0 ? (
                <p>
                  إعادة إرسال الرمز خلال{' '}
                  <span className="font-bold text-amber-600 font-cairo">{timer} ثانية</span>
                </p>
              ) : (
                <button
                  type="button"
                  onClick={handleResendOtp}
                  className="font-bold text-[#0B2038] hover:underline"
                >
                  إعادة إرسال رمز جديد الآن
                </button>
              )}
            </div>
          </div>
        )}

        {step === 'profile_completion' && (
          <div>
            <div className="mb-5">
              <h2 className="text-xl font-black font-cairo text-slate-900 mb-1">
                إكمال بيانات حسابك ✨
              </h2>
              <p className="text-xs text-slate-500">
                خطوة أخيرة لتجهيز حسابك وبدء استلام شحناتك في اليمن.
              </p>
            </div>

            <div className="space-y-4">
              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">
                  الاسم الكامل
                </label>
                <div className="relative">
                  <input
                    type="text"
                    value={fullName}
                    onChange={(e) => setFullName(e.target.value)}
                    placeholder="مثال: مختار غالب الزبيري"
                    className="w-full h-11 bg-slate-50 border border-slate-200 focus:border-[#0B2038] focus:bg-white rounded-xl px-3 text-xs font-semibold text-slate-900 focus:outline-none focus:ring-2 focus:ring-[#0B2038]/10"
                    required
                  />
                  <User size={16} className="absolute left-3 top-3 text-slate-400" />
                </div>
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">
                  المدينة الرئيسية في اليمن
                </label>
                <div className="relative">
                  <select
                    value={city}
                    onChange={(e) => setCity(e.target.value)}
                    className="w-full h-11 bg-slate-50 border border-slate-200 focus:border-[#0B2038] focus:bg-white rounded-xl px-3 text-xs font-semibold text-slate-900 focus:outline-none focus:ring-2 focus:ring-[#0B2038]/10 cursor-pointer"
                  >
                    {YEMEN_CITIES.map((c) => (
                      <option key={c} value={c}>
                        {c}
                      </option>
                    ))}
                  </select>
                  <MapPin size={16} className="absolute left-3 top-3 text-slate-400 pointer-events-none" />
                </div>
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1.5">الجنس</label>
                <div className="grid grid-cols-2 gap-2">
                  <button
                    type="button"
                    onClick={() => setGender('male')}
                    className={`py-2 rounded-xl text-xs font-bold border transition-all ${
                      gender === 'male'
                        ? 'border-[#0B2038] bg-[#0B2038]/5 text-[#0B2038]'
                        : 'border-slate-200 text-slate-600'
                    }`}
                  >
                    ذكر
                  </button>
                  <button
                    type="button"
                    onClick={() => setGender('female')}
                    className={`py-2 rounded-xl text-xs font-bold border transition-all ${
                      gender === 'female'
                        ? 'border-[#0B2038] bg-[#0B2038]/5 text-[#0B2038]'
                        : 'border-slate-200 text-slate-600'
                    }`}
                  >
                    أنثى
                  </button>
                </div>
              </div>

              <button
                type="button"
                onClick={handleCompleteRegistration}
                className="w-full h-12 rounded-xl bg-amber-500 hover:bg-amber-600 text-white font-bold font-cairo text-sm flex items-center justify-center gap-2 shadow-md shadow-amber-500/20 active-press transition-all cursor-pointer mt-4"
              >
                <span>بدء التسوق مع برهان</span>
                <CheckCircle2 size={16} />
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Footer Trust Guarantee */}
      <div className="w-full max-w-md mx-auto text-center pt-4">
        <p className="text-[11px] text-slate-500 flex items-center justify-center gap-1.5">
          <ShieldCheck size={14} className="text-emerald-600" />
          <span>بياناتك ومعاملاتك المالية محمية ومشفرة بمعايير أمان عالية</span>
        </p>
      </div>
    </div>
  );
};
