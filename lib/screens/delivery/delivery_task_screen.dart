import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../models/order.dart';

class DeliveryTaskScreen extends StatefulWidget {
  final AppState state;

  const DeliveryTaskScreen({Key? key, required this.state}) : super(key: key);

  @override
  State<DeliveryTaskScreen> createState() => _DeliveryTaskScreenState();
}

class _DeliveryTaskScreenState extends State<DeliveryTaskScreen> {
  final Map<String, TextEditingController> _otpControllers = {};

  @override
  void dispose() {
    for (var ctrl in _otpControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  TextEditingController _getController(String orderId) {
    if (!_otpControllers.containsKey(orderId)) {
      _otpControllers[orderId] = TextEditingController();
    }
    return _otpControllers[orderId]!;
  }

  @override
  Widget build(BuildContext context) {
    final runs = widget.state.orders.where((o) => o.status == OrderStatus.outForDelivery).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.moped_rounded, color: Color(0xFF00B074), size: 18),
                SizedBox(width: 6),
                Text("Delivery Partner", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
            Text("Neighborhood Deliveries • Nearby Kirana Stores", style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header & Offline Weak Signal Simulator (REQ-V2-DLV-03)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: widget.state.isDeliveryOffline ? Colors.orange.shade300 : Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            widget.state.isDeliveryOffline ? Icons.signal_cellular_connected_no_internet_0_bar : Icons.signal_cellular_alt,
                            color: widget.state.isDeliveryOffline ? Colors.deepOrange : const Color(0xFF00B074),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.state.isDeliveryOffline ? "Elevator / Basement (Offline)" : "Signal: Strong (Online)",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: widget.state.isDeliveryOffline ? Colors.deepOrange.shade800 : const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: widget.state.isDeliveryOffline ? Colors.deepOrange : const Color(0xFF0F172A),
                          side: BorderSide(color: widget.state.isDeliveryOffline ? Colors.deepOrange : Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: Icon(widget.state.isDeliveryOffline ? Icons.wifi : Icons.wifi_off, size: 14),
                        label: Text(
                          widget.state.isDeliveryOffline ? "Turn Online" : "Simulate Offline",
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => widget.state.toggleDeliveryOffline(),
                      ),
                    ],
                  ),
                  if (widget.state.offlineDeliveryQueue.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.sync, size: 16, color: Colors.deepOrange),
                              const SizedBox(width: 6),
                              Text(
                                "${widget.state.offlineDeliveryQueue.length} offline deliveries waiting to sync",
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              minimumSize: Size.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            onPressed: () async {
                              final count = await widget.state.syncOfflineDeliveries();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("✅ Synced $count offline deliveries with server! Shopkeeper paid."),
                                    backgroundColor: const Color(0xFF00B074),
                                  ),
                                );
                              }
                            },
                            child: const Text("Sync Now", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Smart Street-Level Route Batching (REQ-V2-DLV-01)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.alt_route_rounded, color: Color(0xFF00B074), size: 18),
                          SizedBox(width: 8),
                          Text("Batched Street Route", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00B074).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF00B074)),
                        ),
                        child: const Text("⚡ 12 mins saved", style: TextStyle(color: Color(0xFF00B074), fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Street: Green Glen Layout • 2 drops clustered along the same lane",
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildBatchStep("Drop 1", "Flat 402, Green Glen (450m)", true),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward, color: Colors.white38, size: 14),
                      const SizedBox(width: 6),
                      _buildBatchStep("Drop 2", "Flat 101, Green Glen (520m)", false),
                    ],
                  ),
                ],
              ),
            ),

            if (runs.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: const Column(
                  children: [
                    Icon(Icons.check_circle_outline, color: Color(0xFF00B074), size: 40),
                    SizedBox(height: 10),
                    Text("No deliveries right now", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text("When a shop packs an order, it will show up here immediately", style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              )
            else
              ...runs.map((order) => _buildDeliveryCard(context, order)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryCard(BuildContext context, BliptoOrder order) {
    final ctrl = _getController(order.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Order #${order.id}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(order.storeName, style: const TextStyle(fontSize: 11, color: Color(0xFF00B074), fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order.customerAddress ?? "Customer Location (450m away)",
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Fragile & Cold Packing Checklist (REQ-V2-DLV-02)
            if (order.hasFragileItems) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: order.fragileVerified ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: order.fragileVerified ? const Color(0xFF86EFAC) : const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    Text(order.fragileVerified ? "✅" : "⚠️", style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Fragile & Cold Items in Bag", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text(
                            order.fragileVerified
                                ? "Verified safe: Eggs intact & upright, Bread uncrushed"
                                : "Check before departure: Ensure eggs & bread are not crushed",
                            style: TextStyle(fontSize: 10.5, color: order.fragileVerified ? const Color(0xFF15803D) : const Color(0xFF92400E)),
                          ),
                        ],
                      ),
                    ),
                    if (!order.fragileVerified)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD97706),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: () {
                          widget.state.verifyFragileOrder(order.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("✅ Fragile checklist verified! Safe for doorstep delivery."),
                              backgroundColor: Color(0xFF2E7D32),
                            ),
                          );
                        },
                        child: const Text("Verify", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
            ],

            // OTP Input Field (REQ-DLV-02)
            const Text("Ask Customer for 4-Digit Delivery Code", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ctrl,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: const InputDecoration(
                      hintText: "Enter 4-digit code (e.g. 4192)",
                      counterText: "",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B074),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onPressed: () {
                    final success = widget.state.verifyDeliveryWithOtp(order.id, ctrl.text);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("✅ Code Verified! Delivery completed and shopkeeper gets paid instantly."),
                          backgroundColor: Color(0xFF2E7D32),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("❌ Incorrect code! Please ask the customer to check their screen."),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                  child: const Text("Confirm Code", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Fallback Photo Handoff
            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.camera_alt, size: 14, color: Colors.grey),
                label: const Text("Customer not answering? Take photo of packet at door", style: TextStyle(fontSize: 11, color: Colors.grey)),
                onPressed: () {
                  widget.state.verifyDeliveryWithPhoto(order.id, "photo_proof_${order.id}.jpg");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("📸 Photo saved! Order marked as delivered safely."),
                      backgroundColor: Color(0xFF0284C7),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchStep(String tag, String address, bool isFirst) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isFirst ? const Color(0xFF00B074).withOpacity(0.15) : const Color(0xFF334155),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isFirst ? const Color(0xFF00B074) : Colors.transparent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tag, style: TextStyle(color: isFirst ? const Color(0xFF00B074) : Colors.white70, fontWeight: FontWeight.bold, fontSize: 10)),
            Text(address, style: const TextStyle(color: Colors.white, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
