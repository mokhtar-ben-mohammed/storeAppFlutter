import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:store/app/router/app_routes.dart';
import 'package:store/core/theme/burhan_colors.dart';
import 'package:store/core/theme/burhan_typography.dart';
import 'package:store/core/widgets/store_badge.dart';
import 'package:store/features/orders/domain/entities/order_entity.dart';
import 'package:store/features/orders/presentation/data/mock_orders_data.dart';
import 'package:store/features/orders/presentation/pages/order_details_page.dart';

/// Orders history and shipment tracking screen matching OrdersScreen.tsx.
class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late List<OrderEntity> _orders;
  String _selectedStatusTab = 'all';

  @override
  void initState() {
    super.initState();
    _orders = MockOrdersData.initialOrders;
  }

  List<OrderEntity> get _filteredOrders {
    return _orders.where((order) {
      if (_selectedStatusTab == 'all') return true;
      if (_selectedStatusTab == 'processing') {
        return order.status == OrderStatus.pendingPayment ||
            order.status == OrderStatus.processing;
      }
      if (_selectedStatusTab == 'purchased') {
        return order.status == OrderStatus.purchased ||
            order.status == OrderStatus.receivedChina;
      }
      if (_selectedStatusTab == 'shipped_intl') {
        return order.status == OrderStatus.shippedIntl ||
            order.status == OrderStatus.customsLocal ||
            order.status == OrderStatus.outForDelivery;
      }
      if (_selectedStatusTab == 'delivered') {
        return order.status == OrderStatus.delivered;
      }
      return true;
    }).toList();
  }

  String _formatPrice(double amount) {
    return amount.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    final (label, icon, color, bg) = switch (status) {
      OrderStatus.pendingPayment || OrderStatus.processing => (
          'قيد المراجعة والشراء',
          Icons.access_time_rounded,
          BurhanColors.amber,
          BurhanColors.amber.withValues(alpha: 0.1),
        ),
      OrderStatus.purchased => (
          'تم الشراء من المصنع',
          Icons.storefront_rounded,
          const Color(0xFF2563EB),
          const Color(0xFFEFF6FF),
        ),
      OrderStatus.receivedChina => (
          'تم الفحص بمستودع الصين',
          Icons.inventory_2_rounded,
          const Color(0xFF7C3AED),
          const Color(0xFFF5F3FF),
        ),
      OrderStatus.shippedIntl => (
          'غادرت جوياً إلى اليمن',
          Icons.flight_takeoff_rounded,
          const Color(0xFF0284C7),
          const Color(0xFFF0F9FF),
        ),
      OrderStatus.customsLocal || OrderStatus.outForDelivery => (
          'في التوصيل المحلي',
          Icons.local_shipping_rounded,
          const Color(0xFF4F46E5),
          const Color(0xFFEEF2FF),
        ),
      OrderStatus.delivered => (
          'تم التسليم للعميل',
          Icons.check_circle_rounded,
          BurhanColors.emerald500,
          BurhanColors.emerald50,
        ),
      OrderStatus.cancelled => (
          'ملغي',
          Icons.cancel_rounded,
          BurhanColors.rose500,
          BurhanColors.rose500.withValues(alpha: 0.1),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _openOrderDetails(OrderEntity order) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OrderDetailsPage(order: order),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredOrders;

    final tabs = [
      {'id': 'all', 'label': 'الكل'},
      {'id': 'processing', 'label': 'قيد المعالجة'},
      {'id': 'purchased', 'label': 'تم الشراء'},
      {'id': 'shipped_intl', 'label': 'قيد الشحن'},
      {'id': 'delivered', 'label': 'تم التسليم'},
    ];

    return Scaffold(
      backgroundColor: BurhanColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Page Header Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سجل طلباتي وتتبع الشحنات',
                      style: BurhanTypography.titleMedium.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'تابع مسار مشترياتك خطوة بخطوة من مستودعات الصين حتى اليمن',
                      style: BurhanTypography.caption.copyWith(
                        fontSize: 11.5,
                        color: BurhanColors.slate500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Horizontal Status Filter Tabs
            SliverToBoxAdapter(
              child: SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: tabs.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final tab = tabs[index];
                    final isSelected = _selectedStatusTab == tab['id'];

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedStatusTab = tab['id']!;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? BurhanColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? BurhanColors.primary : BurhanColors.slate200,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: BurhanColors.primary.withValues(alpha: 0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          tab['label']!,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.5,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: isSelected ? Colors.white : BurhanColors.slate700,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),

            // 3. Orders List or Empty State
            if (filtered.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: BurhanColors.slate100,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            size: 38,
                            color: BurhanColors.slate400,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد طلبات في هذا القسم',
                          style: BurhanTypography.titleSmall.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'عندما تقوم بإنشاء طلبات شراء جديدة من 1688 أو Taobao، ستظهر تفاصيلها وحالات شحنها هنا فوراً.',
                          textAlign: TextAlign.center,
                          style: BurhanTypography.caption.copyWith(
                            fontSize: 12,
                            color: BurhanColors.slate500,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton(
                          onPressed: () {
                            context.go(AppRoutes.home);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: BurhanColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                            elevation: 0,
                          ),
                          child: Text(
                            'تصفح المنتجات وأنشئ أول طلب',
                            style: BurhanTypography.buttonSmall.copyWith(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 80),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final order = filtered[index];
                      return _buildOrderCard(order);
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static const _arMonths = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
  ];

  String _formatDate(DateTime d) => '${d.day} ${_arMonths[d.month - 1]}';

  Widget _buildOrderCard(OrderEntity order) {
    final formattedDate = _formatDate(order.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BurhanColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openOrderDetails(order),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Order number and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderNumber,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: BurhanColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'بتاريخ: $formattedDate',
                        style: BurhanTypography.caption.copyWith(
                          fontSize: 10,
                          color: BurhanColors.slate400,
                        ),
                      ),
                    ],
                  ),
                  _buildStatusBadge(order.status),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: BurhanColors.slate100),
              const SizedBox(height: 10),

              // Product Thumbnails Carousel
              Row(
                children: [
                  ...order.items.take(3).map((item) {
                    return Container(
                      margin: const EdgeInsets.only(left: 8),
                      width: 52,
                      height: 52,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: item.product.images.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: item.product.images.first,
                                    fit: BoxFit.cover,
                                    width: 52,
                                    height: 52,
                                  )
                                : Container(color: BurhanColors.slate100),
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: StoreBadge(
                              store: item.product.store,
                              size: StoreBadgeSize.sm,
                              showChineseLabel: false,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (order.items.length > 3)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: BurhanColors.slate100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+${order.items.length - 3} منتج إضافي',
                        style: BurhanTypography.caption.copyWith(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: BurhanColors.slate600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: BurhanColors.slate100),
              const SizedBox(height: 10),

              // Bottom Row: Total & Action CTA
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الإجمالي:',
                        style: BurhanTypography.caption.copyWith(
                          fontSize: 10,
                          color: BurhanColors.slate400,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            _formatPrice(order.breakdown.grandTotalYer),
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                              color: BurhanColors.primary,
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Text(
                            'ر.ي',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: BurhanColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'عرض التفاصيل والتتبع',
                        style: BurhanTypography.caption.copyWith(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: BurhanColors.amber,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 11,
                        color: BurhanColors.amber,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
