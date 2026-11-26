import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../models/order.dart';

class DisputeScreen extends StatefulWidget {
  final AppState state;
  final BliptoOrder order;

  const DisputeScreen({Key? key, required this.state, required this.order}) : super(key: key);

  @override
  State<DisputeScreen> createState() => _DisputeScreenState();
}

class _DisputeScreenState extends State<DisputeScreen> {
  String? selectedItemId;
  String reason = "Damaged / Broken packaging";
  bool isPhotoCaptured = false;
  bool isSubmitting = false;

  final List<String> reasons = [
    "Damaged or torn packaging",
    "Expired, stale, or rotten item",
    "Item was missing from packet",
    "Received the wrong item",
  ];

  @override
  Widget build(BuildContext context) {
    final items = widget.order.items;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: const Text(
          "Instant Refund: Return Bad Items",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "No waiting for customer care! Just snap a quick photo of the damaged or wrong item and get your money back in seconds.",
                      style: TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Select Defective Item
            const Text("1. Which item had a problem?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: items.map((oi) {
                  return RadioListTile<String>(
                    dense: true,
                    selected: selectedItemId == oi.item.id,
                    title: Text("${oi.item.iconEmoji} ${oi.item.title}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    subtitle: Text("Price: ₹${oi.item.price.toStringAsFixed(0)}", style: const TextStyle(fontSize: 11)),
                    value: oi.item.id,
                    groupValue: selectedItemId,
                    activeColor: const Color(0xFF00B074),
                    onChanged: (val) => setState(() => selectedItemId = val),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Select Reason
            const Text("2. What went wrong?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: reason,
                  isExpanded: true,
                  items: reasons.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 13)))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => reason = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Camera Photo Proof
            const Text("3. Take a quick photo of the item", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                setState(() => isPhotoCaptured = true);
              },
              child: Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isPhotoCaptured ? const Color(0xFFE8F5E9) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isPhotoCaptured ? const Color(0xFF00B074) : Colors.grey.shade300,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isPhotoCaptured ? Icons.check_circle : Icons.camera_alt_outlined,
                        size: 36,
                        color: isPhotoCaptured ? const Color(0xFF00B074) : Colors.grey.shade600,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isPhotoCaptured ? "Photo captured! (Tap to retake)" : "Tap here to take photo with phone camera",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isPhotoCaptured ? const Color(0xFF2E7D32) : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B074),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: (selectedItemId != null && isPhotoCaptured && !isSubmitting)
                    ? () {
                        setState(() => isSubmitting = true);
                        final chosen = items.firstWhere((it) => it.item.id == selectedItemId);
                        widget.state.fileItemDispute(
                          orderId: widget.order.id,
                          itemId: chosen.item.id,
                          itemTitle: chosen.item.title,
                          reason: reason,
                          refundAmount: chosen.item.price * chosen.quantity,
                          photoProof: "proof_${DateTime.now().millisecondsSinceEpoch}.jpg",
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF2E7D32),
                            content: Text("₹${(chosen.item.price * chosen.quantity).toStringAsFixed(0)} immediately refunded to your wallet!"),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    : null,
                child: Text(
                  isSubmitting ? "Processing Refund..." : "Send Photo & Get Instant Refund",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
