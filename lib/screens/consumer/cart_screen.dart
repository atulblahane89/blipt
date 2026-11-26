import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import 'order_tracking_screen.dart';

class CartScreen extends StatelessWidget {
  final AppState state;

  const CartScreen({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final storeId = state.activeCartStoreId;
    final store = storeId != null
        ? state.stores.firstWhere((s) => s.id == storeId, orElse: () => state.stores.first)
        : null;

    final catalog = storeId != null ? (state.storeInventories[storeId] ?? []) : [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: const Text(
          "Your Blipto Cart",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      body: state.cartItems.isEmpty
          ? const Center(
              child: Text("Your cart is empty", style: TextStyle(color: Colors.grey)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store attribution banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text("🏪", style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Fulfilling Store: ${store?.name ?? 'Local Store'}",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1B5E20)),
                              ),
                              Text(
                                "Direct from shelf • Estimated ~${store?.estimatedMinutes ?? 15} mins SLA",
                                style: const TextStyle(fontSize: 11, color: Color(0xFF2E7D32)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Item breakdown
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Order Items", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 10),
                        ...state.cartItems.entries.map((entry) {
                          final item = catalog.firstWhere((it) => it.id == entry.key, orElse: () => catalog.first);
                          final qty = entry.value;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Text(item.iconEmoji, style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(item.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                ),
                                Text("${qty}x  ₹${(item.price * qty).toStringAsFixed(0)}",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bill Details (Transparent, Zero Hidden Charges)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.verified_outlined, size: 16, color: Color(0xFF00B074)),
                            SizedBox(width: 6),
                            Text("Transparent Billing (Zero Dark Patterns)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                        const Divider(height: 20),
                        _buildBillRow("Item Subtotal", "₹${state.cartSubtotal.toStringAsFixed(0)}"),
                        _buildBillRow("Store Staff Delivery Fee", "₹${state.cartDeliveryFee.toStringAsFixed(0)}"),
                        _buildBillRow("Surge Fee", "₹0 (Always Flat)", highlightGreen: true),
                        _buildBillRow("Handling / Convenience Fee", "₹0 (Free)", highlightGreen: true),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("To Pay", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text("₹${state.cartTotal.toStringAsFixed(0)}",
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00B074))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Place Order Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B074),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        final order = state.placeOrder();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => OrderTrackingScreen(state: state, activeOrderId: order.id)),
                        );
                      },
                      child: Text(
                        "Place Order • ₹${state.cartTotal.toStringAsFixed(0)}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildBillRow(String label, String value, {bool highlightGreen = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: highlightGreen ? const Color(0xFF00B074) : const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}
