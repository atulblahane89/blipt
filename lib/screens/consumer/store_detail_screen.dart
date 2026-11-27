import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../models/store.dart';
import '../../models/inventory_item.dart';
import 'cart_screen.dart';

class StoreDetailScreen extends StatefulWidget {
  final AppState state;
  final Store store;

  const StoreDetailScreen({Key? key, required this.state, required this.store}) : super(key: key);

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  String selectedCategory = "All";

  @override
  Widget build(BuildContext context) {
    final catalog = widget.state.storeInventories[widget.store.id] ?? [];
    final categories = ["All", ...{for (var i in catalog) i.category}];

    final filteredItems = selectedCategory == "All"
        ? catalog
        : catalog.where((it) => it.category == selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.store.name,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            Text(
              "${widget.store.distanceMeters.toStringAsFixed(0)}m away • Fresh from local shelf",
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Trust Badges Banner (REQ-V2-CON-04)
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified, size: 12, color: Color(0xFF16A34A)),
                      const SizedBox(width: 4),
                      Text(
                        widget.store.trustBadge,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Text(
                    "⚡ ${widget.store.onTimeRate.toStringAsFixed(1)}% On-Time",
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8)),
                  ),
                ),
                if (widget.store.lightningPacker)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: const Text(
                      "📦 Lightning Packer",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // If store is in busy mode, display peer spillover banner
          if (widget.store.isBusy)
            Container(
              width: double.infinity,
              color: Colors.amber.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.brown),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Shop is busy right now! A friendly partner shop nearby will pack and deliver your order with no extra fee.",
                      style: TextStyle(fontSize: 11, color: Colors.brown, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

          // Category Pills
          Container(
            height: 48,
            color: Colors.white,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final cat = categories[idx];
                final isSel = selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFF00B074) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                        color: isSel ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Inventory Grid / List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filteredItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, idx) {
                final item = filteredItems[idx];
                return _buildItemCard(item);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.state.cartItems.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, -3)),
                ],
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total: ₹${widget.state.cartTotal.toStringAsFixed(0)}",
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        const Text(
                          "Honest flat pricing • 0 surge",
                          style: TextStyle(fontSize: 11, color: Color(0xFF00B074), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B074),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => CartScreen(state: widget.state)),
                        );
                      },
                      child: const Text("View Cart ➔", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildItemCard(InventoryItem item) {
    final inCart = widget.state.getCartCount(item.id);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Item Emoji Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(item.iconEmoji, style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 14),
          // Title & Pricing
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 2),
                Text(
                  item.unit,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      "₹${item.price.toStringAsFixed(0)}",
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF00B074)),
                    ),
                    const SizedBox(width: 8),
                    // Zero phantom inventory status tags
                    if (item.isOutOfStock)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(4)),
                        child: const Text("Out of Stock", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    else if (item.isLowStock)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(4)),
                        child: Text("Only ${item.stockQuantity} Left", style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(4)),
                        child: Text("${item.stockQuantity} in stock", style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Add or Counter and Subscription Option (REQ-V2-CON-01)
          if (item.isOutOfStock)
            const Text("Unavailable", style: TextStyle(color: Colors.grey, fontSize: 12))
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (inCart == 0)
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF00B074),
                      side: const BorderSide(color: Color(0xFF00B074)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onPressed: () {
                      widget.state.addToCart(widget.store.id, item);
                      setState(() {});
                    },
                    child: const Text("ADD", style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B074),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.white, size: 16),
                          onPressed: () {
                            widget.state.removeFromCart(item.id);
                            setState(() {});
                          },
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          padding: EdgeInsets.zero,
                        ),
                        Text(
                          "$inCart",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.white, size: 16),
                          onPressed: () {
                            widget.state.addToCart(widget.store.id, item);
                            setState(() {});
                          },
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                if (item.category == 'Dairy & Eggs' || item.category == 'Bakery') ...[
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () => _showSubscriptionSheet(item),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF7DD3FC)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.repeat, size: 10, color: Color(0xFF0284C7)),
                          SizedBox(width: 3),
                          Text("Daily Drop", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  void _showSubscriptionSheet(InventoryItem item) {
    String freq = "DAILY";
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(item.iconEmoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Subscribe: ${item.title}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const Text("Morning doorstep delivery by 7:00 AM • Cancel anytime", style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("Select Delivery Schedule:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text("Every Day"),
                        selected: freq == "DAILY",
                        onSelected: (val) => setModalState(() => freq = "DAILY"),
                        selectedColor: const Color(0xFFE8F5E9),
                      ),
                      ChoiceChip(
                        label: const Text("Alternate Days"),
                        selected: freq == "ALTERNATE_DAYS",
                        onSelected: (val) => setModalState(() => freq = "ALTERNATE_DAYS"),
                        selectedColor: const Color(0xFFE8F5E9),
                      ),
                      ChoiceChip(
                        label: const Text("Weekdays Only"),
                        selected: freq == "WEEKDAYS",
                        onSelected: (val) => setModalState(() => freq = "WEEKDAYS"),
                        selectedColor: const Color(0xFFE8F5E9),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B074),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        widget.state.createSubscription(
                          storeId: widget.store.id,
                          item: item,
                          frequency: freq,
                        );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("✅ Subscribed to ${item.title}! First delivery tomorrow 7:00 AM."),
                            backgroundColor: const Color(0xFF2E7D32),
                          ),
                        );
                      },
                      child: const Text("Confirm Subscription", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
