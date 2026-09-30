import 'package:store/features/cart/domain/entities/cart_item_entity.dart';
import 'package:store/features/orders/domain/entities/order_entity.dart';
import 'package:store/features/products/presentation/data/mock_products_data.dart';

/// Preloaded mock orders data matching storeAppUI/src/data/mockData.ts.
class MockOrdersData {
  MockOrdersData._();

  static List<OrderEntity> get initialOrders {
    final p1 = MockProductsData.getById('prod-1')!;
    final p5 = MockProductsData.getById('prod-5')!;
    final p6 = MockProductsData.getById('prod-6')!;

    return [
      OrderEntity(
        id: 'ord-8921',
        orderNumber: 'BRH-89214',
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        status: OrderStatus.shippedIntl,
        items: [
          CartItemEntity(
            id: 'ord-item-1',
            productId: p1.id,
            product: p1,
            selectedVariant: p1.variants.first,
            quantity: 1,
            isSelected: true,
            addedAt: DateTime.now().subtract(const Duration(days: 6)),
          ),
          CartItemEntity(
            id: 'ord-item-2',
            productId: p5.id,
            product: p5,
            selectedVariant: p5.variants.first,
            quantity: 1,
            isSelected: true,
            addedAt: DateTime.now().subtract(const Duration(days: 6)),
          ),
        ],
        shippingMethodName: 'شحن جوي سريع (برهان إكسبرس)',
        paymentMethodName: 'محفظة جوالي / كاش اليمن',
        recipientName: 'مختار غالب الزبيري',
        recipientPhone: '+967 771234567',
        recipientAddress: 'صنعاء، شارع حدة - حي السفارات، بجوار هايبر ماركت التوفير',
        breakdown: const OrderBreakdown(
          itemsOriginalCny: 226,
          itemsConvertedYer: 16950,
          burhanFeeYer: 1050,
          shippingCostYer: 7800,
          taxAndCustomsYer: 900,
          grandTotalYer: 26700,
        ),
        trackingCode: 'CN-YEM-8829104',
        chinaWarehouseNotes:
            'تم فحص الشاشة وحالة البطارية وملحقات العلبة، التغليف سليم 100% وخالٍ من الخدوش.',
        timeline: const [
          OrderTimelineStep(
            status: OrderStatus.pendingPayment,
            title: 'تم إنشاء الطلب واعتماد الدفع',
            description: 'استلم فريق برهان طلب الشراء وتم توثيق الحوالة البنكية',
            time: '24 سبتمبر، 02:30 م',
            location: 'صنعاء، اليمن',
            completed: true,
          ),
          OrderTimelineStep(
            status: OrderStatus.purchased,
            title: 'تم الشراء من متجر 1688 الصيني',
            description: 'قام وكيل الشراء في الصين بدفع المبلغ للمصنع الصيني',
            time: '25 سبتمبر، 10:15 ص',
            location: 'شنجن، الصين',
            completed: true,
          ),
          OrderTimelineStep(
            status: OrderStatus.receivedChina,
            title: 'الاستلام والفحص في مستودع قوانغتشو',
            description: 'وصل الطرد لمستودع برهان وتمت مطابقة المواصفات وتصوير المنتج',
            time: '27 سبتمبر، 04:45 م',
            location: 'مستودع برهان، قوانغتشو',
            completed: true,
          ),
          OrderTimelineStep(
            status: OrderStatus.shippedIntl,
            title: 'غادرت الشحنة جوياً إلى اليمن',
            description: 'تم إصدار بوليصة الشحن الدولي وهي على متن رحلة ترانزيت جوية',
            time: '28 سبتمبر، 11:20 م',
            location: 'مطار قوانغتشو الدولي',
            completed: true,
            current: true,
          ),
          OrderTimelineStep(
            status: OrderStatus.customsLocal,
            title: 'وصول الشحنة والتخليص الجمركي',
            description: 'معالجة الطرد في المركز اللوجستي المحلي في اليمن',
            time: 'متوقع خلال 48 ساعة',
            location: 'مركز فرز الطرود، صنعاء',
            completed: false,
          ),
          OrderTimelineStep(
            status: OrderStatus.outForDelivery,
            title: 'في الطريق للتسليم مع المندوب',
            description: 'سيصلك اتصال من مندوب التوصيل لتسليم الشحنة لعنوانك',
            time: 'متوقع قريباً',
            location: 'حدة، صنعاء',
            completed: false,
          ),
          OrderTimelineStep(
            status: OrderStatus.delivered,
            title: 'تم التسليم بنجاح',
            description: 'استلم العميل الشحنة وأكد إتمام الطلب وجودة المنتجات',
            time: 'قريباً',
            completed: false,
          ),
        ],
      ),
      OrderEntity(
        id: 'ord-7310',
        orderNumber: 'BRH-73109',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        status: OrderStatus.delivered,
        items: [
          CartItemEntity(
            id: 'ord-item-3',
            productId: p6.id,
            product: p6,
            selectedVariant: p6.variants.first,
            quantity: 1,
            isSelected: true,
            addedAt: DateTime.now().subtract(const Duration(days: 20)),
          ),
        ],
        shippingMethodName: 'شحن جوي اقتصادي موحد',
        paymentMethodName: 'حساب الكريمي مميز',
        recipientName: 'مختار غالب الزبيري',
        recipientPhone: '+967 771234567',
        recipientAddress: 'عدن، المعلا - الشارع الرئيسي، عمارة النورس',
        breakdown: const OrderBreakdown(
          itemsOriginalCny: 112,
          itemsConvertedYer: 8400,
          burhanFeeYer: 600,
          shippingCostYer: 4500,
          taxAndCustomsYer: 400,
          grandTotalYer: 13900,
        ),
        trackingCode: 'CN-YEM-7109234',
        chinaWarehouseNotes: 'المصباح يعمل بشكل ممتاز وتم اختبار الشاحن اللاسلكي بدقة.',
        timeline: const [
          OrderTimelineStep(
            status: OrderStatus.pendingPayment,
            title: 'تم إنشاء الطلب',
            description: 'تم توثيق الدفع بنجاح',
            time: '10 سبتمبر',
            completed: true,
          ),
          OrderTimelineStep(
            status: OrderStatus.purchased,
            title: 'تم الشراء من تاوباو',
            description: 'تم الدفع للبائع الصيني',
            time: '11 سبتمبر',
            completed: true,
          ),
          OrderTimelineStep(
            status: OrderStatus.receivedChina,
            title: 'فحص الجودة في الصين',
            description: 'اجتاز الفحص العيني بنجاح',
            time: '13 سبتمبر',
            completed: true,
          ),
          OrderTimelineStep(
            status: OrderStatus.shippedIntl,
            title: 'الشحن الجوي',
            description: 'غادرت رحلة الشحن الدولي',
            time: '15 سبتمبر',
            completed: true,
          ),
          OrderTimelineStep(
            status: OrderStatus.delivered,
            title: 'تم التسليم بنجاح للعميل',
            description: 'تم استلام الشحنة في عدن وتوقيع سند الاستلام',
            time: '20 سبتمبر، 05:10 م',
            completed: true,
            current: true,
          ),
        ],
      ),
      OrderEntity(
        id: 'ord-9041',
        orderNumber: 'BRH-90412',
        createdAt: DateTime.now().subtract(const Duration(hours: 14)),
        status: OrderStatus.processing,
        items: [
          CartItemEntity(
            id: 'ord-item-4',
            productId: p1.id,
            product: p1,
            selectedVariant: p1.variants[1],
            quantity: 3,
            isSelected: true,
            addedAt: DateTime.now().subtract(const Duration(hours: 14)),
          ),
        ],
        shippingMethodName: 'شحن جوي سريع (برهان إكسبرس)',
        paymentMethodName: 'محفظة جوالي / كاش اليمن',
        recipientName: 'مختار غالب الزبيري',
        recipientPhone: '+967 771234567',
        recipientAddress: 'صنعاء، شارع حدة - حي السفارات',
        breakdown: const OrderBreakdown(
          itemsOriginalCny: 504,
          itemsConvertedYer: 37800,
          burhanFeeYer: 2100,
          shippingCostYer: 7800,
          taxAndCustomsYer: 1500,
          grandTotalYer: 49200,
        ),
        trackingCode: null,
        chinaWarehouseNotes: null,
        timeline: const [
          OrderTimelineStep(
            status: OrderStatus.pendingPayment,
            title: 'تم إنشاء الطلب',
            description: 'بانتظار مراجعة وكيل الشراء في مكتب قوانغتشو',
            time: 'اليوم، 09:30 ص',
            location: 'صنعاء، اليمن',
            completed: true,
            current: true,
          ),
          OrderTimelineStep(
            status: OrderStatus.purchased,
            title: 'الشراء من المصنع الصيني',
            description: 'سيتم الدفع للمصنع على منصة 1688 خلال ساعات الدوام',
            time: 'متوقع اليوم',
            location: 'الصين',
            completed: false,
          ),
        ],
      ),
    ];
  }

  static OrderEntity? getById(String id) {
    try {
      return initialOrders.firstWhere((o) => o.id == id);
    } catch (_) {
      return initialOrders.first;
    }
  }
}
