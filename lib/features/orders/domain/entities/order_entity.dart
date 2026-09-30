import 'package:equatable/equatable.dart';
import 'package:store/features/cart/domain/entities/cart_item_entity.dart';

enum OrderStatus {
  pendingPayment('pending_payment', 'قيد المراجعة والشراء'),
  processing('processing', 'قيد المعالجة'),
  purchased('purchased', 'تم الشراء من المصنع'),
  receivedChina('received_china', 'تم الفحص بمستودع الصين'),
  shippedIntl('shipped_intl', 'غادرت جوياً إلى اليمن'),
  customsLocal('customs_local', 'في التخليص الجمركي'),
  outForDelivery('out_for_delivery', 'في التوصيل المحلي'),
  delivered('delivered', 'تم التسليم للعميل'),
  cancelled('cancelled', 'ملغي');

  const OrderStatus(this.code, this.label);
  final String code;
  final String label;

  static OrderStatus fromCode(String code) {
    return OrderStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => OrderStatus.processing,
    );
  }
}

class OrderTimelineStep extends Equatable {
  const OrderTimelineStep({
    required this.status,
    required this.title,
    required this.description,
    this.time,
    this.location,
    this.completed = false,
    this.current = false,
  });

  final OrderStatus status;
  final String title;
  final String description;
  final String? time;
  final String? location;
  final bool completed;
  final bool current;

  OrderTimelineStep copyWith({
    OrderStatus? status,
    String? title,
    String? description,
    String? time,
    String? location,
    bool? completed,
    bool? current,
  }) {
    return OrderTimelineStep(
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      location: location ?? this.location,
      completed: completed ?? this.completed,
      current: current ?? this.current,
    );
  }

  @override
  List<Object?> get props => [status, title, description, time, location, completed, current];
}

class OrderBreakdown extends Equatable {
  const OrderBreakdown({
    required this.itemsOriginalCny,
    required this.itemsConvertedYer,
    required this.burhanFeeYer,
    required this.shippingCostYer,
    required this.taxAndCustomsYer,
    required this.grandTotalYer,
  });

  final double itemsOriginalCny;
  final double itemsConvertedYer;
  final double burhanFeeYer;
  final double shippingCostYer;
  final double taxAndCustomsYer;
  final double grandTotalYer;

  @override
  List<Object?> get props => [
        itemsOriginalCny,
        itemsConvertedYer,
        burhanFeeYer,
        shippingCostYer,
        taxAndCustomsYer,
        grandTotalYer,
      ];
}

class OrderEntity extends Equatable {
  const OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.createdAt,
    required this.status,
    required this.items,
    required this.shippingMethodName,
    required this.paymentMethodName,
    required this.recipientName,
    required this.recipientPhone,
    required this.recipientAddress,
    required this.breakdown,
    this.trackingCode,
    this.chinaWarehouseNotes,
    required this.timeline,
  });

  final String id;
  final String orderNumber;
  final DateTime createdAt;
  final OrderStatus status;
  final List<CartItemEntity> items;
  final String shippingMethodName;
  final String paymentMethodName;
  final String recipientName;
  final String recipientPhone;
  final String recipientAddress;
  final OrderBreakdown breakdown;
  final String? trackingCode;
  final String? chinaWarehouseNotes;
  final List<OrderTimelineStep> timeline;

  OrderEntity copyWith({
    String? id,
    String? orderNumber,
    DateTime? createdAt,
    OrderStatus? status,
    List<CartItemEntity>? items,
    String? shippingMethodName,
    String? paymentMethodName,
    String? recipientName,
    String? recipientPhone,
    String? recipientAddress,
    OrderBreakdown? breakdown,
    String? trackingCode,
    String? chinaWarehouseNotes,
    List<OrderTimelineStep>? timeline,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      items: items ?? this.items,
      shippingMethodName: shippingMethodName ?? this.shippingMethodName,
      paymentMethodName: paymentMethodName ?? this.paymentMethodName,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      recipientAddress: recipientAddress ?? this.recipientAddress,
      breakdown: breakdown ?? this.breakdown,
      trackingCode: trackingCode ?? this.trackingCode,
      chinaWarehouseNotes: chinaWarehouseNotes ?? this.chinaWarehouseNotes,
      timeline: timeline ?? this.timeline,
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        createdAt,
        status,
        items,
        shippingMethodName,
        paymentMethodName,
        recipientName,
        recipientPhone,
        recipientAddress,
        breakdown,
        trackingCode,
        chinaWarehouseNotes,
        timeline,
      ];
}
