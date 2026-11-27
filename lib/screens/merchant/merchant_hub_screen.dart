import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

            // 1. HERO FEATURE: बोलकर सामान जोड़ें (Speak to Add Items) (REQ-V2-MER-01)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.mic, color: Color(0xFF00B074), size: 22),
                          SizedBox(width: 8),
                          Text(
                            "बोलकर सामान जोड़ें (Speak to Add Items)",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00B074).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF00B074)),
                        ),
                        child: const Text("बोलें और जोड़ें", style: TextStyle(color: Color(0xFF00B074), fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "हिंदी या English में बोलें (जैसे: '10 पैकेट फॉर्च्यून तेल 1 लीटर ₹135') - बिना टाइप किए सामान तुरंत दुकान में जुड़ जाएगा।",
                    style: TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.3),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B074),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.mic_none_rounded, color: Colors.white, size: 20),
                      label: const Text(
                        "🎙️ बोलकर सामान जोड़ें (Tap & Speak)",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      onPressed: () => _openVoiceIntakeDialog(context, state),
                    ),
                  ),
                ],
              ),
            ),

            // Quick Actions: Voice Add + Barcode Scan + Bank Transfer
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.mic, color: Color(0xFF00B074), size: 17),
                    label: const Text("बोलकर जोड़ें", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    onPressed: () => _openVoiceIntakeDialog(context, state),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B074),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 17),
                    label: const Text("बारकोड स्कैन", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => BarcodeIntakeScreen(state: state)),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0F172A),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.currency_rupee, size: 16),
                    label: const Text("बैंक खाता", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
            const SizedBox(height: 16),

            // 2. HERO FEATURE: आस-पड़ोस की मांग (What Neighbors Looked For Today) (REQ-V2-MER-04)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBFDBFE), width: 1.5),
                boxShadow: [
                  BoxShadow(color: Colors.blue.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Text("📈", style: TextStyle(fontSize: 18)),
                          SizedBox(width: 6),
                          Text("आस-पड़ोस की मांग (Neighborhood Demand)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF0F172A))),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(6)),
                        child: const Text("🔥 आज सबसे ज़्यादा खोजा गया", style: TextStyle(color: Color(0xFF1D4ED8), fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text("आस-पास के ग्राहकों ने आज यह सामान ढूंढा जो किसी दुकान पर नहीं मिला:", style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 12),
                  _buildDemandSignalItem(
                    context,
                    state,
                    emoji: "🍜",
                    title: "Maggi 2-Minute Masala Noodles (Pack of 4)",
                    category: "Instant Food",
                    price: 56.0,
                    unit: "4 x 70g pack",
                    searches: 48,
                    potentialRevenue: 2688,
                  ),
                  _buildDemandSignalItem(
                    context,
                    state,
                    emoji: "🧈",
                    title: "Amul Butter Pasteurized (500g Block)",
                    category: "Dairy & Eggs",
                    price: 275.0,
                    unit: "500g pack",
                    searches: 36,
                    potentialRevenue: 9900,
                  ),
                  _buildDemandSignalItem(
                    context,
                    state,
                    emoji: "🍵",
                    title: "Tata Tea Gold Leaf Tea (500g Pack)",
                    category: "Tea & Beverages",
                    price: 280.0,
                    unit: "500g pack",
                    searches: 28,
                    potentialRevenue: 7840,
                  ),
                  _buildDemandSignalItem(
                    context,
                    state,
                    emoji: "🥔",
                    title: "Haldiram's Nagpur Aloo Bhujia (400g)",
                    category: "Snacks & Namkeen",
                    price: 110.0,
                    unit: "400g pouch",
                    searches: 24,
                    potentialRevenue: 2640,
                  ),
                ],
              ),
            ),

            // 3. HERO FEATURE: भीड़ में पार्टनर दुकान को ऑर्डर भेजना (Order Sharing When Busy) (REQ-V2-OPS-01)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: store.isBusy ? Colors.deepOrange.shade300 : const Color(0xFFE2E8F0), width: 1.5),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.handshake_outlined, color: Color(0xFF00B074), size: 18),
                          SizedBox(width: 6),
                          Text("पार्टनर दुकान ऑर्डर शेयरिंग (Order Sharing)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF0F172A))),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: store.isBusy ? const Color(0xFFFFF7ED) : const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: store.isBusy ? Colors.deepOrange : const Color(0xFF16A34A)),
                        ),
                        child: Text(
                          store.isBusy ? "🟠 पार्टनर दुकान संभाल रही है (1.5% कमाई चालू)" : "🟢 आपकी दुकान चालू है",
                          style: TextStyle(
                            color: store.isBusy ? Colors.deepOrange : const Color(0xFF15803D),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    store.isBusy
                        ? "दुकान में भीड़ होने पर अतिरिक्त ऑर्डर महादेव सुपरमार्केट (850m) को भेजे जा रहे हैं। आपको बिना सामान पैक किए 1.5% कमीशन मिल रहा है।"
                        : "जब दुकान में बहुत भीड़ हो या 'व्यस्त' चालू हो, तो ऑर्डर पास की पार्टनर दुकान पर चले जाते हैं ताकि ग्राहक ना छूटे और आपको 1.5% कमीशन मिलता रहे।",
                    style: TextStyle(fontSize: 11, color: store.isBusy ? Colors.deepOrange.shade900 : Colors.grey.shade600, height: 1.3),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTelemetryItem("पार्टनर दुकान", "महादेव सुपरमार्केट (850m)"),
                        _buildTelemetryItem("भेजे गए ऑर्डर", store.isBusy ? "2 ऑर्डर" : "0 (तैयार)"),
                        _buildTelemetryItem("आपकी कमाई", store.isBusy ? "₹18.50 (1.5%)" : "₹0.00"),
                        _buildTelemetryItem("डिलीवरी समय", "14 मिनट"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Perishables & Short-Shelf-Life Expiry Alerts (REQ-V2-MER-02)
            Builder(
              builder: (context) {
                final perishables = state.getStorePerishables(store.id);
                if (perishables.isEmpty) return const SizedBox.shrink();
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Text("⚠️", style: TextStyle(fontSize: 16)),
                              SizedBox(width: 6),
                              Text("Short Shelf Life & Low Stock Alerts", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF92400E))),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(6)),
                            child: Text("${perishables.length} Action Needed", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...perishables.map((item) {
                        final isCritical = item.expiryHoursRemaining != null && item.expiryHoursRemaining! <= 12;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isCritical ? Colors.red.shade200 : const Color(0xFFFDE68A)),
                          ),
                          child: Row(
                            children: [
                              Text(item.iconEmoji, style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    Text(
                                      item.expiryHoursRemaining != null
                                          ? "Expires in ${item.expiryHoursRemaining} hrs • Stock: ${item.stockQuantity} ${item.unit}"
                                          : "Low Stock: only ${item.stockQuantity} units left!",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isCritical ? Colors.red.shade700 : const Color(0xFFB45309),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isCritical ? Colors.red.shade50 : const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isCritical ? "CRITICAL EXPIRY" : "SELL FIRST",
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: isCritical ? Colors.red.shade700 : const Color(0xFF92400E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),

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

  Widget _buildDemandSignalItem(
    BuildContext context,
    AppState state, {
    required String emoji,
    required String title,
    required String category,
    required double price,
    required String unit,
    required int searches,
    required int potentialRevenue,
  }) {
    final catalog = state.storeInventories[state.activeMerchantStoreId] ?? [];
    final alreadyStocked = catalog.any((it) => it.title.toLowerCase().contains(title.toLowerCase().split(' ').first));

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text(
                  "$searches nearby searches • Missed potential: ₹$potentialRevenue",
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF1D4ED8), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          if (alreadyStocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6)),
              child: const Text("In Stock", style: TextStyle(color: Color(0xFF15803D), fontSize: 11, fontWeight: FontWeight.bold)),
            )
          else
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B074),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () {
                state.intakeBarcodeItem(
                  barcode: "890${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}",
                  title: title,
                  category: category,
                  price: price,
                  quantity: 12,
                  unit: unit,
                  emoji: emoji,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("✅ Stocked 12 units of $title! Now available to neighbors."),
                    backgroundColor: const Color(0xFF00B074),
                  ),
                );
              },
              child: const Text("Stock This", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildTelemetryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
      ],
    );
  }

  void _openVoiceIntakeDialog(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Text("🎙️", style: TextStyle(fontSize: 22)),
                      SizedBox(width: 8),
                      Text("बोलकर सामान जोड़ें (Speak to Add Items)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                "हिंदी या English में बोलें (जैसे: '10 पैकेट मैगी नूडल्स ₹56' या 'Add 10 Fortune Oil at ₹135')",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Text("टेस्ट करने के लिए किसी एक पर टैप करें:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildVoiceOption(context, state, ctx, "10 पैकेट Maggi 2-Minute Noodles ₹56 में जोड़ो"),
              _buildVoiceOption(context, state, ctx, "Add 20 packets of Amul Taaza Milk at ₹32"),
              _buildVoiceOption(context, state, ctx, "5 पैकेट Aashirvaad Shudh Chakki Atta 5kg ₹245"),
              _buildVoiceOption(context, state, ctx, "Add 10 packets of Fortune Sunflower Oil 1 Litre at ₹135"),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVoiceOption(BuildContext context, AppState state, BuildContext bottomSheetCtx, String phrase) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          side: const BorderSide(color: Color(0xFFCBD5E1)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: const Icon(Icons.mic, color: Color(0xFF00B074), size: 18),
        label: Text(phrase, style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A), fontWeight: FontWeight.w500)),
        onPressed: () async {
          Navigator.pop(bottomSheetCtx);
          try {
            final res = await http.post(
              Uri.parse("http://localhost:8080/v1/merchants/catalog/voice-parse"),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({"voice_transcript": phrase}),
            );
            if (res.statusCode == 200) {
              final data = jsonDecode(res.body);
              if (data["parsed"] != null) {
                final p = data["parsed"];
                state.intakeBarcodeItem(
                  barcode: p["barcode"] ?? "890${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}",
                  title: p["title"] ?? "Groceries",
                  category: p["category"] ?? "General",
                  price: (p["price"] as num?)?.toDouble() ?? 50.0,
                  quantity: (p["quantity"] as num?)?.toInt() ?? 10,
                  unit: p["unit"] ?? "1 unit",
                  emoji: "📦",
                );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("🎙️ Voice added: ${p['title']} (${p['quantity']} units @ ₹${p['price']}) to shelf!"),
                    backgroundColor: const Color(0xFF00B074),
                    duration: const Duration(seconds: 2),
                  ),
                );
                return;
              }
            }
          } catch (_) {}

          // Fallback offline intake
          state.intakeBarcodeItem(
            barcode: "8901058852219",
            title: "Fortune Sunlite Refined Sunflower Oil",
            category: "Oils & Staples",
            price: 135.0,
            quantity: 10,
            unit: "1 Litre pouch",
            emoji: "🌻",
          );
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("🎙️ Voice added: Fortune Sunflower Oil (10 units @ ₹135) to shelf!"),
              backgroundColor: Color(0xFF00B074),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
}
