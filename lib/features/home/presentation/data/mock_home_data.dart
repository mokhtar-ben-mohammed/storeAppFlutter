import 'package:store/features/products/domain/entities/product_entity.dart';

/// Authentic mock products ported from storeAppUI/src/data/mockData.ts.
class MockHomeData {
  MockHomeData._();

  static const List<ProductEntity> products = [
    ProductEntity(
      id: 'prod-1',
      title: 'ساعة ذكية Ultra 2 بهيكل تيتانيوم وشاشة AMOLED متطورة ومقاومة للماء',
      store: '1688',
      supplierName: 'Shenzhen MicroTech Electronic Factory',
      supplierRating: 4.9,
      originalPriceCny: 168,
      marketPriceCny: 280,
      rating: 4.8,
      salesCount: 4120,
      images: [
        'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1508685096489-7aacd43bd3b1?auto=format&fit=crop&w=800&q=80',
      ],
      category: 'electronics',
      description:
          'ساعة ذكية من أحدث إصدارات مصانع شنجن على 1688، تأتي بهيكل تيتانيوم صلب، بطارية تدوم حتى 7 أيام، ومستشعرات دقيقة.',
      isVerifiedSupplier: true,
    ),
    ProductEntity(
      id: 'prod-2',
      title: 'سماعات رأس لاسلكية استوديو Hi-Fi مع ميزة عزل الضوضاء النشط ANC مزدوج',
      store: 'taobao',
      supplierName: 'SoundWave Acoustic Lab (Taobao Gold)',
      supplierRating: 4.95,
      originalPriceCny: 245,
      marketPriceCny: 390,
      rating: 4.9,
      salesCount: 1840,
      images: [
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=800&q=80',
      ],
      category: 'electronics',
      description:
          'سماعات رأس فاخرة من تاوباو مخصصة لعشاق الصوت النقي، مزودة بمحركات تيتانيوم 40 مم مع عزل ضوضاء هجين.',
      isVerifiedSupplier: true,
    ),
    ProductEntity(
      id: 'prod-3',
      title: 'لوحة مفاتيح ميكانيكية مخصصة بنمط ريترو ووصلات ثلاثية وسويتشات خطية',
      store: 'aliexpress',
      supplierName: 'KeyCrafter Official Store',
      supplierRating: 4.8,
      originalPriceCny: 198,
      marketPriceCny: 320,
      rating: 4.7,
      salesCount: 3290,
      images: [
        'https://images.unsplash.com/photo-1587829741301-dc798b83add3?auto=format&fit=crop&w=800&q=80',
      ],
      category: 'electronics',
      description:
          'كيبورد ميكانيكي أنيق 75% مع أزرار PBT مزدوجة الصب بنمط ريترو كلاسيكي، مقبض تحكم بالصوت من الألمنيوم.',
      isVerifiedSupplier: true,
    ),
    ProductEntity(
      id: 'prod-4',
      title: 'حقيبة ساعي بريد جلدية عتيقة كلاسيكية صناعة يدوية (فحص ونظافة مضمونة)',
      store: 'goofish',
      supplierName: 'Vintage Leather Craftsman (Goofish Verified)',
      supplierRating: 4.88,
      originalPriceCny: 135,
      marketPriceCny: 260,
      rating: 4.85,
      salesCount: 740,
      images: [
        'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&w=800&q=80',
      ],
      category: 'fashion',
      description:
          'حقيبة يد وكتف جلدية مصنوعة يدوياً من مقتنيات جوفيش المختارة بعناية وفحص سلامة من فريق قوانغتشو.',
      isVerifiedSupplier: true,
    ),
  ];
}
