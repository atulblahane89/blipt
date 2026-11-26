import 'inventory_item.dart';

enum OrderStatus {
  placed,
  packing,
  outForDelivery,
  delivered,
  disputed,
  refunded,
}

class OrderItem {
  final InventoryItem item;
  final int quantity;

  OrderItem({required this.item, required this.quantity});

  double get total => item.price * quantity;
}

class BliptoOrder {
  final String id;
  final String consumerId;
  final String storeId;
  final String storeName;
  final String? fulfillingStoreId;
  final String? fulfillingStoreName;
  final bool isSpillover;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double totalAmount;
  final String deliveryOtp;
  final DateTime createdAt;
  OrderStatus status;
  String? deliveryProofPhoto;
  String? customerAddress;

  BliptoOrder({
    required this.id,
    required this.consumerId,
    required this.storeId,
    required this.storeName,
    this.fulfillingStoreId,
    this.fulfillingStoreName,
    this.isSpillover = false,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.totalAmount,
    required this.deliveryOtp,
    required this.createdAt,
    this.status = OrderStatus.placed,
    this.deliveryProofPhoto,
    this.customerAddress = "Flat 402, Green Glen Layout, Bellandur (450m away)",
  });

  String get statusDisplay {
    switch (status) {
      case OrderStatus.placed:
        return "Order Received at Store";
      case OrderStatus.packing:
        return "Being Packed by Merchant";
      case OrderStatus.outForDelivery:
        return "Out for Delivery (Staff en route)";
      case OrderStatus.delivered:
        return "Delivered via Doorstep Verification";
      case OrderStatus.disputed:
        return "Dispute Under Review";
      case OrderStatus.refunded:
        return "Instant Escrow Refund Processed";
    }
  }
}
