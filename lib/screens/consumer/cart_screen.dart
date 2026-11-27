import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import 'order_tracking_screen.dart';

class CartScreen extends StatefulWidget {
  final AppState state;

  const CartScreen({Key? key, required this.state}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String selectedPaymentMethod = "UPI";
  bool useWallet = false;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final storeId = state.activeCartStoreId;
    final store = storeId != null
        ? state.stores.firstWhere((s) => s.id == storeId, orElse: () => state.stores.first)
        : null;

    final catalog = storeId != null ? (state.storeInventories[storeId] ?? []) : [];

    final walletBal = state.consumerWalletBalance;
    final walletDeductible = min(walletBal, state.cartTotal);
    final finalPayable = state.cartTotal - (useWallet ? walletDeductible : 0.0);

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
                                "Direct from shelf • Estimated ~${store?.estimatedMinutes ?? 15} mins",
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
                            Text("Clean & Honest Bill (No Surprise Fees)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                        const Divider(height: 20),
                        _buildBillRow("Items Total", "₹${state.cartSubtotal.toStringAsFixed(0)}"),
                        _buildBillRow("Delivery Boy Fee", "₹${state.cartDeliveryFee.toStringAsFixed(0)}"),
                        _buildBillRow("Surge / Rain fee", "₹0 (We never charge surge)", highlightGreen: true),
                        _buildBillRow("Packing / Platform fee", "₹0 (Free)", highlightGreen: true),
                        if (useWallet && walletDeductible > 0)
                          _buildBillRow("Blipto Wallet Applied", "-₹${walletDeductible.toStringAsFixed(0)}", highlightGreen: true),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Final Amount to Pay", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            Text("₹${finalPayable.toStringAsFixed(0)}",
                                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF00B074))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Options Selection (REQ-PAY-01, US-CON-06)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF00B074), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("How would you like to pay?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text("Safe Escrow", style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 10)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Blipto Wallet Deduction Toggle
                        if (walletBal > 0) ...[
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: useWallet,
                                  activeColor: const Color(0xFF00B074),
                                  onChanged: (val) {
                                    setState(() {
                                      useWallet = val ?? false;
                                    });
                                  },
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Use Blipto Wallet Balance", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      Text("₹${walletBal.toStringAsFixed(0)} available (saves ₹${walletDeductible.toStringAsFixed(0)})",
                                          style: const TextStyle(fontSize: 11, color: Color(0xFF00B074), fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],

                        // Main Payment Options (if wallet doesn't cover 100%)
                        if (finalPayable > 0) ...[
                          _buildPaymentTile("UPI", "⚡ Pay via UPI", "Google Pay, PhonePe, Paytm, BHIM"),
                          _buildPaymentTile("CARD", "💳 Credit / Debit Card", "Visa, Mastercard, RuPay"),
                          _buildPaymentTile("COD", "💵 Cash on Delivery", "Pay cash directly to delivery boy at door"),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle, color: Color(0xFF00B074), size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text("Your order is 100% covered by your Blipto Wallet balance!",
                                      style: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                        final method = finalPayable <= 0 ? "WALLET" : selectedPaymentMethod;
                        final order = widget.state.placeOrder(
                          paymentMethod: method,
                          walletAmountUsed: useWallet ? walletDeductible : 0.0,
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => OrderTrackingScreen(state: widget.state, activeOrderId: order.id)),
                        );
                      },
                      child: Text(
                        finalPayable <= 0
                            ? "Place Order (Paid via Wallet) ➔"
                            : "Pay ₹${finalPayable.toStringAsFixed(0)} via ${selectedPaymentMethod == 'UPI' ? 'UPI' : (selectedPaymentMethod == 'CARD' ? 'Card' : 'Cash')} ➔",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPaymentTile(String key, String title, String subtitle) {
    final isSelected = selectedPaymentMethod == key;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = key;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? const Color(0xFF00B074) : Colors.grey.shade300, width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? const Color(0xFF00B074) : Colors.grey,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                  Text(subtitle, style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600)),
                ],
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
