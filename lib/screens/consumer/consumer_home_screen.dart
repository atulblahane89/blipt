import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../models/store.dart';
import '../../models/order.dart';
import 'store_detail_screen.dart';
import 'cart_screen.dart';
import 'order_tracking_screen.dart';

class ConsumerHomeScreen extends StatelessWidget {
  final AppState state;

  const ConsumerHomeScreen({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Theme.of(context).primaryColor, size: 16),
                const SizedBox(width: 4),
                const Text(
                  "Green Glen Layout, Bellandur",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.black54),
              ],
            ),
            const Text(
              "Shops within 5-10 mins from your home",
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          // Wallet Pill
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFA5D6A7)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet, size: 14, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 4),
                  Text(
                    "₹${state.consumerWalletBalance.toStringAsFixed(0)}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1B5E20)),
                  ),
                ],
              ),
            ),
          ),
          // Active Orders shortcut button
          Center(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => OrderTrackingScreen(state: state)),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.moped, size: 15, color: Color(0xFF00B074)),
                    const SizedBox(width: 5),
                    Text(
                      state.orders.isNotEmpty ? "Track Order (${state.orders.length})" : "Track Order",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Order Live Tracker Card (Prominent when an order exists)
            if (state.orders.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF00B074), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.delivery_dining, color: Color(0xFF00B074), size: 22),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Track Your Order", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                                Text("Order #${state.orders.first.id} • ${state.orders.first.storeName}", style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: state.orders.first.status == OrderStatus.delivered ? const Color(0xFFE8F5E9) : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            state.orders.first.statusDisplay,
                            style: TextStyle(
                              color: state.orders.first.status == OrderStatus.delivered ? const Color(0xFF2E7D32) : const Color(0xFF92400E),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Delivery Code: ${state.orders.first.deliveryOtp}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF00B074)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00B074),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => OrderTrackingScreen(state: state)),
                            );
                          },
                          child: const Text("Open Live Tracking ➔", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // Banner: Transparent Zero-Surge Pledge
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Text("⚡", style: TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Your Trusted Neighborhood Kiranas",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        SizedBox(height: 3),
                        Text(
                          "Delivered in 15 mins • No surge pricing • What you see is what's in stock",
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ALWAYS-VISIBLE My Orders & Live Tracking Action Bar
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: state.orders.isNotEmpty ? const Color(0xFF00B074) : Colors.grey.shade300, width: 1.5),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => OrderTrackingScreen(state: state)),
                  );
                },
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delivery_dining, color: Color(0xFF00B074), size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                state.orders.isNotEmpty ? "Track Active Order" : "My Orders & Delivery Tracking",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                              ),
                              if (state.orders.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00B074),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    "${state.orders.length} Active",
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            state.orders.isNotEmpty
                                ? "Order #${state.orders.first.id} from ${state.orders.first.storeName} (${state.orders.first.statusDisplay})"
                                : "Tap to view delivery status, OTP code, or past orders",
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B074),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Text("Track", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios, color: Colors.white, size: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Active Stores Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Neighborhood Stores Near You",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                Text(
                  "${state.stores.length} Active",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF00B074)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Store Cards
            ...state.stores.map((store) => _buildStoreCard(context, store)).toList(),
          ],
        ),
      ),
      floatingActionButton: state.cartItems.isNotEmpty
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF00B074),
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              label: Text(
                "View Cart (${state.cartItems.values.fold(0, (a, b) => a + b)}) • ₹${state.cartTotal.toStringAsFixed(0)}",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CartScreen(state: state)),
                );
              },
            )
          : null,
    );
  }

  Widget _buildStoreCard(BuildContext context, Store store) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => StoreDetailScreen(state: state, store: store)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text("🏪", style: TextStyle(fontSize: 26)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                store.name,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.amber.shade300),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, size: 12, color: Colors.amber),
                                  const SizedBox(width: 2),
                                  Text(
                                    store.trustRating.toString(),
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          store.address,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 14, color: Colors.grey.shade700),
                      const SizedBox(width: 4),
                      Text(
                        "~${store.estimatedMinutes} mins",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.directions_walk, size: 14, color: Colors.grey.shade700),
                      const SizedBox(width: 2),
                      Text(
                        "${store.distanceMeters.toStringAsFixed(0)}m away",
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  // Store busy or open pill
                  if (store.isBusy)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: const Text(
                        "Shop Busy • Partner Delivering",
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Delivering Now",
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                      ),
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
