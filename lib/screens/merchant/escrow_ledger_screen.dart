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
          "My Earnings & Bank Payouts",
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
                  const Text("Ready to Transfer to Bank", style: TextStyle(color: Colors.white70, fontSize: 12)),
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
                          const Text("Orders Being Delivered Now", style: TextStyle(color: Colors.white60, fontSize: 11)),
                          Text(
                            "₹${state.merchantEscrowBalance.toStringAsFixed(2)}",
                            style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Your Bank UPI ID", style: TextStyle(color: Colors.white60, fontSize: 11)),
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
                label: const Text("Transfer to My Bank Account Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: () {
                  state.requestInstantSettlement();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Money sent to your UPI: ${state.activeMerchantStore.upiId}!"),
                      backgroundColor: const Color(0xFF2E7D32),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Daily Settlement & GST-Ready Tax Summary (REQ-V2-MER-03)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.receipt_long_rounded, color: Color(0xFF0F172A), size: 18),
                          SizedBox(width: 8),
                          Text("Daily GST & Tax Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(6)),
                        child: const Text("GST-Ready", style: TextStyle(color: Color(0xFF1D4ED8), fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text("GSTIN: 29AABCU9603R1ZM • Ready for monthly filing", style: TextStyle(fontSize: 10.5, color: Colors.grey)),
                  const Divider(height: 16),
                  _buildTaxRow("Gross Store Sales (Today)", "₹${state.merchantSettledBalance.toStringAsFixed(2)}"),
                  _buildTaxRow("CGST Collected (2.5%)", "₹${(state.merchantSettledBalance * 0.025).toStringAsFixed(2)}"),
                  _buildTaxRow("SGST Collected (2.5%)", "₹${(state.merchantSettledBalance * 0.025).toStringAsFixed(2)}"),
                  _buildTaxRow("Platform Commission (4.5%)", "₹${(state.merchantSettledBalance * 0.045).toStringAsFixed(2)}"),
                  const Divider(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Net Bank Payout", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                      Text(
                        "₹${(state.merchantSettledBalance - (state.merchantSettledBalance * 0.05) - (state.merchantSettledBalance * 0.045)).toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF00B074)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0F172A),
                        side: const BorderSide(color: Color(0xFF94A3B8)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text("Download GST Summary (CSV)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("📄 GST Report downloaded: gst_summary_${state.activeMerchantStore.id}_today.csv"),
                            backgroundColor: const Color(0xFF0284C7),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

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
                      Text("No More Udhari (Pending Credit) — Guaranteed Payment", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    "• Customer already paid online when ordering — zero risk of unpaid bills.\n• The second your delivery boy enters the customer's code, money is 100% yours.\n• Tap the green button anytime to transfer money straight into your bank account.",
                    style: TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Disputes Log
            const Text("Customer Complaints & Returns", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            if (state.disputes.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: const Text("Zero complaints. You have a 100% Quality Score!", style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 13)),
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

  Widget _buildTaxRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
          Text(value, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }
}
