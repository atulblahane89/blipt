import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../models/order.dart';
import 'dispute_screen.dart';

class OrderTrackingScreen extends StatelessWidget {
  final AppState state;
  final String? activeOrderId;

  const OrderTrackingScreen({Key? key, required this.state, this.activeOrderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final order = activeOrderId != null
        ? state.orders.firstWhere((o) => o.id == activeOrderId, orElse: () => state.orders.first)
        : (state.orders.isNotEmpty ? state.orders.first : null);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: Text(
          order != null ? "Tracking #${order.id}" : "Order Tracking",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      body: order == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_bag_outlined, size: 56, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text("No Active Orders Yet", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    const SizedBox(height: 8),
                    const Text(
                      "When you place an order from any neighborhood kirana, its live status, 4-digit delivery code, and instant refunds will appear right here.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B074),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Browse Stores", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dynamic Spillover Alert if routed
                  if (order.isSpillover)
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.alt_route_rounded, color: Colors.deepPurple, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Shop Sharing: Original shop was busy, so partner ${order.fulfillingStoreName} is delivering your order on time!",
                              style: const TextStyle(fontSize: 12, color: Colors.deepPurple, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Delivery Status Header Card with OTP
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order.statusDisplay,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00B074),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text("12-15 Mins", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Divider(color: Colors.white24, height: 1),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Delivery Code", style: TextStyle(color: Colors.white70, fontSize: 11)),
                                SizedBox(height: 2),
                                Text("Tell this 4-digit code to delivery person", style: TextStyle(color: Colors.white54, fontSize: 10)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                order.deliveryOtp,
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Stepper Progress
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildStepRow("Order Placed", "Synchronized with shelf stock", isComplete: true),
                        _buildStepLine(isComplete: order.status.index >= OrderStatus.packing.index),
                        _buildStepRow("Merchant Packing", "Store staff bagging items", isComplete: order.status.index >= OrderStatus.packing.index),
                        _buildStepLine(isComplete: order.status.index >= OrderStatus.outForDelivery.index),
                        _buildStepRow("Out for Delivery", "Store delivery boy en route (450m)", isComplete: order.status.index >= OrderStatus.outForDelivery.index),
                        _buildStepLine(isComplete: order.status.index >= OrderStatus.delivered.index),
                        _buildStepRow("Delivered", "Verified via 4-digit OTP or Photo", isComplete: order.status.index >= OrderStatus.delivered.index),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Dispute / Defect Action (REQ-CON-05)
                  if (order.status == OrderStatus.delivered || order.status == OrderStatus.refunded)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.red.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.shield_outlined, color: Colors.deepOrange, size: 18),
                              SizedBox(width: 8),
                              Text("Problem with your items?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Got a damaged, spoiled, or missing item? Take a quick photo for an instant refund to your wallet — no customer care calls needed.",
                            style: TextStyle(fontSize: 11, color: Colors.black54),
                          ),
                          const SizedBox(height: 12),
                          if (order.status == OrderStatus.refunded)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)),
                              child: const Row(
                                children: [
                                  Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 16),
                                  SizedBox(width: 6),
                                  Text("Money Refunded to Your Wallet", style: TextStyle(color: Color(0xFF2E7D32), fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )
                          else
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.deepOrange,
                                side: const BorderSide(color: Colors.deepOrange),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.camera_alt_outlined, size: 16),
                              label: const Text("Damaged Item? Get Instant Refund", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => DisputeScreen(state: state, order: order)),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildStepRow(String title, String subtitle, {required bool isComplete}) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isComplete ? const Color(0xFF00B074) : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isComplete ? Icons.check : Icons.circle,
            color: Colors.white,
            size: isComplete ? 14 : 8,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 13, fontWeight: isComplete ? FontWeight.bold : FontWeight.w500)),
            Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
      ],
    );
  }

  Widget _buildStepLine({required bool isComplete}) {
    return Container(
      margin: const EdgeInsets.only(left: 11),
      height: 20,
      width: 2,
      color: isComplete ? const Color(0xFF00B074) : Colors.grey.shade300,
    );
  }
}
