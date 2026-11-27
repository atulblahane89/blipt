import 'package:flutter/material.dart';
import '../state/app_state.dart';

class RoleSwitcherBar extends StatelessWidget {
  final AppState state;

  const RoleSwitcherBar({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Blipto Brand Logo Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00B074), Color(0xFF00897B)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 4),
                  Text(
                    "Blipto",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Segmented Role Toggle
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    _buildRoleTab(
                      label: state.t("Customer", "ग्राहक"),
                      icon: Icons.shopping_bag_outlined,
                      isSelected: state.currentRole == AppRole.consumer,
                      onTap: () => state.switchRole(AppRole.consumer),
                    ),
                    _buildRoleTab(
                      label: state.t("Shopkeeper", "दुकानदार"),
                      icon: Icons.storefront_rounded,
                      isSelected: state.currentRole == AppRole.merchant,
                      onTap: () => state.switchRole(AppRole.merchant),
                      badgeCount: state.hasIncomingOrderAlert ? 1 : null,
                    ),
                    _buildRoleTab(
                      label: state.t("Delivery Boy", "डिलीवरी"),
                      icon: Icons.moped_rounded,
                      isSelected: state.currentRole == AppRole.deliveryStaff,
                      onTap: () => state.switchRole(AppRole.deliveryStaff),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Language Selector Toggle (EN | हिंदी)
            InkWell(
              onTap: () => state.toggleLanguage(),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: state.isHindi ? const Color(0xFFFFF7ED) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: state.isHindi ? Colors.orange.shade400 : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.language_rounded, size: 16, color: Color(0xFF0F172A)),
                    const SizedBox(width: 4),
                    Text(
                      state.isHindi ? "हि" : "EN",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: state.isHindi ? Colors.deepOrange.shade800 : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleTab({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    int? badgeCount,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    )
                  ]
                : [],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 15,
                    color: isSelected ? const Color(0xFF00B074) : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected ? const Color(0xFF1F2937) : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              if (badgeCount != null)
                Positioned(
                  top: -6,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      "!",
                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
