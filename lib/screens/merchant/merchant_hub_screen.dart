import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../models/order.dart';
import 'barcode_intake_screen.dart';
import 'escrow_ledger_screen.dart';

class MerchantHubScreen extends StatelessWidget {
  final AppState state;

  const MerchantHubScreen({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = state.activeMerchantStore;
    final activeOrders = state.orders.where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.refunded).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.storefront_rounded, color: Color(0xFF00B074), size: 18),
                const SizedBox(width: 6),
                Text(
                  store.name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
            const Text(
              "Kirana Shop Dashboard • Receive Orders & Money",
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Color(0xFF00B074)),
            tooltip: "Scan Barcode",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BarcodeIntakeScreen(state: state)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_balance, color: Colors.black87),
            tooltip: "My Earnings",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EscrowLedgerScreen(state: state)),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Loud Incoming Order Alarm Banner if new order is pending
            if (state.hasIncomingOrderAlert)
              _buildIncomingAlarmBanner(context),

            // Store Capacity & Busy Mode Control Card (REQ-MER-03)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Shop Rush? (Busy Mode)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(
                            store.isBusy
                                ? "ON: Forward orders to partner shop (You still earn commission!)"
                                : "OFF: Taking all nearby customer orders normally",
                            style: TextStyle(fontSize: 11, color: store.isBusy ? Colors.deepOrange : Colors.grey.shade600),
                          ),
                        ],
                      ),
                      Switch(
                        value: store.isBusy,
                        activeThumbColor: Colors.deepOrange,
                        onChanged: (val) {
                          state.toggleBusyMode(store.id);
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricItem("Out for Delivery", "${store.activeOrdersCount}/${store.maxActiveOrders}"),
                      _buildMetricItem("Money in Delivery", "₹${state.merchantEscrowBalance.toStringAsFixed(0)}"),
                      _buildMetricItem("Today's Earnings", "₹${state.merchantSettledBalance.toStringAsFixed(0)}"),
                      _buildMetricItem("Complaints", "${state.merchantStrikeCount}/3", isWarning: state.merchantStrikeCount > 0),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quick Actions: Barcode Ingestion + Escrow Release
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B074),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.barcode_reader, color: Colors.white, size: 20),
                    label: const Text("Scan Barcode", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => BarcodeIntakeScreen(state: state)),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0F172A),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.currency_rupee, size: 18),
                    label: const Text("Transfer to Bank", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => EscrowLedgerScreen(state: state)),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Active In-Flight Orders List (REQ-MER-02)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("In-Store Order Dispatch Terminal", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text("${activeOrders.length} In-Flight", style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),

            if (activeOrders.isEmpty)
              Container(
                padding: const EdgeInsets.all(28),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.done_all, color: Color(0xFF00B074), size: 36),
                    SizedBox(height: 8),
                    Text("All orders packed and fulfilled!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text("Incoming orders will ring with audio chime", style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              )
            else
              ...activeOrders.map((ord) => _buildOrderPackingCard(context, ord)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomingAlarmBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade600,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "🚨 NEW HYPER-LOCAL ORDER!",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  "Accept within 60s or auto-spillover triggers",
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (state.lastAlertOrderId != null) {
                state.acceptOrder(state.lastAlertOrderId!);
              } else {
                state.dismissAlert();
              }
            },
            child: const Text("PACK ORDER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, {bool isWarning = false}) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isWarning ? Colors.red : const Color(0xFF0F172A))),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildOrderPackingCard(BuildContext context, BliptoOrder order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("#${order.id}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(order.statusDisplay, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(order.customerAddress ?? "", style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
            const Divider(height: 16),
            // Packing items
            ...order.items.map((oi) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Text(oi.item.iconEmoji),
                    const SizedBox(width: 8),
                    Expanded(child: Text(oi.item.title, style: const TextStyle(fontSize: 12))),
                    Text("${oi.quantity}x", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total: ₹${order.totalAmount.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                if (order.status == OrderStatus.placed)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B074)),
                    onPressed: () => state.acceptOrder(order.id),
                    child: const Text("Mark Packed", style: TextStyle(color: Colors.white, fontSize: 12)),
                  )
                else if (order.status == OrderStatus.packing)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
                    onPressed: () => state.markOrderOutForDelivery(order.id),
                    child: const Text("Hand to Staff (Out)", style: TextStyle(color: Colors.white, fontSize: 12)),
                  )
                else
                  const Text("Delivery in progress", style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
