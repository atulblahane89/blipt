import 'package:flutter/material.dart';
import '../../state/app_state.dart';

class EscrowLedgerScreen extends StatelessWidget {
  final AppState state;

  const EscrowLedgerScreen({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: const Text(
          "Digital Escrow & Payout Ledger",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ledger Hero Card (Replacing Udhari with Instant Digital Settlement)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Settled Available Balance", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    "₹${state.merchantSettledBalance.toStringAsFixed(2)}",
                    style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Funds in Escrow Hold", style: TextStyle(color: Colors.white60, fontSize: 11)),
                          Text(
                            "₹${state.merchantEscrowBalance.toStringAsFixed(2)}",
                            style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Registered UPI ID", style: TextStyle(color: Colors.white60, fontSize: 11)),
                          Text(
                            state.activeMerchantStore.upiId,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Instant Settlement Button (REQ-MER-04)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B074),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.flash_on, color: Colors.white),
                label: const Text("Transfer to Bank Account via UPI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: () {
                  state.requestInstantSettlement();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Payout initiated to ${state.activeMerchantStore.upiId}!"),
                      backgroundColor: const Color(0xFF2E7D32),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Escrow Mechanics Explanation
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lock_clock, size: 18, color: Color(0xFF00B074)),
                      SizedBox(width: 8),
                      Text("How Blipto Escrow Protects You", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    "• 100% of customer payment is locked in digital escrow upon order placement.\n• Funds automatically unlock to your settled ledger the instant your delivery boy verifies the customer OTP or photo.\n• No delayed retailer credit cycles or uncollected cash.",
                    style: TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Disputes Log
            const Text("Disputes & Quality Audits", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            if (state.disputes.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: const Text("Zero active disputes. 100% Quality Score!", style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 13)),
              )
            else
              ...state.disputes.map((d) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.report_problem_outlined, color: Colors.redAccent, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${d.itemTitle} (${d.reason})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            Text("Auto-refunded: ₹${d.refundAmount.toStringAsFixed(0)} • Strike Logged", style: const TextStyle(fontSize: 10, color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}
