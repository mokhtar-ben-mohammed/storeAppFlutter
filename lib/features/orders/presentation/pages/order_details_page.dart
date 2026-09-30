import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:store/core/theme/burhan_colors.dart';
import 'package:store/core/theme/burhan_typography.dart';
import 'package:store/core/widgets/store_badge.dart';
import 'package:store/features/orders/domain/entities/order_entity.dart';

/// Detailed order tracking and logistics breakdown screen matching OrderDetailsScreen.tsx.
class OrderDetailsPage extends StatefulWidget {
  const OrderDetailsPage({
    super.key,
    required this.order,
  });

  final OrderEntity order;

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late OrderEntity _currentOrder;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم نسخ $label: $text',
          style: BurhanTypography.bodySmall.copyWith(color: Colors.white),
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: BurhanColors.slate900,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _advanceOrderSimulation() {
    final statuses = [
      OrderStatus.pendingPayment,
      OrderStatus.purchased,
      OrderStatus.receivedChina,
      OrderStatus.shippedIntl,
      OrderStatus.customsLocal,
      OrderStatus.outForDelivery,
      OrderStatus.delivered,
    ];

    final currentIndex = statuses.indexOf(_currentOrder.status);
    if (currentIndex == -1 || currentIndex >= statuses.length - 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('وصلت الشحنة بالفعل إلى المحطة النهائية (تم التسليم)'),
          duration: Duration(seconds: 1),
          backgroundColor: BurhanColors.slate900,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final nextStatus = statuses[currentIndex + 1];

    setState(() {
      final updatedTimeline = _currentOrder.timeline.map((step) {
        final stepIndex = statuses.indexOf(step.status);
        if (stepIndex < currentIndex + 1) {
          return step.copyWith(completed: true, current: false);
        } else if (stepIndex == currentIndex + 1) {
          return step.copyWith(completed: true, current: true, time: 'الآن');
        } else {
          return step.copyWith(completed: false, current: false);
        }
      }).toList();

      _currentOrder = _currentOrder.copyWith(
        status: nextStatus,
        timeline: updatedTimeline,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم تحديث مسار الشحنة إلى: ${nextStatus.label}',
          style: BurhanTypography.bodySmall.copyWith(color: Colors.white),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: BurhanColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
          'في التوصيل والتخليص',
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = _currentOrder;

    return Scaffold(
      backgroundColor: BurhanColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: BurhanColors.slate900,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        title: Text(
          'تتبع الطلب ${order.orderNumber}',
          style: BurhanTypography.titleSmall.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Simulation Banner for Reviewers
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    BurhanColors.amber.withValues(alpha: 0.15),
                    BurhanColors.amber.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: BurhanColors.amber.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: BurhanColors.amber, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'أداة محاكاة تتبع الشحنة الحية',
                          style: BurhanTypography.titleSmall.copyWith(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'اضغط لتقديم حالة الشحنة خطوة وتحديث المسار التفاعلي!',
                          style: BurhanTypography.caption.copyWith(
                            fontSize: 10.5,
                            color: BurhanColors.slate600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _advanceOrderSimulation,
                    icon: const Icon(Icons.play_arrow_rounded, size: 14, color: Colors.white),
                    label: const Text(
                      'قدم خطوة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BurhanColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 2. Status Overview Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: BurhanColors.slate200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'رقم التتبع الدولي',
                            style: BurhanTypography.caption.copyWith(
                              fontSize: 10.5,
                              color: BurhanColors.slate400,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                order.trackingCode ?? 'قيد الإصدار بالمستودع',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: BurhanColors.primary,
                                ),
                              ),
                              if (order.trackingCode != null) ...[
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: () => _copyToClipboard(order.trackingCode!, 'رقم التتبع'),
                                  child: const Icon(Icons.copy_rounded, size: 14, color: BurhanColors.slate400),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      _buildStatusBadge(order.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: BurhanColors.slate100),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'طريقة الشحن: ${order.shippingMethodName}',
                        style: BurhanTypography.caption.copyWith(
                          fontSize: 11,
                          color: BurhanColors.slate600,
                        ),
                      ),
                      Text(
                        'الدفع: ${order.paymentMethodName}',
                        style: BurhanTypography.caption.copyWith(
                          fontSize: 11,
                          color: BurhanColors.slate600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3. Logistics Interactive Timeline
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: BurhanColors.slate200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timeline_rounded, color: BurhanColors.primary, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'مسار الشحنة خطوة بخطوة',
                        style: BurhanTypography.titleSmall.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: order.timeline.length,
                    itemBuilder: (context, index) {
                      final step = order.timeline[index];
                      final isLast = index == order.timeline.length - 1;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left indicator and connecting line
                          Column(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: step.current
                                      ? BurhanColors.amber
                                      : (step.completed
                                          ? BurhanColors.emerald500
                                          : BurhanColors.slate200),
                                  boxShadow: step.current
                                      ? [
                                          BoxShadow(
                                            color: BurhanColors.amber.withValues(alpha: 0.4),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Icon(
                                  step.completed
                                      ? Icons.check_rounded
                                      : (step.current
                                          ? Icons.radio_button_checked_rounded
                                          : Icons.circle_outlined),
                                  size: 14,
                                  color: (step.completed || step.current)
                                      ? Colors.white
                                      : BurhanColors.slate400,
                                ),
                              ),
                              if (!isLast)
                                Container(
                                  width: 2,
                                  height: 48,
                                  color: step.completed
                                      ? BurhanColors.emerald500.withValues(alpha: 0.5)
                                      : BurhanColors.slate200,
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),

                          // Step details
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        step.title,
                                        style: BurhanTypography.titleSmall.copyWith(
                                          fontSize: 12,
                                          fontWeight: step.current
                                              ? FontWeight.w900
                                              : (step.completed
                                                  ? FontWeight.w700
                                                  : FontWeight.w500),
                                          color: step.current
                                              ? BurhanColors.primary
                                              : (step.completed
                                                  ? BurhanColors.slate900
                                                  : BurhanColors.slate400),
                                        ),
                                      ),
                                      if (step.time != null)
                                        Text(
                                          step.time!,
                                          style: BurhanTypography.caption.copyWith(
                                            fontSize: 10,
                                            color: step.current
                                                ? BurhanColors.amber
                                                : BurhanColors.slate400,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    step.description,
                                    style: BurhanTypography.caption.copyWith(
                                      fontSize: 11,
                                      color: BurhanColors.slate500,
                                      height: 1.35,
                                    ),
                                  ),
                                  if (step.location != null) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.location_on_outlined,
                                            size: 11, color: BurhanColors.slate400),
                                        const SizedBox(width: 2),
                                        Text(
                                          step.location!,
                                          style: BurhanTypography.caption.copyWith(
                                            fontSize: 9.5,
                                            color: BurhanColors.slate400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 4. China Warehouse Inspection Report Card
            if (order.chinaWarehouseNotes != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF8EE),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: BurhanColors.amber.withValues(alpha: 0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified_rounded, color: BurhanColors.amber, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'تقرير فحص مستودع قوانغتشو - الصين',
                          style: BurhanTypography.titleSmall.copyWith(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF78350F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      order.chinaWarehouseNotes!,
                      style: BurhanTypography.bodySmall.copyWith(
                        fontSize: 11.5,
                        color: const Color(0xFF92400E),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // 5. Ordered Products List
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: BurhanColors.slate200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المنتجات المشمولة في الطلب (${order.items.length})',
                    style: BurhanTypography.titleSmall.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...order.items.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: BurhanColors.slate50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: BurhanColors.slate100),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 58,
                              height: 58,
                              child: item.product.images.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: item.product.images.first,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(color: BurhanColors.slate200),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    StoreBadge(store: item.product.store, size: StoreBadgeSize.sm),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        item.product.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: BurhanTypography.titleSmall.copyWith(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'المتغير: ${item.selectedVariant.name} · الكمية: ${item.quantity}',
                                      style: BurhanTypography.caption.copyWith(
                                        fontSize: 10.5,
                                        color: BurhanColors.slate500,
                                      ),
                                    ),
                                    Text(
                                      '${_formatPrice(item.totalPriceYer)} ر.ي',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: BurhanColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 6. Delivery Address Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: BurhanColors.slate200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: BurhanColors.primary, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'عنوان التوصيل في اليمن',
                        style: BurhanTypography.titleSmall.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    order.recipientName,
                    style: BurhanTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w800,
                      color: BurhanColors.slate900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    order.recipientPhone,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: BurhanColors.slate600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.recipientAddress,
                    style: BurhanTypography.caption.copyWith(
                      fontSize: 11.5,
                      color: BurhanColors.slate600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 7. Financial Invoice Breakdown Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: BurhanColors.slate200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تفاصيل الفاتورة والتكلفة',
                    style: BurhanTypography.titleSmall.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildCostRow('قيمة المنتجات بالصين (¥${order.breakdown.itemsOriginalCny.toInt()})',
                      '${_formatPrice(order.breakdown.itemsConvertedYer)} ر.ي'),
                  _buildCostRow('عمولة فحص وشراء برهان', '${_formatPrice(order.breakdown.burhanFeeYer)} ر.ي'),
                  _buildCostRow('تكلفة الشحن الدولي المباشر', '${_formatPrice(order.breakdown.shippingCostYer)} ر.ي'),
                  _buildCostRow('التخليص والجمارك', '${_formatPrice(order.breakdown.taxAndCustomsYer)} ر.ي'),
                  const Divider(height: 20, color: BurhanColors.slate200),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الإجمالي النهائي المدفوع',
                        style: BurhanTypography.titleSmall.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: BurhanColors.primary,
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
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: BurhanColors.primary,
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Text(
                            'ر.ي',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: BurhanColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: BurhanTypography.caption.copyWith(
              fontSize: 11.5,
              color: BurhanColors.slate600,
            ),
          ),
          Text(
            value,
            style: BurhanTypography.caption.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: BurhanColors.slate800,
            ),
          ),
        ],
      ),
    );
  }
}
