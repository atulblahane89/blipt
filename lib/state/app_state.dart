import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/store.dart';
import '../models/inventory_item.dart';
import '../models/order.dart';
import '../models/dispute.dart';

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
    ),
  ];

  // Active Store Selected in Merchant Hub
  String activeMerchantStoreId = "store-001";

  // Catalog items keyed by storeId
  Map<String, List<InventoryItem>> storeInventories = {};

  // Shopping Cart: StoreId -> (ItemId -> Quantity)
  Map<String, int> cartItems = {};
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
      ),
    ];
  }

  void _initSampleOrders() {
    final now = DateTime.now();
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
      ),
    ];
    merchantEscrowBalance = 119.0;
  }

  Store get activeMerchantStore {
    return stores.firstWhere((s) => s.id == activeMerchantStoreId, orElse: () => stores.first);
  }

  // --- Cart Operations ---
  void addToCart(String storeId, InventoryItem item) {
    if (activeCartStoreId != null && activeCartStoreId != storeId) {
      // Switching store clears prior cart
      cartItems.clear();
    }
    activeCartStoreId = storeId;
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

  double get cartSubtotal {
    if (activeCartStoreId == null) return 0.0;
    final catalog = storeInventories[activeCartStoreId] ?? [];
    double sum = 0.0;
    cartItems.forEach((itemId, qty) {
      final item = catalog.firstWhere((it) => it.id == itemId, orElse: () => catalog.first);
      sum += item.price * qty;
    });
    return sum;
  }

  double get cartDeliveryFee => cartSubtotal > 0 ? 10.0 : 0.0;
  double get cartTotal => cartSubtotal + cartDeliveryFee;

  // --- Dynamic Spillover & Order Placement ---
  BliptoOrder placeOrder({String paymentMethod = "UPI", double walletAmountUsed = 0.0}) {
    if (activeCartStoreId == null || cartItems.isEmpty) {
      throw StateError("Cart is empty");
    }

    final targetStore = stores.firstWhere((s) => s.id == activeCartStoreId);
    bool shouldSpillover = targetStore.isBusy || targetStore.isAtCapacity;
    Store fulfillingStore = targetStore;
    bool isSpillover = false;

    if (shouldSpillover) {
      // Find partner store with available capacity within 1.2km
      final candidate = stores.firstWhere(
        (s) => s.id != targetStore.id && s.canAcceptOrders,
        orElse: () => targetStore,
      );
      if (candidate.id != targetStore.id) {
        fulfillingStore = candidate;
        isSpillover = true;
      }
    }

    // Build order items and decrement stock in fulfilling store
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

    final randomOtp = (1000 + Random().nextInt(9000)).toString();

    // Deduct wallet if used
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
    );

    // Update store capacity
    fulfillingStore.activeOrdersCount += 1;
    orders.insert(0, newOrder);

    // Lock funds in Escrow
    merchantEscrowBalance += newOrder.totalAmount;

    // Trigger Merchant Alert chime
    hasIncomingOrderAlert = true;
    lastAlertOrderId = newOrder.id;

    // Reset Cart
    cartItems.clear();
    activeCartStoreId = null;

    // Asynchronously log to the App Owner's Backend & Admin Dashboard
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
        }),
      );
    } catch (e) {
      debugPrint("Local/offline sync note: $e");
    }
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
}
