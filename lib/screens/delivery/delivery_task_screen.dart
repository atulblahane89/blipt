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
            // Status Header
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Orders to Deliver", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text("${runs.length} Deliveries Waiting", style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

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
}
