import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/store.dart';
import '../models/inventory_item.dart';
import '../models/order.dart';
import '../models/dispute.dart';
import '../models/subscription.dart';

enum AppRole {
  consumer,
  merchant,
  deliveryStaff,
}

class AppState extends ChangeNotifier {
  AppRole currentRole = AppRole.consumer;

  // Wallet Balance (Consumer)
  double consumerWalletBalance = 50.00;

  // Merchant Escrow & Settlement Ledger
  double merchantEscrowBalance = 0.00;
  double merchantSettledBalance = 3450.00;
  int merchantStrikeCount = 0;

  // Stores in Hyper-Local Catchment (500m - 2000m)
  List<Store> stores = [
    Store(
      id: "store-001",
      name: "Gupta Kirana & Provisions",
      address: "Cross Road 4, Bellandur (450m away)",
      latitude: 12.9352,
      longitude: 77.6245,
      distanceMeters: 450,
      deliveryRadiusMeters: 1500,
      isBusy: false,
      maxActiveOrders: 4,
      activeOrdersCount: 2,
      trustRating: 4.9,
      upiId: "gupta.kirana@oksbi",
      estimatedMinutes: 14,
      trustBadge: "Trusted Partner",
      onTimeRate: 99.2,
      lightningPacker: true,
    ),
    Store(
      id: "store-002",
      name: "Mahadev Daily Supermarket",
      address: "Main Market Road, Green Glen (850m away)",
      latitude: 12.9380,
      longitude: 77.6290,
      distanceMeters: 850,
      deliveryRadiusMeters: 1800,
      isBusy: false,
      maxActiveOrders: 5,
      activeOrdersCount: 1,
      trustRating: 4.8,
      upiId: "mahadev.retail@okaxis",
      estimatedMinutes: 18,
      trustBadge: "Supermarket",
      onTimeRate: 98.5,
      lightningPacker: false,
    ),
    Store(
      id: "store-003",
      name: "Sri Venkateshwara Fresh & Dairy",
      address: "Temple Arch, Sector 2 (1100m away)",
      latitude: 12.9310,
      longitude: 77.6210,
      distanceMeters: 1100,
      deliveryRadiusMeters: 2000,
      isBusy: true, // Currently in Busy Mode (Peak Rush)
      maxActiveOrders: 3,
      activeOrdersCount: 3,
      trustRating: 4.7,
      upiId: "venkateshwara@icici",
      estimatedMinutes: 25,
      trustBadge: "Fresh Specialist",
      onTimeRate: 97.0,
      lightningPacker: true,
    ),
  ];

  // Active Store Selected in Merchant Hub
  String activeMerchantStoreId = "store-001";

  // Catalog items keyed by storeId
  Map<String, List<InventoryItem>> storeInventories = {};

  // Active recurring morning essential subscriptions
  List<Subscription> subscriptions = [];

  // Shopping Cart: StoreId -> (ItemId -> Quantity)
  Map<String, int> cartItems = {};
  Map<String, String> cartItemStoreMap = {};
  String? activeCartStoreId;

  // Orders Feed
  List<BliptoOrder> orders = [];

  // Disputes Log
  List<Dispute> disputes = [];

  // Live order incoming alert flag (for Merchant Terminal)
  bool hasIncomingOrderAlert = false;
  String? lastAlertOrderId;

  AppState() {
    _initCatalog();
    _initSampleOrders();
  }

  void switchRole(AppRole role) {
    currentRole = role;
    notifyListeners();
  }

  void _initCatalog() {
    storeInventories["store-001"] = [
      InventoryItem(
        id: "item-101",
        storeId: "store-001",
        barcode: "8901030383821",
        title: "Amul Taaza Homogenised Toned Milk",
        category: "Dairy & Eggs",
        price: 32.0,
        stockQuantity: 18,
        iconEmoji: "🥛",
        unit: "500 ml pouch",
        expiryHoursRemaining: 18,
        isFragile: false,
      ),
      InventoryItem(
        id: "item-102",
        storeId: "store-001",
        barcode: "8901491101837",
        title: "Modern 100% Whole Wheat Bread",
        category: "Bakery",
        price: 45.0,
        stockQuantity: 2, // Low stock demo!
        iconEmoji: "🍞",
        unit: "400g pack",
        expiryHoursRemaining: 12,
        isFragile: true,
      ),
      InventoryItem(
        id: "item-103",
        storeId: "store-001",
        barcode: "8901725181222",
        title: "Farm Fresh Farm Brown Eggs (Pack of 6)",
        category: "Dairy & Eggs",
        price: 55.0,
        stockQuantity: 14,
        iconEmoji: "🥚",
        unit: "6 pcs",
        expiryHoursRemaining: 72,
        isFragile: true,
      ),
      InventoryItem(
        id: "item-104",
        storeId: "store-001",
        barcode: "8901058852219",
        title: "Fortune Sunlite Refined Sunflower Oil",
        category: "Oils & Staples",
        price: 135.0,
        stockQuantity: 9,
        iconEmoji: "🌻",
        unit: "1 Litre pouch",
        isFragile: false,
      ),
      InventoryItem(
        id: "item-105",
        storeId: "store-001",
        barcode: "8901262010017",
        title: "Tata Salt Vacuum Evaporated Iodized",
        category: "Oils & Staples",
        price: 28.0,
        stockQuantity: 30,
        iconEmoji: "🧂",
        unit: "1 kg",
        isFragile: false,
      ),
      InventoryItem(
        id: "item-106",
        storeId: "store-001",
        barcode: "8901719104018",
        title: "Aashirvaad Shudh Chakki Atta",
        category: "Flours & Grains",
        price: 260.0,
        stockQuantity: 6,
        iconEmoji: "🌾",
        unit: "5 kg bag",
        isFragile: false,
      ),
    ];

    // Partner store items (Mahadev Supermarket)
    storeInventories["store-002"] = [
      InventoryItem(
        id: "item-201",
        storeId: "store-002",
        barcode: "8901030383821",
        title: "Amul Taaza Homogenised Toned Milk",
        category: "Dairy & Eggs",
        price: 32.0,
        stockQuantity: 25,
        iconEmoji: "🥛",
        unit: "500 ml pouch",
        expiryHoursRemaining: 24,
        isFragile: false,
      ),
      InventoryItem(
        id: "item-202",
        storeId: "store-002",
        barcode: "8901491101837",
        title: "Modern 100% Whole Wheat Bread",
        category: "Bakery",
        price: 45.0,
        stockQuantity: 12,
        iconEmoji: "🍞",
        unit: "400g pack",
        expiryHoursRemaining: 16,
        isFragile: true,
      ),
      InventoryItem(
        id: "item-203",
        storeId: "store-002",
        barcode: "8901725181222",
        title: "Farm Fresh Farm Brown Eggs (Pack of 6)",
        category: "Dairy & Eggs",
        price: 55.0,
        stockQuantity: 20,
        iconEmoji: "🥚",
        unit: "6 pcs",
        expiryHoursRemaining: 96,
        isFragile: true,
      ),
    ];
  }

  void _initSampleOrders() {
    final now = DateTime.now();
    subscriptions = [
      Subscription(
        id: "SUB-101",
        consumerId: "usr-881",
        storeId: "store-001",
        itemId: "item-101",
        itemTitle: "Amul Taaza Homogenised Toned Milk",
        frequency: "DAILY",
        timeSlot: "6:30 AM - 7:30 AM",
        quantity: 2,
        price: 32.0,
        status: "ACTIVE",
      ),
    ];

    orders = [
      BliptoOrder(
        id: "ORD-9281",
        consumerId: "usr-881",
        storeId: "store-001",
        storeName: "Gupta Kirana & Provisions",
        items: [
          OrderItem(item: storeInventories["store-001"]![0], quantity: 2),
          OrderItem(item: storeInventories["store-001"]![1], quantity: 1),
        ],
        subtotal: 109.0,
        deliveryFee: 10.0,
        totalAmount: 119.0,
        deliveryOtp: "4192",
        createdAt: now.subtract(const Duration(minutes: 8)),
        status: OrderStatus.outForDelivery,
        hasFragileItems: true,
        substitutePreference: "REPLACE_SIMILAR",
      ),
      BliptoOrder(
        id: "ORD-9104",
        consumerId: "usr-881",
        storeId: "store-001",
        storeName: "Gupta Kirana & Provisions",
        items: [
          OrderItem(item: storeInventories["store-001"]![2], quantity: 1),
        ],
        subtotal: 55.0,
        deliveryFee: 10.0,
        totalAmount: 65.0,
        deliveryOtp: "8319",
        createdAt: now.subtract(const Duration(minutes: 35)),
        status: OrderStatus.delivered,
        hasFragileItems: true,
        fragileVerified: true,
        substitutePreference: "REPLACE_SIMILAR",
      ),
    ];
    merchantEscrowBalance = 119.0;
  }

  Store get activeMerchantStore {
    return stores.firstWhere((s) => s.id == activeMerchantStoreId, orElse: () => stores.first);
  }

  // --- Cart Operations (REQ-V2-CON-03: Multi-Shop Split Cart) ---
  void addToCart(String storeId, InventoryItem item) {
    activeCartStoreId = storeId;
    cartItemStoreMap[item.id] = storeId;
    final currentQty = cartItems[item.id] ?? 0;
    if (currentQty < item.stockQuantity) {
      cartItems[item.id] = currentQty + 1;
      notifyListeners();
    }
  }

  void removeFromCart(String itemId) {
    if (cartItems.containsKey(itemId)) {
      if (cartItems[itemId]! > 1) {
        cartItems[itemId] = cartItems[itemId]! - 1;
      } else {
        cartItems.remove(itemId);
        cartItemStoreMap.remove(itemId);
        if (cartItems.isEmpty) {
          activeCartStoreId = null;
        }
      }
      notifyListeners();
    }
  }

  int getCartCount(String itemId) {
    return cartItems[itemId] ?? 0;
  }

  List<String> get cartStoreIds {
    final ids = <String>{};
    for (var itemId in cartItems.keys) {
      final sId = cartItemStoreMap[itemId] ?? activeCartStoreId;
      if (sId != null) ids.add(sId);
    }
    return ids.toList();
  }

  bool get isSplitCart => cartStoreIds.length > 1;

  double get cartSubtotal {
    if (cartItems.isEmpty) return 0.0;
    double sum = 0.0;
    cartItems.forEach((itemId, qty) {
      final sId = cartItemStoreMap[itemId] ?? activeCartStoreId;
      final catalog = sId != null ? (storeInventories[sId] ?? []) : [];
      final item = catalog.firstWhere(
        (it) => it.id == itemId,
        orElse: () => catalog.isNotEmpty
            ? catalog.first
            : InventoryItem(
                id: itemId,
                storeId: sId ?? '',
                barcode: itemId,
                title: 'Item',
                category: 'General',
                price: 0,
                stockQuantity: 0,
                iconEmoji: '📦',
                unit: '1 unit',
              ),
      );
      sum += item.price * qty;
    });
    return sum;
  }

  // Single-store delivery fee: ₹10. Multi-shop bundled delivery fee: ₹15 (saves ₹5 compared to ₹10 * 2)
  double get cartDeliveryFee {
    if (cartSubtotal <= 0) return 0.0;
    return isSplitCart ? 15.0 : 10.0;
  }

  double get cartTotal => cartSubtotal + cartDeliveryFee;

  // --- Dynamic Spillover & Order Placement (with Multi-Shop Split Cart) ---
  BliptoOrder placeOrder({
    String paymentMethod = "UPI",
    double walletAmountUsed = 0.0,
    String substitutePreference = "REPLACE_SIMILAR",
  }) {
    if (cartItems.isEmpty) {
      throw StateError("Cart is empty");
    }

    if (isSplitCart) {
      final sIds = cartStoreIds;
      final splitGroupId = "GRP-${1000 + Random().nextInt(9000)}";
      final List<BliptoOrder> createdSubOrders = [];

      double remainingWalletToUse = min(walletAmountUsed, cartTotal);
      if (remainingWalletToUse > 0) {
        consumerWalletBalance = max(0.0, consumerWalletBalance - remainingWalletToUse);
      }

      for (int i = 0; i < sIds.length; i++) {
        final sId = sIds[i];
        final targetStore = stores.firstWhere((s) => s.id == sId, orElse: () => stores.first);
        final catalog = storeInventories[sId] ?? [];
        final List<OrderItem> subOrderItems = [];
        double subtotalForStore = 0.0;

        cartItems.forEach((itemId, qty) {
          if ((cartItemStoreMap[itemId] ?? activeCartStoreId) == sId) {
            final item = catalog.firstWhere((it) => it.id == itemId || it.barcode == itemId, orElse: () => catalog.first);
            item.stockQuantity = max(0, item.stockQuantity - qty);
            subOrderItems.add(OrderItem(item: item, quantity: qty));
            subtotalForStore += item.price * qty;
          }
        });

        // Split delivery fee: ₹10 for primary store, ₹5 for companion store (total ₹15)
        final double subDeliveryFee = (i == 0) ? 10.0 : 5.0;
        final double subTotal = subtotalForStore + subDeliveryFee;
        final double subWalletUsed = min(remainingWalletToUse, subTotal);
        remainingWalletToUse -= subWalletUsed;
        final double subPaidAmount = max(0.0, subTotal - subWalletUsed);

        final randomOtp = (1000 + Random().nextInt(9000)).toString();
        final subOrder = BliptoOrder(
          id: "ORD-${1000 + Random().nextInt(9000)}",
          splitGroupId: splitGroupId,
          consumerId: "usr-881",
          storeId: targetStore.id,
          storeName: targetStore.name,
          items: subOrderItems,
          subtotal: subtotalForStore,
          deliveryFee: subDeliveryFee,
          totalAmount: subTotal,
          deliveryOtp: randomOtp,
          createdAt: DateTime.now(),
          status: OrderStatus.placed,
          paymentMethod: paymentMethod,
          walletAmountUsed: subWalletUsed,
          paidAmount: subPaidAmount,
          substitutePreference: substitutePreference,
          hasFragileItems: subOrderItems.any((oi) => oi.item.isFragile),
          fragileVerified: false,
        );

        targetStore.activeOrdersCount += 1;
        orders.insert(0, subOrder);
        merchantEscrowBalance += subOrder.totalAmount;
        createdSubOrders.add(subOrder);

        _syncOrderToBackend(subOrder, targetStore.id);
      }

      hasIncomingOrderAlert = true;
      lastAlertOrderId = createdSubOrders.first.id;
      cartItems.clear();
      cartItemStoreMap.clear();
      activeCartStoreId = null;

      notifyListeners();
      return createdSubOrders.first;
    }

    // Single-store checkout path
    final targetStore = stores.firstWhere((s) => s.id == (activeCartStoreId ?? cartStoreIds.first));
    bool shouldSpillover = targetStore.isBusy || targetStore.isAtCapacity;
    Store fulfillingStore = targetStore;
    bool isSpillover = false;

    if (shouldSpillover) {
      final candidate = stores.firstWhere(
        (s) => s.id != targetStore.id && s.canAcceptOrders,
        orElse: () => targetStore,
      );
      if (candidate.id != targetStore.id) {
        fulfillingStore = candidate;
        isSpillover = true;
      }
    }

    final catalog = storeInventories[fulfillingStore.id] ?? storeInventories[targetStore.id]!;
    final List<OrderItem> orderItems = [];

    cartItems.forEach((itemId, qty) {
      final item = catalog.firstWhere(
        (it) => it.id == itemId || it.barcode == itemId,
        orElse: () => catalog.first,
      );
      item.stockQuantity = max(0, item.stockQuantity - qty);
      orderItems.add(OrderItem(item: item, quantity: qty));
    });

    final bool hasFragile = orderItems.any((oi) => oi.item.isFragile);
    final randomOtp = (1000 + Random().nextInt(9000)).toString();

    final effectiveWalletUsed = min(walletAmountUsed, cartTotal);
    if (effectiveWalletUsed > 0) {
      consumerWalletBalance = max(0.0, consumerWalletBalance - effectiveWalletUsed);
    }
    final effectivePaidAmount = max(0.0, cartTotal - effectiveWalletUsed);

    final newOrder = BliptoOrder(
      id: "ORD-${1000 + Random().nextInt(9000)}",
      consumerId: "usr-881",
      storeId: targetStore.id,
      storeName: targetStore.name,
      fulfillingStoreId: isSpillover ? fulfillingStore.id : null,
      fulfillingStoreName: isSpillover ? fulfillingStore.name : null,
      isSpillover: isSpillover,
      items: orderItems,
      subtotal: cartSubtotal,
      deliveryFee: cartDeliveryFee,
      totalAmount: cartTotal,
      deliveryOtp: randomOtp,
      createdAt: DateTime.now(),
      status: OrderStatus.placed,
      paymentMethod: paymentMethod,
      walletAmountUsed: effectiveWalletUsed,
      paidAmount: effectivePaidAmount,
      substitutePreference: substitutePreference,
      hasFragileItems: hasFragile,
      fragileVerified: false,
    );

    fulfillingStore.activeOrdersCount += 1;
    orders.insert(0, newOrder);
    merchantEscrowBalance += newOrder.totalAmount;
    hasIncomingOrderAlert = true;
    lastAlertOrderId = newOrder.id;

    cartItems.clear();
    cartItemStoreMap.clear();
    activeCartStoreId = null;

    _syncOrderToBackend(newOrder, targetStore.id);

    notifyListeners();
    return newOrder;
  }

  Future<void> _syncOrderToBackend(BliptoOrder order, String storeId) async {
    try {
      final itemsPayload = order.items.map((oi) => {
        "item_id": oi.item.id,
        "barcode": oi.item.barcode,
        "quantity": oi.quantity,
      }).toList();

      await http.post(
        Uri.parse("http://localhost:8080/v1/orders"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "consumer_id": order.consumerId,
          "store_id": storeId,
          "consumer_lat": 12.9352,
          "consumer_lng": 77.6245,
          "items": itemsPayload,
          "payment_method": order.paymentMethod,
          "wallet_amount_used": order.walletAmountUsed,
          "substitute_preference": order.substitutePreference,
        }),
      );
    } catch (e) {
      debugPrint("Local/offline sync note: $e");
    }
  }

  // --- Subscriptions (REQ-V2-CON-01) ---
  void createSubscription({
    required String storeId,
    required InventoryItem item,
    String frequency = "DAILY",
    String timeSlot = "6:30 AM - 7:30 AM",
    int quantity = 1,
  }) {
    final sub = Subscription(
      id: "SUB-${100 + Random().nextInt(900)}",
      consumerId: "usr-881",
      storeId: storeId,
      itemId: item.id,
      itemTitle: item.title,
      frequency: frequency,
      timeSlot: timeSlot,
      quantity: quantity,
      price: item.price,
      status: "ACTIVE",
    );
    subscriptions.insert(0, sub);
    _syncSubscriptionToBackend(sub);
    notifyListeners();
  }

  void toggleSubscription(String subId) {
    final idx = subscriptions.indexWhere((s) => s.id == subId);
    if (idx != -1) {
      subscriptions[idx].status = subscriptions[idx].status == "ACTIVE" ? "PAUSED" : "ACTIVE";
      notifyListeners();
    }
  }

  Future<void> _syncSubscriptionToBackend(Subscription sub) async {
    try {
      await http.post(
        Uri.parse("http://localhost:8080/v1/subscriptions"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "consumer_id": sub.consumerId,
          "store_id": sub.storeId,
          "item_id": sub.itemId,
          "item_title": sub.itemTitle,
          "frequency": sub.frequency,
          "time_slot": sub.timeSlot,
          "quantity": sub.quantity,
          "price": sub.price,
        }),
      );
    } catch (_) {}
  }

  // --- Fragile Delivery Verification (REQ-V2-DLV-02) ---
  void verifyFragileOrder(String orderId) {
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      orders[idx].fragileVerified = true;
      _syncFragileVerificationToBackend(orderId);
      notifyListeners();
    }
  }

  Future<void> _syncFragileVerificationToBackend(String orderId) async {
    try {
      await http.post(
        Uri.parse("http://localhost:8080/v1/orders/$orderId/verify-fragile"),
        headers: {"Content-Type": "application/json"},
      );
    } catch (_) {}
  }

  // --- Kirana Perishables & Expiry (REQ-V2-MER-02) ---
  List<InventoryItem> getStorePerishables(String storeId) {
    final catalog = storeInventories[storeId] ?? [];
    return catalog.where((it) => (it.expiryHoursRemaining != null && it.expiryHoursRemaining! <= 24) || it.isLowStock).toList();
  }

  // --- Merchant Operations ---
  void toggleBusyMode(String storeId) {
    final idx = stores.indexWhere((s) => s.id == storeId);
    if (idx != -1) {
      stores[idx].isBusy = !stores[idx].isBusy;
      notifyListeners();
    }
  }

  void acceptOrder(String orderId) {
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      orders[idx].status = OrderStatus.packing;
      hasIncomingOrderAlert = false;
      notifyListeners();
    }
  }

  void markOrderOutForDelivery(String orderId) {
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      orders[idx].status = OrderStatus.outForDelivery;
      notifyListeners();
    }
  }

  void dismissAlert() {
    hasIncomingOrderAlert = false;
    notifyListeners();
  }

  // Barcode Intake (Mobile Shelf Sync)
  void intakeBarcodeItem({
    required String barcode,
    required String title,
    required String category,
    required double price,
    required int quantity,
    required String unit,
    required String emoji,
  }) {
    final catalog = storeInventories[activeMerchantStoreId] ?? [];
    final existingIdx = catalog.indexWhere((it) => it.barcode == barcode);
    if (existingIdx != -1) {
      catalog[existingIdx].stockQuantity += quantity;
    } else {
      catalog.add(
        InventoryItem(
          id: "item-${Random().nextInt(9999)}",
          storeId: activeMerchantStoreId,
          barcode: barcode,
          title: title,
          category: category,
          price: price,
          stockQuantity: quantity,
          iconEmoji: emoji,
          unit: unit,
        ),
      );
    }
    storeInventories[activeMerchantStoreId] = catalog;
    notifyListeners();
  }

  // Instant UPI settlement
  void requestInstantSettlement() {
    merchantSettledBalance += merchantEscrowBalance;
    merchantEscrowBalance = 0.0;
    notifyListeners();
  }

  // --- Delivery Staff Operations ---
  bool verifyDeliveryWithOtp(String orderId, String inputOtp) {
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      if (orders[idx].deliveryOtp == inputOtp.trim()) {
        orders[idx].status = OrderStatus.delivered;
        // Release from escrow to settled ledger
        merchantSettledBalance += orders[idx].totalAmount;
        merchantEscrowBalance = max(0.0, merchantEscrowBalance - orders[idx].totalAmount);
        _syncHandoffToBackend(orderId, inputOtp.trim());
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  void verifyDeliveryWithPhoto(String orderId, String photoProofLabel) {
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      orders[idx].status = OrderStatus.delivered;
      orders[idx].deliveryProofPhoto = photoProofLabel;
      merchantSettledBalance += orders[idx].totalAmount;
      merchantEscrowBalance = max(0.0, merchantEscrowBalance - orders[idx].totalAmount);
      notifyListeners();
    }
  }

  // --- Consumer Dispute & Instant Escrow Refund ---
  void fileItemDispute({
    required String orderId,
    required String itemId,
    required String itemTitle,
    required String reason,
    required double refundAmount,
    required String photoProof,
  }) {
    final dispute = Dispute(
      id: "DSP-${1000 + Random().nextInt(9000)}",
      orderId: orderId,
      itemId: itemId,
      itemTitle: itemTitle,
      reason: reason,
      refundAmount: refundAmount,
      filedAt: DateTime.now(),
      photoPath: photoProof,
      status: 'AUTO_REFUNDED',
    );
    disputes.insert(0, dispute);

    // Instant Escrow Refund into Consumer Wallet
    consumerWalletBalance += refundAmount;

    // Deduct from Merchant Escrow/Settled ledger
    if (merchantEscrowBalance >= refundAmount) {
      merchantEscrowBalance -= refundAmount;
    } else {
      merchantSettledBalance = max(0.0, merchantSettledBalance - refundAmount);
    }

    // Three-strike increment
    merchantStrikeCount += 1;

    // Mark order status
    final ordIdx = orders.indexWhere((o) => o.id == orderId);
    if (ordIdx != -1) {
      orders[ordIdx].status = OrderStatus.refunded;
    }

    _syncDisputeToBackend(orderId, itemId, reason, photoProof);

    notifyListeners();
  }

  Future<void> _syncHandoffToBackend(String orderId, String otp) async {
    try {
      await http.post(
        Uri.parse("http://localhost:8080/v1/orders/$orderId/verify-delivery"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"otp": otp}),
      );
    } catch (_) {}
  }

  Future<void> _syncDisputeToBackend(String orderId, String itemId, String reason, String photo) async {
    try {
      await http.post(
        Uri.parse("http://localhost:8080/v1/orders/$orderId/dispute"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "item_id": itemId,
          "reason": reason,
          "photo_base64": photo,
        }),
      );
    } catch (_) {}
  }

  // --- Strike Appeal (REQ-V2-OPS-03) ---
  Future<bool> fileStrikeAppeal({
    required String storeId,
    required String disputeId,
    required String reason,
    required String proofNote,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("http://localhost:8080/v1/merchants/strike-appeal"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "store_id": storeId,
          "dispute_id": disputeId,
          "reason": reason,
          "proof_note": proofNote,
        }),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Strike appeal sync note: $e");
    }
    return false;
  }
}
