import 'package:store/features/products/domain/entities/product_entity.dart';

/// Centralized mock data matching storeAppUI/src/data/mockData.ts.
class MockProductsData {
  MockProductsData._();

  static const List<ProductEntity> products = [
    ProductEntity(
      id: 'prod-1',
      title: 'ساعة ذكية Ultra 2 بهيكل تيتانيوم وشاشة AMOLED متطورة ومقاومة للماء',
      store: '1688',
      storeUrl: 'https://detail.1688.com/offer/7391823901.html',
      supplierName: 'Shenzhen MicroTech Electronic Factory',
      supplierRating: 4.9,
      originalPriceCny: 168,
      marketPriceCny: 280,
      rating: 4.8,
      salesCount: 4120,
      images: [
        'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1508685096489-7aacd43bd3b1?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1434494878577-86c23bcb06b9?auto=format&fit=crop&w=800&q=80',
      ],
      category: 'electronics',
      description:
          'ساعة ذكية من أحدث إصدارات مصانع شنجن على 1688، تأتي بهيكل تيتانيوم صلب، بطارية تدوم حتى 7 أيام، مستشعرات لقياس نبضات القلب والأكسجين، وتدعم شريحة الاتصال وإشعارات باللغة العربية.',
      variants: [
        ProductVariant(
          id: 'v1',
          name: 'تيتانيوم أسود مطفي + سوار بحري',
          colorHex: '#1e293b',
          inStock: true,
        ),
        ProductVariant(
          id: 'v2',
          name: 'تيتانيوم فضي نقي + سوار برتقالي رياضي',
          colorHex: '#ea580c',
          inStock: true,
        ),
        ProductVariant(
          id: 'v3',
          name: 'تيتانيوم طبيعي + سوار جلدي كلاسيك',
          colorHex: '#78350f',
          priceModifierCny: 15,
          inStock: true,
        ),
      ],
      wholesaleTiers: [
        WholesaleTier(minQty: 1, priceCny: 168),
        WholesaleTier(minQty: 5, priceCny: 155),
        WholesaleTier(minQty: 20, priceCny: 142),
      ],
      weightKg: 0.28,
      estimatedDeliveryDays: '8-14 يوم عمل',
      specs: [
        ProductSpec(label: 'الشاشة', value: '2.12 بوصة AMOLED بدقة 485x520'),
        ProductSpec(label: 'البطارية', value: '450mAh تدوم حتى 7 أيام'),
        ProductSpec(label: 'مقاومة الماء', value: 'معيار IP68 للغوص الخفيف'),
        ProductSpec(label: 'اللغات', value: 'تدعم العربية بالكامل بدون تقطيع'),
        ProductSpec(label: 'التوافق', value: 'Android و iOS'),
      ],
      isVerifiedSupplier: true,
      featured: true,
    ),
    ProductEntity(
      id: 'prod-2',
      title: 'سماعات رأس لاسلكية استوديو Hi-Fi مع ميزة عزل الضوضاء النشط ANC مزدوج',
      store: 'taobao',
      storeUrl: 'https://item.taobao.com/item.htm?id=6928172918',
      supplierName: 'SoundWave Acoustic Lab (Taobao Gold)',
      supplierRating: 4.95,
      originalPriceCny: 245,
      marketPriceCny: 390,
      rating: 4.9,
      salesCount: 1840,
      images: [
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1484704849700-f032a568e944?auto=format&fit=crop&w=800&q=80',
      ],
      category: 'electronics',
      description:
          'سماعات رأس فاخرة من تاوباو مخصصة لعشاق الصوت النقي، مزودة بمحركات تيتانيوم 40 مم مع عزل ضوضاء هجين حتى 42dB، وبطارية خارقة تصل إلى 65 ساعة استماع متواصل.',
      variants: [
        ProductVariant(
          id: 'v2-1',
          name: 'أزرق كحلي ملكي ولمسات ذهبية',
          colorHex: '#0f294a',
          inStock: true,
        ),
        ProductVariant(
          id: 'v2-2',
          name: 'أبيض عاجي فاخر',
          colorHex: '#f8fafc',
          inStock: true,
        ),
        ProductVariant(
          id: 'v2-3',
          name: 'رمادي حجري مطفي',
          colorHex: '#475569',
          inStock: true,
        ),
      ],
      wholesaleTiers: [
        WholesaleTier(minQty: 1, priceCny: 245),
        WholesaleTier(minQty: 3, priceCny: 230),
      ],
      weightKg: 0.45,
      estimatedDeliveryDays: '7-12 يوم عمل',
      specs: [
        ProductSpec(label: 'استجابة التردد', value: '20Hz - 40,000Hz (Hi-Res Audio)'),
        ProductSpec(label: 'البلوتوث', value: 'Bluetooth 5.3 + دعم LDAC'),
        ProductSpec(label: 'عزل الضوضاء', value: 'عزل نشط هجين -42dB'),
        ProductSpec(label: 'منفذ الشحن', value: 'Type-C شحن سريع (10 دقائق = 5 ساعات)'),
      ],
      isVerifiedSupplier: true,
      featured: true,
    ),
    ProductEntity(
      id: 'prod-3',
      title: 'لوحة مفاتيح ميكانيكية مخصصة بنمط ريترو ووصلات ثلاثية وسويتشات خطية',
      store: 'aliexpress',
      storeUrl: 'https://aliexpress.com/item/1005006281928.html',
      supplierName: 'KeyCrafter Official Store',
      supplierRating: 4.8,
      originalPriceCny: 198,
      marketPriceCny: 320,
      rating: 4.7,
      salesCount: 3290,
      images: [
        'https://images.unsplash.com/photo-1587829741301-dc798b83add3?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1618384887929-16ec33fab9ef?auto=format&fit=crop&w=800&q=80',
      ],
      category: 'electronics',
      description:
          'كيبورد ميكانيكي أنيق 75% مع أزرار PBT مزدوجة الصب بنمط ريترو كلاسيكي، مقبض تحكم بالصوت من الألمنيوم، اتصال ثلاثي (2.4G + بلوتوث + سلكي Type-C)، وحشوات إسفنجية لتجربة نقر هادئة ورخامية.',
      variants: [
        ProductVariant(
          id: 'v3-1',
          name: 'سويتش أصفر خطي ناعم (صوت رخامي)',
          colorHex: '#eab308',
          inStock: true,
        ),
        ProductVariant(
          id: 'v3-2',
          name: 'سويتش بني تكتيكي (نقرة واضحة)',
          colorHex: '#78350f',
          inStock: true,
        ),
      ],
      weightKg: 0.85,
      estimatedDeliveryDays: '9-15 يوم عمل',
      specs: [
        ProductSpec(label: 'التصميم', value: 'حجم مدمج 75% مع 82 مفتاح + مقبض دوار'),
        ProductSpec(label: 'الأزرار', value: 'PBT Double-Shot مضادة للتآكل'),
        ProductSpec(label: 'الإضاءة', value: 'RGB جنوبية مع 22 نمط إضاءة'),
        ProductSpec(label: 'البطارية', value: '4000mAh تدوم أسبوعين'),
      ],
      isVerifiedSupplier: true,
      featured: true,
    ),
    ProductEntity(
      id: 'prod-4',
      title: 'حقيبة ساعي بريد جلدية عتيقة كلاسيكية صناعة يدوية (فحص ونظافة مضمونة)',
      store: 'goofish',
      storeUrl: 'https://2.taobao.com/item.htm?id=goofish9281723',
      supplierName: 'VintageCollector_Guangzhou (بائع موثوق تقييم 5 نجوم)',
      supplierRating: 5.0,
      originalPriceCny: 155,
      marketPriceCny: 340,
      rating: 4.9,
      salesCount: 42,
      images: [
        'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&w=800&q=80',
      ],
      category: 'fashion',
      description:
          'قطعة مميزة من سوق جوفيش (سوق المستعمل والمقتنيات المضمونة). حقيبة جلد طبيعي مدبوغ نباتياً بنمط كلاسيكي إيطالي، فحصها فريق برهان في قوانغتشو والتأكد من خلوها من أي عيوب.',
      variants: [
        ProductVariant(
          id: 'v4-1',
          name: 'بني هافان عتيق (حالة ممتازة 98%)',
          colorHex: '#9a3412',
          inStock: true,
        ),
        ProductVariant(
          id: 'v4-2',
          name: 'أسود فحمي كلاسيك (حالة جديدة)',
          colorHex: '#18181b',
          inStock: true,
        ),
      ],
      weightKg: 0.65,
      estimatedDeliveryDays: '10-16 يوم عمل',
      specs: [
        ProductSpec(label: 'المادة', value: 'جلد بقري طبيعي 100% سماكة 2 مم'),
        ProductSpec(label: 'المقاس', value: '32 × 24 × 9 سم (تتسع لجهاز iPad 11 بوصة)'),
        ProductSpec(label: 'حالة المنتج', value: 'مستعمل بحالة استثنائية (مفحوص ومصور)'),
        ProductSpec(label: 'فحص برهان', value: 'يشمل فحص السحابات والجلد قبل الشحن'),
      ],
      isVerifiedSupplier: true,
      featured: false,
    ),
    ProductEntity(
      id: 'prod-5',
      title: 'طقم أدوات صيانة دقيقة وشاملة 128 في 1 للموبايلات والأجهزة الحساسة',
      store: '1688',
      storeUrl: 'https://detail.1688.com/offer/6192837192.html',
      supplierName: 'Yongkang Precision Hardware Tool Co.',
      supplierRating: 4.85,
      originalPriceCny: 58,
      marketPriceCny: 120,
      rating: 4.8,
      salesCount: 8900,
      images: [
        'https://images.unsplash.com/photo-1581783342308-f792dbdd27c5?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1530124566582-a618bc2615dc?auto=format&fit=crop&w=800&q=80',
      ],
      category: 'tools',
      description:
          'طقم مفكات احترافي من مصانع 1688 يضم 128 رأس مفك من فولاذ CR-V المعالج حرارياً، علبة مغناطيسية ذكية بضغطة زر واحدة، مناسب لصيانة الجوالات واللابتوبات والساعات والكاميرات.',
      variants: [
        ProductVariant(
          id: 'v5-1',
          name: 'علبة ألمنيوم رمادية متينة 128 قطعة',
          colorHex: '#475569',
          inStock: true,
        ),
        ProductVariant(
          id: 'v5-2',
          name: 'علبة بلاستيكية مقاومة للصدمات مع مقبض مطاطي',
          colorHex: '#0f172a',
          inStock: true,
        ),
      ],
      wholesaleTiers: [
        WholesaleTier(minQty: 1, priceCny: 58),
        WholesaleTier(minQty: 10, priceCny: 49),
        WholesaleTier(minQty: 50, priceCny: 42),
      ],
      weightKg: 0.52,
      estimatedDeliveryDays: '8-14 يوم عمل',
      specs: [
        ProductSpec(label: 'عدد القطع', value: '128 رأس مفك دقيق + ملقط + فتاحات'),
        ProductSpec(label: 'خامة الرؤوس', value: 'فولاذ CR-V عالي الصلابة 60HRC'),
        ProductSpec(label: 'المقبض', value: 'سبيكة ألمنيوم مع رأس كروي دوار 360°'),
      ],
      isVerifiedSupplier: true,
      featured: false,
    ),
    ProductEntity(
      id: 'prod-6',
      title: 'مصباح مكتبي ذكي محاكي لضوء الشمس مع شاحن لاسلكي سريع 15W مدمج',
      store: 'taobao',
      storeUrl: 'https://item.taobao.com/item.htm?id=7829103941',
      supplierName: 'Lumina Home Technology',
      supplierRating: 4.9,
      originalPriceCny: 112,
      marketPriceCny: 195,
      rating: 4.7,
      salesCount: 2150,
      images: [
        'https://images.unsplash.com/photo-1534353436294-0dbd4bdac845?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?auto=format&fit=crop&w=800&q=80',
      ],
      category: 'home',
      description:
          'مصباح مكتبي عصري من تاوباو بتصميم مينيماليست، يوفر إضاءة ناعمة خالية من الوميض لحماية العين أثناء القراءة والعمل، مع قاعدة شحن لاسلكي مدمجة للهاتف وساعة ذكية.',
      variants: [
        ProductVariant(
          id: 'v6-1',
          name: 'أبيض سيراميكي أنيق',
          colorHex: '#f1f5f9',
          inStock: true,
        ),
        ProductVariant(
          id: 'v6-2',
          name: 'أسود مطفي ميتاليك',
          colorHex: '#09090b',
          inStock: true,
        ),
      ],
      weightKg: 0.72,
      estimatedDeliveryDays: '7-12 يوم عمل',
      specs: [
        ProductSpec(label: 'درجة حرارة اللون', value: '2700K - 6500K (5 درجات إضاءة)'),
        ProductSpec(label: 'مؤشر تجسيد الألوان', value: 'Ra ≥ 95 (دقة ألوان سينمائية)'),
        ProductSpec(label: 'الشحن اللاسلكي', value: 'شحن سريع 15W يدعم معيار Qi'),
      ],
      isVerifiedSupplier: true,
      featured: false,
    ),
  ];

  static List<ProductEntity> getByStore(String storeId) {
    return products.where((p) => p.store.toLowerCase() == storeId.toLowerCase()).toList();
  }

  static ProductEntity? getById(String id) {
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (_) {
      return products.first;
    }
  }
}
